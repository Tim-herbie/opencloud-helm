#!/bin/bash
printenv
# replace openCloud domain in keycloak realm import
mkdir -p /opt/keycloak/data/import

# Replace domain in the realm configuration
sed -e "s/cloud.opencloud.test/${OC_DOMAIN}/g" /opt/keycloak/data/import-dist/openCloud-realm.json > /opt/keycloak/data/import/openCloud-realm.json

# run original docker-entrypoint
/opt/keycloak/bin/kc.sh "$@"
