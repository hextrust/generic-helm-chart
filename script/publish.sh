#!/bin/bash

usage() {
    if [[ -z "$1" ]]; then
        # General usage message 
        echo "Please provide PACKAGE_REGISTRY_USER and PACKAGE_REGISTRY_PASSWORD"
    else
        echo "$1"
    fi
    exit 1
}

echo "$0"
PACKAGE_REGISTRY_USER="${PACKAGE_REGISTRY_USER}"
PACKAGE_REGISTRY_PASSWORD="${PACKAGE_REGISTRY_PASSWORD}"
[[ ! -z "${PACKAGE_REGISTRY_USER}" ]] || usage
[[ ! -z "${PACKAGE_REGISTRY_PASSWORD}" ]] || usage

echo "Packaging helm chart..."
VERSION=$(cut -d ":" -f2 <<< $(helm show chart .|grep version))
helm package .
PACKAGE=$(ls | grep -i "^generic-helm-chart-$VERSION.*tgz$")
[[ ! -z "${PACKAGE}" ]] || usage "Helm package not found, exit 1"

echo "Uploading helm chart..."
RESP=$(curl --request POST --form "chart=@${PACKAGE}" --user $PACKAGE_REGISTRY_USER:$PACKAGE_REGISTRY_PASSWORD https://gitlab.int.hextech.io/api/v4/projects/645/packages/helm/api/stable/charts)
echo $RESP
if [[ $RESP == *"20"* ]]; then
    echo "Upload succeed"
else
    usage "Upload failed, exit 1"
fi