#### Run below command to add the policy
```shell
# Add globally` 
jf xr curl -XPOST -H "Content-Type: application/json" "api/v2/policies" -T owsap.json
# Add to the project
jf xr curl -XPOST -H "Content-Type: application/json" "api/v2/policies?projectKey=proj1" -T owsap.json
```
