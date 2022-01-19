#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART_DIR=$(cd "${MODULE_DIR}/chart/ibmcpd"; pwd -P)

NAME="$1"
DEST_DIR="$2"
VALUES_FILE="$3"

mkdir -p "${DEST_DIR}"

## Add logic here to put the yaml resource content in DEST_DIR

cp -R "${CHART_DIR}"/* "${DEST_DIR}"

echo "${VALUES_CONTENT}" > "${DEST_DIR}/${VALUES_FILE}"

find "${DEST_DIR}" -name "*"