#!/bin/bash

set -e


CHUB_URI=https://api.hub.confluent.io/api/plugins
CHUB_PKG="$1"
CHUB_PKG_VERSION="$2"
CHUB_URI="$CHUB_URI/$CHUB_PKG/versions/$CHUB_PKG_VERSION"
CHUB_FILE=$(mktemp)
curl -fSL -o "$CHUB_FILE" \
  $( curl --stderr /dev/null "$CHUB_URI" \
    | sed -rn \
    's/.*("archive":.*)/\1/; s/(("url":"([^"]*)".*)*.)*/\3/p' \
  )
mv "$CHUB_FILE" "$CHUB_DEP_DESTINATION"
unzip "$CHUB_DEP_DESTINATION/${CHUB_FILE##*/}"
rm "$CHUB_DEP_DESTINATION/${CHUB_FILE##*/}"

