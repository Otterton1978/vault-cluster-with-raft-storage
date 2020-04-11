#!/usr/bin/env bash

echo "First Node - Initialise Vault"
INIT_RESPONSE=$(vault operator init -format=json -key-shares=1 -key-threshold=1)

UNSEAL_KEY=$(echo $INIT_RESPONSE | jq -r .unseal_keys_b64[0])
VAULT_TOKEN=$(echo $INIT_RESPONSE | jq -r .root_token)

echo $UNSEAL_KEY
echo $VAULT_TOKEN

echo "Store unseal key and root token in files to be used for other nodes"
echo $INIT_RESPONSE > /vagrant/primary-keys.txt
echo $UNSEAL_KEY > /vagrant/primary-unseal-key.txt
echo $VAULT_TOKEN > /vagrant/primary-root-token.txt

echo "Unseal Vault Started"
vault operator unseal $UNSEAL_KEY
echo "Unseal Vault Completed"
sleep 15s

echo "Print Vault Status"
vault status
#sleep 5s
echo "Check for availability of Active Node"

echo "Login with Root Token"
vault login $VAULT_TOKEN 
echo "Logged-in as Root"
sleep 5s

echo "Print Vault Status and sleep 2s"
vault status 
sleep 5s

echo "Print Raft Status"
vault operator raft list-peers

echo "Vault is initialised and unsealed"

# Update the license information if there is a separate license file
LICENSE_FILE=/vagrant/ent/license.txt

if [ -f "$LICENSE_FILE" ]; then 
    echo "Vault License file exists in the ent folder"

    LICENSE_KEY=$(cat /vagrant/ent/license.txt)
    vault write sys/license text=$LICENSE_KEY

    echo "Updated the license. License details "
    vault read sys/license
fi