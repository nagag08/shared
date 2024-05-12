#! /bin/bash

mkdir -p repos
SOURCE_USERNAME="sourceusername"
SOURCE_PASSWD="mypassword"
TARGET_USERNAME="targetusername"
TARGET_PASSWD="mypassword"
SOURCE_JPD_URL="https://source-artifactory.mycomp.com"
TARGET_JPD_URL="https://target-artifactory.mycomp.com"
## Dont change the default timer. The below schedules replication for all repos 2 minutes apart
max=60
maxhr=24
cronmin=0
mininterval=2
cronhr=0
reset=0

addreplication(){
    repo=$1
    echo -e "\nREPO NAME ==> $repo"
    ##jf rt replication-delete "$repo" --quiet   ## Perform Delete and Create if Required
    echo -e "Creating JSON payload for replicating" $repo
    if [ $cronmin -lt $max -a $cronhr -lt $maxhr ];then
        cronmin=$(( $mininterval + $cronmin))
        if [[ $cronmin -eq $max ]]; then
        cronhr=$(( $cronhr + 1))
        cronmin=$reset
        fi
    elif [[ $cronmin -eq $max ]]; then
        cronhr=$(( $cronhr + 1))
        cronmin=$reset
    elif [[ $cronhr -eq $maxhr ]]; then
        cronhr=$reset
        cronmin=$reset
    fi
    # Creating payload JSON for creating Replication
    echo '[{ "enabled": "true","cronExp":"0 '$cronmin' '$cronhr' * * ?", "syncProperties" : "true", "syncDeletes": "true", "syncStatistics": "true"', > repos/$repo-template.json
    #Insert the remaining parameters, note we're replicating to the same repository name
    echo '"username": "'$TARGET_USERNAME'", "password": "'$TARGET_PASSWD'", "repoKey": "'$repo'","enableEventReplication":"true",' >> repos/$repo-template.json
    echo "\"url\": \"$TARGET_JPD_URL/artifactory/$repo\" }]" >> repos/$repo-template.json
    echo "Adding the Replication"
    #cat  $repo-template.json
    curl -u $SOURCE_USERNAME:$SOURCE_PASSWD -X PUT -s -k "$SOURCE_JPD_URL/artifactory/api/replications/$repo" -d @repos/$repo-template.json -s -H 'Content-Type: application/json'
}

curl -u $SOURCE_USERNAME:$SOURCE_PASSWD -s -k -XGET "$SOURCE_JPD_URL/artifactory/api/repositories?type=local" | jq -r '.[] | .key' > local_source.txt
for art in $(cat local_source.txt);
do
    # echo "Creating Local Repo - $art"
    # curl -u $SOURCE_USERNAME:$SOURCE_PASSWD -s -k "$SOURCE_JPD_URL/artifactory/api/repositories/$art" > repos/$art.json
    # curl -u $TARGET_USERNAME:$TARGET_PASSWD -s -k -X PUT "$TARGET_JPD_URL/artifactory/api/repositories/$art" -d @"repos/$art.json" -s -H 'Content-Type: application/json'
    echo "adding replication"
    addreplication $art
done
