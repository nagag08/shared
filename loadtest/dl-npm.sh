#!/bin/sh

apk add nodejs npm curl jq bash 
SERVERURL=$(basename $ARTIFACTORY_URL)
curl -fL https://install-cli.jfrog.io | sh
jf c add loadtest --url $ARTIFACTORY_URL --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD --interactive=false --overwrite=true
jf c use loadtest
npm install -g npm-cli-login
# jf npm-config --repo-resolve $NPMREPO --server-id-resolve loadtest
npmreg="${ARTIFACTORY_URL}/artifactory/api/npm/${NPMREPO}"
npm-cli-login -u $ARTIFACTORY_USER -p $ARTIFACTORY_PASSWORD -e test@example.com -r $npmreg
npm config set registry $npmreg
npm config set email test@example.com
getrandomjsonarray() {
json_array=`cat $1 |  tr '\n' '\0' | jq -R '. | split("\u0000")'`
num_random_elements=$2

array_length=$(echo "$json_array" | jq length)
for  i in $(seq 1 $num_random_elements); do
    random_index=$((RANDOM % array_length))
    random_element=$(echo "$json_array" | jq -r --argjson index "$random_index" '.[$index]')
    echo "$random_element "| tr '\n' '\0'
done
}
getrandompkgs() {
specfilename="npm.spec"
cat >./$specfilename << EOL
{
  "files": [
    {
      "aql": {
        "items.find": {
          "repo": {"$match": "${NPMREPO}*"},
          "name": "package.json"
        }
      }
    }
  ]
}
EOL
npmpkglist=$(jf rt s --spec npm.spec | jq '[.[].path]')
length=$(echo "$npmpkglist" | jq length)
if [[ $length -eq 0 ]]; then
    echo "No npm images found"
    exit 1;
fi
for i in $(seq 1 $CONCURRENCY)
do
    random_index=$(( RANDOM % length ))
    randompkg=$(echo "$npmpkglist" | jq -r --argjson index "$random_index" '.[$index]'| sed 's/.*\.npm\/\(.*\)\/package\.json/\1/')
    echo $randompkg
    #npm view $randompkg versions -r $npmreg --json | jq -r --arg pkgname "${randompkg}@" '$pkgname+.[]'
done
}

runTests() {
    randompkglistfile='randompkglist.json'
    getrandompkgs  > $randompkglistfile
    randomnpmpkgs=$(getrandomjsonarray $randompkglistfile $CONCURRENCY)
    npm install -g $randomnpmpkgs --loglevel verbose --registry  $npmreg 2>&1  | tee -a $logfile
}

logfile="dl-npm_`date +%s`.log"
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

