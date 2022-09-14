#!/bin/bash

VAULT_PLUGIN_VERSION="0.2.0"
PLUGIN_DIR="vault/plugins"

rm -rf $PLUGIN_DIR
mkdir -p $PLUGIN_DIR
pushd $PLUGIN_DIR || exit

curl --output keycloak-plugin.zip -L https://github.com/Serviceware/vault-plugin-secrets-keycloak/releases/download/v${VAULT_PLUGIN_VERSION}/vault-plugin-secrets-keycloak_${VAULT_PLUGIN_VERSION}_darwin_arm64.zip
unzip keycloak-plugin.zip

rm keycloak-plugin.zip
mv vault-plugin-secrets-keycloak_v0.2.0 keycloak-client-secrets
popd || exit

#vault server -dev -dev-root-token-id=root -dev-plugin-dir=/opt/vault-plugins -dev-listen-address=0.0.0.0:8200