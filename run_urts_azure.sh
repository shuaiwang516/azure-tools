#!/bin/bash

# Example input:
# https://github.com/xlab-uiuc/uRTS_artifacts.git,1b3ce98e23e4ec2be43dd579d12906386410fa50,
# retestall/ekstazi/urts,hcommon/hdfs/hbase/alluxio/zookeeper,1576f81dfe0156514ec06b6051e5df7928a294e2,c665ab02ed5c400b0c5e9e350686cd0e5b5e6972

if [[ $1 == "" ]]; then
    echo "arg1 - Path to CSV file with uRTS_repo_git_url,sha,mode,project_name,sha_of_prj"
    exit
fi

repo=$(git rev-parse HEAD)
echo "script vers: $repo"
dir=$(pwd)
echo "script dir: $dir"
starttime=$(date)
echo "starttime: $starttime"

cd ~/
projfile=$1
rounds=$2
input_container=$3
line=$(head -n 1 $projfile)

echo "================Starting experiment for input: $line"
gitURL=$(echo ${line} | cut -d',' -f1)
sha=$(echo ${line} | cut -d',' -f2)
mode=$(echo ${line} | cut -d',' -f3)
projname=$(echo ${line} | cut -d',' -f4)
projsha1=$(echo ${line} | cut -d',' -f5)
projsha2=$(echo ${line} | cut -d',' -f6)

RESULTSDIR=~/output/
mkdir -p $RESULTSDIR
RESULTFILE=$RESULTSDIR/$mode-$projname-$projsha1-$projsha2-output.txt
INSTALLINFO=$RESULTSDIR/$mode-$projname-$projsha1-$projsha2-install.txt
touch RESULTFILE
touch INSTALLINFO

echo "================Cloning uRTS_artifacts repo to wd: SHA=$sha"
cd $AZ_BATCH_TASK_WORKING_DIR
git clone $gitURL
urtsdirname=$(echo $gitURL | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
cd $urtsdirname
git checkout $sha
echo "================Finish repo clone"

echo "================Start Installing uRTS"
cd experiment/
bash setup_ubuntu.sh | tee -a $INSTALLINFO
bash install_tool.sh $mode | tee -a $INSTALLINFO
echo "================Finish Installing uRTS"

echo "================Start running $mode $projname $projsha1 $projsha2"
#bash run_azure.sh urts hcommon 1576f81dfe0156514ec06b6051e5df7928a294e2 c665ab02ed5c400b0c5e9e350686cd0e5b5e6972
bash run_azure.sh $mode $projname $projsha1 $projsha2 | tee -a $RESULTFILE
echo "================Finish running $mode $projname $projsha1 $projsha2"