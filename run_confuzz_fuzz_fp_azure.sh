#!/bin/bash

# Example input:
# DOCKER_TAG INPUT_FILE_LINK

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
dockerTag=$(echo ${line} | cut -d',' -f1)
fileLink=$(echo ${line} | cut -d',' -f2)

RESULTSDIR=~/output/
mkdir -p $RESULTSDIR

echo "================Cloning confuzz repo to wd: SHA=$sha"
cd $AZ_BATCH_TASK_WORKING_DIR

wget https://mir.cs.illinois.edu/~swang516/confuzz/docker-fuzz-debug.sh
echo "================Finish repo clone"

echo "================Pull Container"
docker pull shuaiwang516/confuzz-image:$dockerTag

echo "================Start Running Fuzzing"
bash docker-fuzz-fp.sh $fileLink
echo "================Finish Running Fuzzing"
cp -r result/ $RESULTSDIR

endtime=$(date)
echo "endtime: $endtime"
