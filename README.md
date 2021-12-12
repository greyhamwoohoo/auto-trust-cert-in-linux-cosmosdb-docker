# The problem
The Azure Cosmos Emulator for Linux creates a new certificate every time it is started; and by default the certificate is only configured to use IP addresses for its alternative names (no DNS). Therefore, we cannot directly access https://cosmosdb:8081 from another container even if that container trusts the certificate. Some languages - such as Node via the NODE_TLS_REJECT_UNAUTHORIZED environment variable - can disable TLS verification; and other languages - such as .Net - can do it via modifying the verification by providing a callback handler - which needs access to the code. However: it is better to resolve these issues at the infrastructure level. 

# The solution
The solution is quite straight forward: there are four things we need to do:

## CosmosDB Emulator Container
There is one problem the CosmosDB Container must solve so that clients in the same docker-compose can access it via its service name: 

1. We need to provide the name of the CosmosDB service in docker-compose via the AZURE_COSMOS_EMULATOR_ARGS environment variable when we start docker-compose. Thats all!

## CosmosDb Clients in other containers
There are three problems CosmosDB Clients in the same docker-compose must solve if they want to access CosmosDB by its container IP:

1. They must wait for CosmosDB to be ready. This is indicated by the availability of the certificate from the CosmosDB URL. We need to use a tool such as ```curl --insecure``` to poll the availability of the certificate because we cannot trust the certificate until it exists. Therefore, this must happen as early as possible during container initialization.
2. They must trust the CosmosDB SSL certificate. 
3. They must access the CosmosDB instance via its DNS/docker-compose service name

# Example
An example is included - just:

```
docker-compose up
```

The ```scripts``` folder is mounted in the CosmosDB Client and contains the waiting and certificate trusting logic. 

# Musing: View generated certificate
To view the CosmosDB certificate, its settings, alternative names and so forth, execute this from the *HOST* machine, after the docker-compose is:

```
curl --insecure https://localhost:18081/_explorer/emulator.pem > emulator.crt
openssl x509 -in emulator.crt -text -noout
```

# Musing: View entrypoint script
The CosmosDb entrypoint is currently ```start.sh``` and can be viewed like this:

```
# Find THEID
docker container ls

docker exec THEID cat /usr/local/bin/cosmos/start.sh
```

This repository is based on the PREVIEW version - so this solution is likely brittle. Ideally, it would be possible to add extra /alternativenames using a specific environment variable but there is no way currently. 

# References
| Link | Reference | 
| ---- | --------- |
| https://docs.microsoft.com/en-us/azure/cosmos-db/linux-emulator?tabs=ssl-netstd21 | In particular: ..."can also be used for signaling when the emulator endpoint is ready" |
| https://mcr.microsoft.com/v2/cosmosdb/linux/azure-cosmos-emulator/tags/list | View the tags for the Linux Cosmos Emulator |
