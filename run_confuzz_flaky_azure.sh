# imageTag=$1
# app=$2
# testModule=$3
# regexFile=$4
# configGenerator=$5
# tests=$6

#!/bin/bash

if [[ $1 == "" ]]; then
    echo "arg1 - Path to CSV file with imageTag,app,testModule,regexFile,configGenerator,tests"
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

echo "================Starting Confuzz DeFlaky For Input: $line==================="
dockerTag=$(echo ${line} | cut -d',' -f1)
app=$(echo ${line} | cut -d',' -f2)
projmodule=$(echo ${line} | cut -d',' -f3)
regexFile=$(echo ${line} | cut -d',' -f4)
configGenerator=$(echo ${line} | cut -d',' -f5)
tests=$(echo ${line} | cut -d',' -f6)

RESULTSDIR=~/output/
mkdir -p $RESULTSDIR

cd $AZ_BATCH_TASK_WORKING_DIR

echo "================Downloading docker-flaky script file===================" 
wget https://mir.cs.illinois.edu/~swang516/confuzz/docker-flaky.sh

echo "================Pull Container===================="
docker pull shuaiwang516/confuzz-image:$dockerTag

echo "================Start Checking Flakiness in Docker $dockerTag=================="

bash docker-flaky.sh $dockerTag $app $projmodule $regexFile $configGenerator $tests

echo "================Finish Running Deflkay====================="
cp -r result/ $RESULTSDIR

endtime=$(date)
echo "endtime: $endtime"
