#! /bin/bash
 
#Get Arguments
SOURCE_ID="${1:?Enter artifactory server ID}"
REPO_NAME="${2:?Enter repo name}"
NO_DAYS="${3:?number of days older}"
TOP_FILES=50
# jf rt curl -s -XPOST -H 'Content-Type: text/plain' api/search/aql --server-id $SOURCE_ID --data "items.find({\"repo\": \"$REPO_NAME\"},{\"modified\" : {\"\$last\" : \"${NO_DAYS}d\"}}).include(\"repo\",\"path\",\"name\",\"size\").sort({\"\$desc\":[\"size\",\"name\"]}).limit($TOP_FILES)" | jq -r '.results[]|(.path +"/"+ .name+","+(.size|tostring))' | sed -e 's/,,/, ,/g' | column -s, -t

output=""
for  path in $(jf rt curl -s -XPOST -H 'Content-Type: text/plain' api/search/aql --server-id $SOURCE_ID --data "items.find({\"repo\": \"$REPO_NAME\"},{\"name\": \"manifest.json\"},{\"modified\" : {\"\$last\" : \"${NO_DAYS}d\"}}).include(\"path\")" | jq -r '.results[]|.path')
do
   SIZE=$(jf rt curl -s -XPOST  -H 'Content-Type: text/plain' api/search/aql --server-id $SOURCE_ID --data "items.find({\"repo\": \"$REPO_NAME\"},{\"path\": \"$path\"})" | jq '.results|map(.size)|add')
   output+="$SIZE - $path \n"
done
echo -e $output | sort -nr 
