#!/bin/bash
usage() { 
    echo "Unknown options: $1 
    Valid Script option are: 
    --artifactpath - [Mandatory] full path of artifact. This is same as 'Repository Path:' in Web UI
    ex1: bash <script> --artifactpath my-ldocker/maven/3.8.1-adoptopenjdk-11/manifest.json
    ex2: bash <script> --artifactpath dev-npm-local/metaverse/-/metaverse-0.92.12.tgz"
} 
while [[ $# -gt 0 ]]; do 
    case "$1" in 
        --artifactpath) 
            artifactpath="$2" 
            shift 2 
            ;; 
        *) 
            usage $1 
            exit 1 
            ;; 
    esac 
done 

if [ -z "${artifactpath}" ]; then 
    echo "--artifactpath is unset or set to the empty string" 
    usage 
    exit 1 
fi 
sha256=$(jf xr curl -H 'Content-Type: application/json' -XPOST api/v1/dependencyGraph/artifact -d '{
    "path":"default/'$artifactpath'"
}'  | jq -r '.artifact.sha256')
pkg_type=$(jf xr curl -H 'Content-Type: application/json' -XPOST api/v1/dependencyGraph/artifact -d '{
    "path":"default/'$artifactpath'"
}'  | jq -r '.artifact.pkg_type')
cname=$(jf xr curl -H 'Content-Type: application/json' -XPOST api/v1/dependencyGraph/artifact -d '{
    "path":"default/'$artifactpath'"
}'  | jq -r '.artifact.component_id')
jf xr curl -XPOST api/v1/component/exportDetails \
    -H "Content-type: application/json" \
    -d '{
    "component_name":"'$cname'",
    "package_type":"'$pkg_type'",
    "output_format":"json",
    "spdx":false,
    "cyclonedx":true,
    "violations": true,
    "license": true,
    "security": true,
    "malicious_code": true,
    "iac": true,
    "services": true,
    "applications": true,
    "operational_risk": true,
    "include_ignored_violations": true,
    "malicious_code": true,
    "cyclonedx_format":"json",
    "sha_256":"'$sha256'"
    }' \
    --output artifact-report-$cname-$pkg_type-$sha256.zip
