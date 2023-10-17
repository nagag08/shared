#!/bin/bash
usage() {
  echo "Unknown options: $1
  Valid option are:
     --sourcerepo - [Mandatory] Repo Name
     --targetrepo - [Mandatory] duration like 1d, 1w, 1mo or 1y
  ex: bash <script> --sourcerepo myconan --targetrepo myconanbkp "
}
while [[ $# -gt 0 ]]; do
 case "$1" in
   --sourcerepo)
     srepo="$2"
     shift 2
     ;;
   --targetrepo)
     trepo="$2"
     shift 2
     ;;
   *)
     usage $1
     exit 1
     ;;
 esac
done

if [ -z "${srepo}" ]; then
   echo "--sourcerepo is unset or set to the empty string"
   usage
   exit 1
fi
if [ -z "${trepo}" ]; then
   echo "--targetrepo is unset or set to the empty string"
   usage
   exit 1
fi

while true; do
read -p "Is [JF CLI] and [jq] installed and configured. Make RT as default? (y/n) " yn

case $yn in
	[yY] ) echo Performing Conan clean up as per criteria;
		break;;
	[nN] ) echo Install [JF CLI] and [jq] and configure to your JPD;
		exit;;
	* ) echo invalid response;;
esac
done


for rem in $(jf rt curl -s -XPOST -H 'Content-Type: text/plain' api/search/aql --data  "items.find({\"repo\":{\"\$eq\":\"$srepo\"}, \"name\":{\"\$eq\":\".timestamp\"}, \"modified\" : {\"\$last\" : \"90d\"}, \"path\": {\"\$match\" : \"*/package/*\"} }).include(\"path\")" | jq -r '.results[].path')
do
    echo jf rt mv --recursive $srepo/$rem $trepo
done
