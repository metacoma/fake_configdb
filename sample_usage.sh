#!/bin/sh

component_request_data() {
cat<<EOF
{
  "name": "fuel9.0",
  "resource_definitions": {
    "override/node"                   : {},
    "override/class"                  : {},
    "override/module"                 : {},
    "override/plugins"                : {},
    "override/common"                 : {},
    "override/configuration"          : {},
    "override/configuration/role"     : {},
    "override/configuration/cluster"  : {},
    "class"                           : {},
    "module"                          : {},
    "nodes"                           : {},
    "globals"                         : {},
    "astute"                          : {}
  }
}
EOF
}

ENDPOINT="lit-plateau-85383.herokuapp.com"

component_request_data | curl -X POST -d @- http://${ENDPOINT}/api/v1/config/components
echo
curl http://${ENDPOINT}/api/v1/config/components

exit
#create env
curl -X POST -H 'Content-length: 0' http://localhost:4567/api/v1/config/environment/1
echo
curl -X PUT -H 'Content-length: 18' -d "{'data': 'foobar'}" http://localhost:4567/api/v1/config/environment/1/node/1/resource/foobar
echo
curl http://localhost:4567/api/v1/config/environment/1/node/1/resource/foobar/values

curl -X PUT -H 'Content-length: 18' -d "{'data': 'foobar'}" http://localhost:4567/api/v1/config/environment/1/node/1/resource/nodes
