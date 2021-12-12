#!/bin/sh
apk add curl

# Credit: https://gist.github.com/rgl/f90ff293d56dbb0a1e0f7e7e89a81f42
timeout 300 /bin/sh -c 'while [[ "$(curl -k -s -o /dev/null -w ''%{http_code}'' https://cosmosdb:8081/_explorer/emulator.pem)" != "200" ]]; do sleep 1; echo "Waiting for CosmosDB..."; done'

echo ""
echo ""
echo "CosmosDB has started. "

# https://superuser.com/questions/812664/nslookup-command-line-with-a-record-ip-as-sole-output/812667
COSMOSDBIP=$(nslookup cosmosdb | grep "Address" | awk '{print $2}' | sed -n 2p)

echo ""
echo ""
echo "Import the certificate so that we trust it"
curl -k https://$COSMOSDBIP:8081/_explorer/emulator.pem > /usr/local/share/ca-certificates/emulatorcert.crt
update-ca-certificates

echo ""
echo ""
echo "This will succeed when access CosmosDB through its IP address"
curl https://$COSMOSDBIP:8081/_explorer/emulator.pem

echo ""
echo ""
echo "This will succeed when accessing CosmosDB through its docker-compose service name because 'cosmosdb' was added as an Alternative Name"
curl https://cosmosdb:8081/_explorer/emulator.pem

sleep 3600
