#!/bin/bash

# Example input:
# NonDex-plugin-test-repo-url, sha, project_name (separated by %)
# https://github.com/MarcyGO/NonDex-plugin-test.git,0a9ee7e6b0670f08e5050a673924a96f6af6d3aa,gogradle/gogradle%diffplug/spotless%Leaking/Hunter

# "Usage: bash try_plugin.sh gogradle/gogradle%diffplug/spotless%Leaking/Hunter"

if [[ $1 == "" ]]; then
    echo "arg1 - Path to CSV file with NonDex-plugin-test-repo-url, sha, projects_name"
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

RESULTSDIR=~/output/
mkdir -p $RESULTSDIR
RESULTFILE=$RESULTSDIR/output.txt

echo "================Cloning NonDex-plugin-test-repo repo to wd: SHA=$sha"
cd $AZ_BATCH_TASK_WORKING_DIR
git clone $gitURL
cd NonDex-plugin-test/
git checkout $sha
echo "================Finish repo clone"

echo "================Gradle Install NonDex-plugin-test-repo"
git clone https://github.com/jchen8460/Nondex-Gradle-Plugin.git
cd Nondex-Gradle-Plugin && export GRADLE_OPTS="-Dfile.encoding=utf-8" && ./gradlew publishToMavenLocal && cd ..

echo "================Start Running nonDex"
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
echo "current dir: $(pwd)"
bash try_plugin.sh $projname | tee -a $RESULTFILE
cp -r output/ $RESULTSDIR
echo "================Finish Running nonDex $projname"
