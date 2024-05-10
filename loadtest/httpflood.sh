#!/bin/bash
apk add curl jq bash
curl -fL https://install-cli.jfrog.io | sh
jf c add loadtest --url $ARTIFACTORY_URL --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD --interactive=false --overwrite=true
jf c use loadtest

cat > curlcmds.txt <<- EOM
url=$ARTIFACTORY_URL/artifactory/api/system/ping
url=$ARTIFACTORY_URL/artifactory/api/build
url=$ARTIFACTORY_URL/artifactory/api/storageinfo
url=$ARTIFACTORY_URL/artifactory/api/v1/system/liveness
url=$ARTIFACTORY_URL/access/api/v1/system/ping
url=$ARTIFACTORY_URL/mc/api/v1/system/ping
url=$ARTIFACTORY_URL/xray/api/v1/system/ping
url=$ARTIFACTORY_URL/distribution/api/v1/system/info
url=$ARTIFACTORY_URL/artifactory/api/security/users
url=$ARTIFACTORY_URL/artifactory/api/security/lockedUsers
url=$ARTIFACTORY_URL/artifactory/api/security/userLockPolicy
url=$ARTIFACTORY_URL/artifactory/api/security/configuration/passwordExpirationPolicy
url=$ARTIFACTORY_URL/artifactory/api/security/encryptedPassword
url=$ARTIFACTORY_URL/artifactory/api/repositories
url=$ARTIFACTORY_URL/artifactory/api/release/bundles
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&bower
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&cargo
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&chef
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&cocoapods
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&composer
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&conan
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&cran
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&debian
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&docker
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&gems
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&gitlfs
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&go
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&gradle
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&helm
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&ivy
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&maven
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&nuget
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&opkg
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&p2
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&pub
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&puppet
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&pypi
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&rpm
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&sbt
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&swift
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&terraform
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&vagrant
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&yum
url=$ARTIFACTORY_URL/artifactory/api/repositories?local&generic
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&bower
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&cargo
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&chef
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&cocoapods
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&composer
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&conan
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&cran
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&debian
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&docker
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&gems
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&gitlfs
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&go
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&gradle
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&helm
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&ivy
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&maven
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&nuget
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&opkg
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&p2
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&pub
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&puppet
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&pypi
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&rpm
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&sbt
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&swift
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&terraform
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&vagrant
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&yum
url=$ARTIFACTORY_URL/artifactory/api/repositories?remote&generic
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&bower
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&cargo
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&chef
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&cocoapods
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&composer
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&conan
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&cran
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&debian
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&docker
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&gems
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&gitlfs
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&go
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&gradle
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&helm
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&ivy
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&maven
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&nuget
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&opkg
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&p2
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&pub
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&puppet
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&pypi
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&rpm
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&sbt
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&swift
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&terraform
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&vagrant
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&yum
url=$ARTIFACTORY_URL/artifactory/api/repositories?virtual&generic
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&bower
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&cargo
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&chef
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&cocoapods
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&composer
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&conan
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&cran
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&debian
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&docker
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&gems
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&gitlfs
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&go
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&gradle
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&helm
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&ivy
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&maven
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&nuget
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&opkg
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&p2
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&pub
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&puppet
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&pypi
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&rpm
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&sbt
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&swift
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&terraform
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&vagrant
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&yum
url=$ARTIFACTORY_URL/artifactory/api/repositories?federated&generic
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&bower
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&cargo
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&chef
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&cocoapods
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&composer
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&conan
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&cran
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&debian
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&docker
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&gems
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&gitlfs
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&go
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&gradle
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&helm
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&ivy
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&maven
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&nuget
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&opkg
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&p2
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&pub
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&puppet
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&pypi
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&rpm
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&sbt
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&swift
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&terraform
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&vagrant
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&yum
url=$ARTIFACTORY_URL/artifactory/api/repositories?distribution&generic
url=$ARTIFACTORY_URL/artifactory/api/system/logs/config
url=$ARTIFACTORY_URL/artifactory/api/v2/security/permissions
url=$ARTIFACTORY_URL/access/api/v2/users
url=$ARTIFACTORY_URL/router/api/v1/system/health
url=$ARTIFACTORY_URL/access/api/v2/groups
url=$ARTIFACTORY_URL/access/api/v1/cert/root
url=$ARTIFACTORY_URL/access/api/v1/system/federation
url=$ARTIFACTORY_URL/artifactory/api/xrayRepo/getIntegrationConfig
url=$ARTIFACTORY_URL/xray/api/v2/policies
url=$ARTIFACTORY_URL/xray/api/v2/watches
url=$ARTIFACTORY_URL/xray/api/v1/system/version
url=$ARTIFACTORY_URL/distribution/api/v1/system/settings
url=$ARTIFACTORY_URL/distribution/api/v1/system/info
url=$ARTIFACTORY_URL/distribution/api/v1/security/token
url=$ARTIFACTORY_URL/mc/api/v1/jpds"
EOM

runTests() {
curl -s -k -m 10 -u "$ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD"  --parallel --parallel-immediate --parallel-max $CONCURRENCY --config curlcmds.txt -w "\n\nResponse code for URL: %{url} -> %{response_code} -> [Time: %{time_total}ms] -> [errormsg: %{errormsg}]\n\n" | grep "Response code" | tee -a $logfile
}

logfile="httpflood_`date +%s`.log"
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
