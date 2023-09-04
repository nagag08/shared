# Under development - Procedure is not approved yet

## Clean up of Conan artifactory remote repository 

### Pre-requisites 
1. Install JF CLI and jq
2. configure JF CLI to jfrog artifactory

### How to run 
```
bash conanremote.sh
```
### check if all packages are removed.
```
conan search "zug/0.1.0@" -r myconan

Output
------
Existing packages for recipe zug/0.1.0:

Existing recipe in remote 'myconan':

There are no packages for reference 'zug/0.1.0', but package recipe found.

```
