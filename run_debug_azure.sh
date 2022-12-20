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
echo "projfile: $projfile"
rounds=$2
echo "rounds: $rounds"
input_container=$3
echo "input_container: $input_container"

line=$(head -n 1 $projfile)
echo "================Debug for input: $line"

echo "maven version: $(mvn -v)"
echo "java version: $(java -version)"