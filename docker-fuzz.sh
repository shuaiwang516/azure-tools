# To use this script, you need to build the image first with docker-build.sh

# Usage: bash docker-fuzz.sh <imageTag> <app> <testModule> <regexFile> <injectConfigFile> <duration> <test1+test2+...+testN>
# assumes that constraintFile is named constraint and regex file name
# root dir is where the two files are stored
# Note that fuzz-hadoop is stored in /home/ctestfuzz/ in the docker

#!/bin/bash
imageTag=$1
app=$2
testModule=$3
regexFile=$4
configGenerator=$5
injectConfigFile=$6
duration=$7
tests=$8
containerName=confuzz-container
# injectConfigFile=target/classes/ctest.xml
# regexFile=/home/ctestfuzz/fuzz-hadoop/regex.json

IFS="+" read -ra test_methods <<< "$tests"

docker run --name ${containerName} -u ctestfuzz -w "/home/ctestfuzz/${app}/${testModule}" -d -i -t "shuaiwang516/confuzz-image:${imageTag}" bash

for test in "${test_methods[@]}"; do
  # split the test string into the test class and test method using the "#" delimiter
  #echo $test
  testClass=$(echo $test | cut -d '#' -f 1)
  testMethod=$(echo $test | cut -d '#' -f 2)
  echo "Test Class: $testClass, Test Method: $testMethod"
  docker exec -u ctestfuzz ${containerName} mvn confuzz:fuzz -Dconfuzz.generator=${configGenerator} -Dmeringue.testClass=${testClass} -Dmeringue.testMethod=${testMethod} -DregexFile=${regexFile} -Dmeringue.duration=PT${duration}S
  docker exec -u ctestfuzz ${containerName} mvn confuzz:debug -Dconfuzz.generator=${configGenerator} -Dmeringue.testClass=${testClass} -Dmeringue.testMethod=${testMethod} -DregexFile=${regexFile} -DinjectConfigFile=${injectConfigFile}
done

mkdir -p result/
docker cp ${containerName}:/home/ctestfuzz/$app/$testModule/target/meringue/ result/
docker stop ${containerName}
docker rm ${containerName}
