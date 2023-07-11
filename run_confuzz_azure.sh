#!/bin/bash

# Example input:
# confuzz-repo, sha, project_module, injection_config_file, fuzzing_duration (in seconds), test1+test2+test3+...+testN
# https://github.com/xlab-uiuc/confuzz.git,9eb14bae3b75e893dcbb4dc911602808aa844a30,Mar20,hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-core,target/classes/mapred-ctest.xml,60,org.apache.hadoop.mapred.TestDebug#test+org.apache.hadoop.mapred.TestJobAclsManager#testGroups
# "Usage: bash docker-fuzz.sh hadoop-yarn-project/hadoop-yarn/hadoop-yarn-common <project_name> <test_list> <output_dir> <fuzzing_duration>"

if [[ $1 == "" ]]; then
    echo "arg1 - Path to CSV file with confuzz_repo_git_url,sha,project_name,test_list,duration"
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
dockerTag=$(echo ${line} | cut -d',' -f3)
app=$(echo ${line} | cut -d',' -f4)
projmodule=$(echo ${line} | cut -d',' -f5)
regexFile=$(echo ${line} | cut -d',' -f6)
configGenerator=$(echo ${line} | cut -d',' -f7)
injectConfigFile=$(echo ${line} | cut -d',' -f8)
duration=$(echo ${line} | cut -d',' -f9)
testlist=$(echo ${line} | cut -d',' -f10)


RESULTSDIR=~/output/
mkdir -p $RESULTSDIR
cp docker-fuzz.sh $AZ_BATCH_TASK_WORKING_DIR
#echo "================Cloning confuzz repo to wd: SHA=$sha"
cd $AZ_BATCH_TASK_WORKING_DIR
#git clone $gitURL
#confuzzDirName=$(echo $gitURL | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
#cd $confuzzDirName
#git checkout $sha
#echo "================Finish repo clone"

echo "================Pull Container"
docker pull shuaiwang516/confuzz-image:$dockerTag

echo "================Start Running Fuzzing"
#cd docker/
# "Usage: bash docker-fuzz.sh Mar20 hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-core target/classes/mapred-ctest.xml 60 org.apache.hadoop.mapred.TestDebug#test+org.apache.hadoop.mapred.TestJobAclsManager#testGroups"
# Usage: bash docker-fuzz.sh <imageTag> <app> <testModule> <regexFile> <injectConfigFile> <duration> <test1+test2+...+testN>
bash docker-fuzz.sh $dockerTag $app $projmodule $regexFile $configGenerator $injectConfigFile $duration $testlist
echo "================Finish Running Fuzzing"
cp -r result/ $RESULTSDIR
