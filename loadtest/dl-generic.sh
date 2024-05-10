#!/bin/bash
apk add curl jq bash
curl -fL https://install-cli.jfrog.io | sh
jf c add loadtest --url $ARTIFACTORY_URL --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD --interactive=false --overwrite=true
jf c use loadtest

pullfiles() {
specfilename="specfile.spec"
cat >./$specfilename << EOL
{
  "files": [
    {
      "aql": {
        "items.find": {
          "repo": "$GENERICREPO",
          "path": {"\$match": "*"},
          "size": {"\$lt": 9999},
          "name": {"\$match": "*"}
        }
      }
    }
  ]
}
EOL
if [[ "$USEJFCLI" == "true" ]]; then
  length=$(jf rt s --spec $specfilename | jq "[.[].path]|length")
  dloffset=$(( RANDOM % length ))
  jf rt dl --spec=$specfilename --threads $CONCURRENCY --server-id loadtest --limit $CONCURRENCY --offset $dloffset --detailed-summary --quiet| jq 'del(.files)'
else
  fileslist=$(jf rt s --spec=$specfilename  --server-id loadtest | jq '[.[].path]')
  length=$(echo "$fileslist" | jq length)
  if [[ $length -eq 0 ]]; then
      echo "No docker images found"
      exit 1;
  fi
  for i in $(seq 1 $CONCURRENCY);
  do
    random_index=$(( RANDOM % length ))
    filename=$(echo "$fileslist" | jq -r --argjson index "$random_index" '.[$index]')
    curl -u $ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD "$ARTIFACTORY_URL/artifactory/$filename" -s -o /dev/null -w "%{http_code} - %{URL} -  %{errormsg} \n" &
  done
  wait
fi
}
logfile="dl-generic_`date +%s`.log"
echo "-------------------------" | tee  $logfile
echo `date` | tee -a $logfile
echo "-------------------------" | tee -a $logfile 

runTests (){
    #for reponame in $(jf rt curl -s -XGET '/api/repositories?type=local&packageType=generic' --server-id  loadtest | jq -r '.[] | .key');
    #  do
    #      echo "Downloading files from $reponame with Thread count $CONCURRENCY" | tee -a $logfile
    #      echo "Return Status: `pullfiles $reponame`" | tee -a $logfile
    #  done
    echo "Downloading files from $GENERICREPO with Thread count $CONCURRENCY" | tee -a $logfile
    echo "Return Status: `pullfiles`" | tee -a $logfile
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
