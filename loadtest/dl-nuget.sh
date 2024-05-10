#!/bin/sh

apk add dotnet7-sdk curl jq bash 
apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
    apk add --no-cache --virtual=.build-dependencies ca-certificates && \
    cert-sync /etc/ssl/certs/ca-certificates.crt && \
    apk del .build-dependencies
curl -o /usr/local/bin/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
chmod a+x /usr/local/bin/nuget.exe
alias nuget="mono /usr/local/bin/nuget.exe"

SERVERURL=$(basename $ARTIFACTORY_URL)
curl -fL https://install-cli.jfrog.io | sh
jf c add loadtest --url $ARTIFACTORY_URL --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD --interactive=false --overwrite=true
jf c use loadtest

nugetInstall(){
    randomnugetpkg=$1
    jf nuget locals all -clear
    installdir=`python -c 'import time; print(int(time.time() * 1000000))'`
    echo $installdir
    #mkdir -p $installdir
    
    jf nuget install $randomnugetpkg -DependencyVersion ignore -NoHttpCache -o ./$installdir -NonInteractive
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to download $randomnugetpkg" 2>&1  | tee -a $logfile
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Successfully installed nuget pkg $randomnugetpkg" 2>&1  | tee -a $logfile
    fi
    rm -rf ./$installdir
} 

runTests() {
    for i in $(seq 1 $CONCURRENCY)
    do 
      line_count=0
      random_line_number=0
      while IFS= read -r line; do
        line_count=$((line_count + 1))
        random_number=$((RANDOM % line_count))
        if [[ $random_number -eq 0 ]]; then
          random_line_number=$line_count
          random_line="$line"
        fi
      done << EOF 
$nugetpkgs 
EOF

      randomnuget=$random_line 
      randomnugetpkg=`echo $randomnuget| awk '{print $1}'`
      echo $randomnugetpkg
      nugetInstall $randomnugetpkg &
    done
    wait

}
mkdir -p ~/workdir
cd ~/workdir
jf nuget-config --repo-resolve $NUGETREPO --server-id-resolve loadtest
nugetpkgs=$(jf nuget list)

# string=${nugetlist[0]};
if [[ $nugetpkgs =~ "No packages found" ]]; then
    echo "No Nuget Pkgs found"
    exit 1;
fi
logfile="dl-nuget_`date +%s`.log"
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

