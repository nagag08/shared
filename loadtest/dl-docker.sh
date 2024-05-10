#!/bin/bash
apk add curl jq bash img
SERVERURL=$(basename $ARTIFACTORY_URL)
img login $SERVERURL -u $ARTIFACTORY_USER -p $ARTIFACTORY_PASSWORD 
curl -fL https://install-cli.jfrog.io | sh
jf c add loadtest --url $ARTIFACTORY_URL --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD --interactive=false --overwrite=true
jf c use loadtest
DOCKERPATH="$DOCKERREG/$DOCKERREPO/"
dockerInstall() {
    randomdockerpkg=$1
    dockertag=`jf rt curl -s -XGET "/api/docker/$DOCKERREPO/v2/$randomdockerpkg/tags/list?n=1" --server-id loadtest | jq -r '.tags[]'`
    dockerfullname=$DOCKERPATH$randomdockerpkg:$dockertag
    # echo jf docker pull `jf c s $SERVERID | grep "JFrog Platform URL:" | awk -F "https://" '{print $2}'`$randomreponame/$randomdockerpkg:$dockert
    echo img pull $dockerfullname
    output=$(img pull "$dockerfullname" 2>&1)
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to download $dockerfullname" | tee -a $logfile
        echo "Failure details: $output"  | tee -a $logfile
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Downloaded $dockerfullname successfully"  | tee -a $logfile
        img rm $dockerfullname
    fi
}

runTests() {
repos=$(jf rt curl -s -XGET /api/docker/$DOCKERREPO/v2/_catalog --server-id loadtest | jq -r '.repositories')
length=$(echo "$repos" | jq length)
if [[ $length -eq 0 ]]; then
    echo "No docker images found"
    exit 1;
fi

for i in $(seq 1 $CONCURRENCY)
do
  random_index=$(( RANDOM % length ))
  randomdocker=$(echo "$repos" | jq -r --argjson index "$random_index" '.[$index]')
  randomdockerpkg=$(echo $randomdocker| awk '{print $1}')
  echo "Random Pkg Type: $randomdockerpkg"
  dockerInstall  $randomdockerpkg &
done
wait

}

logfile="dl-docker_`date +%s`.log"
echo "-------------------------" | tee  $logfile
echo `date` | tee -a $logfile
echo "-------------------------" | tee -a $logfile 
duration=$(($TESTDURATION * 60))
start_time=$(date +%s)
while true; do
    echo "############ Date: $(date)"
    runTests
    # Check if the duration has elapsed
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [ $elapsed_time -ge $duration ]; then
        echo "Job completed." | tee -a $logfile
        jf rt upload "$logfile" $LOGSREPO/ --server-id  loadtest
        break
    fi
done
