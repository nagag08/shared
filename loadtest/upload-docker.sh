#!/bin/bash
apk add curl jq bash img python3 git
SERVERURL=$(basename $ARTIFACTORY_URL)
img login $SERVERURL -u $ARTIFACTORY_USER -p $ARTIFACTORY_PASSWORD 
curl -fL https://install-cli.jfrog.io | sh
jf c add loadtest --url $ARTIFACTORY_URL --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD --interactive=false --overwrite=true
jf c use loadtest
DOCKERPATH="$DOCKERREG/$DOCKERREPO"
dockerpush() {
    CWD=`pwd`
    msec=$(python3 -c "import time; print(time.time_ns())")
    mkdir -p $CWD/workdir/$msec
    cd $CWD/workdir/$msec
    echo 'FROM alpine' > Dockerfile
    for i in $(seq 1 5)
    do
        echo "LABEL key_$i=\"val_$msec_$i\"" >> Dockerfile
    done
    echo "RUN sh -c echo \"$msec\"">> Dockerfile
    dockerfullname="${DOCKERPATH}/testdocker${msec}:1.0.0"
    img build -t $dockerfullname -f Dockerfile  -d . 
        output=$(img push $dockerfullname 2>&1 1>&-)
        if [ $? -ne 0 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to upload $dockerfullname" | tee -a "$logfile"
            echo "Failure details: $output" >> "$logfile"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Uploaded $dockerfullname successfully" | tee -a $logfile
            img rm $dockerfullname 
        fi
    cd $CWD
    rm -rf $CWD/workdir/$msec
}

runTests() {

for i in $(seq 1 $CONCURRENCY)
do
   dockerpush &
done
wait

}

dockerpath="psemea.jfrog.io/docker-local"
CWD1=`pwd`
logfile="$CWD1/upload-docker_`date +%s`.log"

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
