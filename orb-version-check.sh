#!/usr/bin/env bash

set -e

CIRCLE_WORKING_DIRECTORY="${CIRCLE_WORKING_DIRECTORY:-/home/circleci/project}"
CIRCLECI_CONFIG=${CIRCLE_WORKING_DIRECTORY}/.circleci/config.yml

if [ -f "$CIRCLECI_CONFIG" ]
then
  echo "CircleCI config is found @ ${CIRCLECI_CONFIG}!"
else
  echo "CircleCI config not found. Please make sure it is a valid file."
  exit 1
fi

# ensure all dependencies are available
DEPENDENCIES="yq jq curl"
for DEP in $DEPENDENCIES
do
  if [ -z "$(command -v $DEP)" ]; then
    echo "Missing dependency ${DEP}"
    exit 1
  fi
done

function get_latest_orb_version() {
  # $1 follows the "${ORB_NAME}@{VERSION_USED}" pattern
  local ORB_NAME=$(echo $1 | cut -d'@' -f1)
  local VERSION_USED=$(echo $1 | cut -d'@' -f2)

  # generate the GraphQL query needed to confirm what is the latest available version for this orb.
  # @volatile is alias to latest version available for this CircleCI orb
  local CURL_PAYLOAD=$(jq -c --arg ORB $ORB_NAME '.variables.name = $ORB | .variables.orbVersionRef = ($ORB + "@volatile")' curl_payload.json)
  local CURL_RESPONSE=$(curl -s -X POST -H 'Content-Type: application/json' https://circleci.com/graphql-unstable -d "$CURL_PAYLOAD")
  local VERSION_LATEST_AVAILABLE=$(echo $CURL_RESPONSE | jq -r '.data.orbVersion.version')

  # TODO: it is better to use a semver tool to validate if $VERSION_USED is outdated (< $VERSION_LATEST_AVAILABLE)
  if [ "$VERSION_USED" != "$VERSION_LATEST_AVAILABLE" ]; then
    echo "Consider upgrading ${ORB_NAME} version: ${VERSION_USED} -> ${VERSION_LATEST_AVAILABLE}"
    return 1
  fi
}

# Ultimately, the committed repository needs to have a CircleCI config at .circleci/config.yml
# See https://support.circleci.com/hc/en-us/articles/360056463852-Can-I-split-a-config-into-multiple-files-
ORBS=$(yq e -j '.orbs' $CIRCLECI_CONFIG | jq -r 'to_entries | map(.value) | join(" ")')

NUM_OUTDATED=0

# TODO: this assumes all declared orbs are imported;
# This will break for inline orbs.
# See https://circleci.com/docs/2.0/reusing-config/#writing-inline-orbs
for ORB in $ORBS; do
  # $ORB follows the "orb_name@version" pattern
  get_latest_orb_version $ORB
  if [ $? -gt 0 ]
  then
    ((NUM_OUTDATED++))
  fi
done

if [ $NUM_OUTDATED -gt 0 ]
then
  exit 1
else
  echo "All orbs found are using the latest versions available. Nice one, mate!"
fi
