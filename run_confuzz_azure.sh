#!/bin/bash

# Example input:
# confuzz-repo, sha, project_name, test1;test2;test3;...;testN, fuzzing_duration (in seconds)
# https://github.com/xlab-uiuc/confuzz.git,9eb14bae3b75e893dcbb4dc911602808aa844a30,hcommon,org.apache.hadoop.crypto.key.kms.TestLoadBalancingKMSClientProvider#testTokenServiceCreationWithUriFormat;org.apache.hadoop.ipc.TestRPC#testRpcMetrics;org.apache.hadoop.ipc.TestRPC#testDecayRpcSchedulerMetrics,300

# "Usage: python3 fuzz_on_azure.py <project_name> <test_list> <output_dir> <fuzzing_duration>"

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
projname=$(echo ${line} | cut -d',' -f3)
testlist=$(echo ${line} | cut -d',' -f4)
duration=$(echo ${line} | cut -d',' -f5)

RESULTSDIR=~/output/
mkdir -p $RESULTSDIR
RESULTFILE=$RESULTSDIR/$projname-$testlist-output.txt

echo "================Cloning confuzz repo to wd: SHA=$sha"
cd $AZ_BATCH_TASK_WORKING_DIR
git clone $gitURL
confuzzDirName=$(echo $gitURL | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
cd $confuzzDirName
git checkout $sha
echo "================Finish repo clone"

echo "================Maven Install Confuzz"
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
JAVA_HOME=$JAVA_HOME mvn clean install -DskipTests

echo "================Start Running Fuzzing"
cd scripts/
# "Usage: python3 fuzz_on_azure.py <project_name> <test_list> <output_dir> <fuzzing_duration>"
python3 fuzz_on_azure.py $projname $testlist $RESULTSDIR $duration | tee -a $RESULTFILE
echo "================Finish Running Fuzzing $projname $testlist"
