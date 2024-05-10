#!/bin/bash
apk add curl jq python3
curl -fL https://install-cli.jfrog.io | sh
jf c add loadtest --url $ARTIFACTORY_URL --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD --interactive=false --overwrite=true
jf c use loadtest

uploadfiles() {
parallelC="upload"
CWD=`pwd`
dirname="$(python3 -c "import time; print(time.time_ns())")_$parallelC"
#echo $dirname
mkdir $CWD/$dirname
cd $CWD/$dirname
for i in $(seq 1 $CONCURRENCY)
do
    fname="$(python3 -c "import time; print(time.time_ns())")_fname_$i"
    echo $fname > $fname.data
    if [[ "$USEJFCLI" == "false" ]]; then
       curl -u $ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD -X PUT "$ARTIFACTORY_URL/artifactory/$GENERICREPO/$dirname/$fname.data" -o /dev/null -s -w "%{http_code} - %{URL} -  %{errormsg} \n" &
    fi
done
wait
echo "use jfcli $USEJFCLI"
# ls
cd $CWD
if [[ "$USEJFCLI" == "true" ]]; then
  jf rt u $dirname/ $GENERICREPO --threads $CONCURRENCY --server-id loadtest
fi
}
logfile="upload-generic_`date +%s`.log"
echo "-------------------------" | tee  $logfile
echo `date` | tee -a $logfile
echo "-------------------------" | tee -a $logfile 

runTests (){
    # for $i in $(seq 1 $CONCURRENCY);
    # do
          echo "Uploading files with Thread count $CONCURRENCY" | tee -a $logfile
          echo "Return Status: `uploadfiles`" | tee -a $logfile
    # done
}
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
