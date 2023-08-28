for rem in $(jf rt curl -s -XPOST -H 'Content-Type: text/plain' api/search/aql -T aqlbyuploaddate.aql | jq -r '.results[].path')
do
    jf rt del --quiet myconan/$rem
done
