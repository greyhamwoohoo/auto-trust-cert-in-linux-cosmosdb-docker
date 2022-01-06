#!/bin/sh
apk add curl

# Credit: https://gist.github.com/rgl/f90ff293d56dbb0a1e0f7e7e89a81f42
timeout 300 /bin/sh "/workspace/scripts/client/wait-for-cosmosdb.sh"

echo ""
echo ""
echo "CosmosDB has started. "
echo ""
echo ""

echo ""
echo ""
echo "Import the certificate so that we trust it"
curl -k https://cosmosdb:8081/_explorer/emulator.pem > /usr/local/share/ca-certificates/emulatorcert.crt
update-ca-certificates
echo ""
echo ""

echo ""
echo ""
echo "This will succeed when accessing CosmosDB through its docker-compose service name because 'cosmosdb' was added as an Alternative Name"
curl https://cosmosdb:8081/_explorer/emulator.pem
echo ""
echo ""

echo ""
echo "DONE: CosmosDB is ready... "
echo ""

sleep 3600
