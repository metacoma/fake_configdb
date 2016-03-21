#!/bin/sh



#create env
curl -X POST -H 'Content-length: 0' http://localhost:4567/api/v1/config/environment/1
echo
curl -X PUT -H 'Content-length: 18' -d "{'data': 'foobar'}" http://localhost:4567/api/v1/config/environment/1/node/1/resource/foobar
echo
curl http://localhost:4567/api/v1/config/environment/1/node/1/resource/foobar/values

curl -X PUT -H 'Content-length: 18' -d "{'data': 'foobar'}" http://localhost:4567/api/v1/config/environment/1/node/1/resource/nodes
