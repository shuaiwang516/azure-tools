#!/bin/bash

# Input:
# <dockerTag>, <app>, <module>, <cov_file_link>
# JUL25,fuzz-alluxio,core/common,https://shuaiwang516.github.io/xxx.cov


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

echo "================Starting Confuzz Coverage For Input: $line==================="
dockerTag=$(echo ${line} | cut -d',' -f1)
app=$(echo ${line} | cut -d',' -f2)
projmodule=$(echo ${line} | cut -d',' -f3)
covlink=$(echo ${line} | cut -d',' -f4)

RESULTSDIR=~/output/
mkdir -p $RESULTSDIR

cd $AZ_BATCH_TASK_WORKING_DIR

echo "================Downloading docker-coverage file===================" 
wget https://mir.cs.illinois.edu/~swang516/confuzz/docker-coverage.sh

echo "================Pull Container===================="
docker pull shuaiwang516/confuzz-image:$dockerTag

echo "================Start Calculating Coverage in Docker $dockerTag=================="

bash docker-coverage.sh $dockerTag $app $projmodule $covlink

echo "================Finish Running Fuzzing====================="
cp -r result/ $RESULTSDIR

endtime=$(data)
echo "endtime: $endtime"
