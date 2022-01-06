#!/bin/sh

# Credit: https://gist.github.com/rgl/f90ff293d56dbb0a1e0f7e7e89a81f42
while [[ "$(curl -k -s -o /dev/null -w ''%{http_code}'' https://cosmosdb:8081/_explorer/emulator.pem)" != "200" ]]; 
    do sleep 1; 
    echo "Waiting for CosmosDB..."; 
done
