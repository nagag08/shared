#! /bin/bash

######################
# $ cat diffFile.txt 
# localreponame1
# localreponame2
# remoterepo1
# remoterepo2
# virtualrepo1
# virtualrepo2​
#######################
### sample example: ./repocreate.sh diffFile.txt source-server target-server
### Get Arguments
FILE_NAME="${1:?please provide the file name to parse. ex - diffFile.txt}"
SOURCE_JPD_URL="${2:?please enter JPD - JF Config}"
TARGET_JPD_URL="${3:?please enter JPD - JF Config}"

rm -f *.json
### parse file
while IFS= read -r line; do
        repoadd=$line
        echo -e "\nAdd Repo ==> $repoadd"
        echo -e "Exporting JSON for $repoadd from $SOURCE_JPD_URL"
        # curl -X GET -u "${USER_NAME}":"${AUTH_TOKEN_JPD_1}" "$SOURCE_JPD_URL/artifactory/api/repositories/$repoadd" -s > "$repoadd.tmp.json"
        jf rt curl -X GET --server-id $SOURCE_JPD_URL  "/api/repositories/$repoadd" -s > "$repoadd.json"
        jf rt curl -X PUT --server-id $TARGET_JPD_URL "/api/repositories/$repoadd" -d @"$repoadd.json" -s -H 'Content-Type: application/json'
        echo -e "\n"
done < $FILE_NAME


