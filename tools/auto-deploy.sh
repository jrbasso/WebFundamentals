#!/bin/bash
# fail on errors
set -e

CLOUDSDK_URL=https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
SDK_DIR=google-cloud-sdk

# deploy only master builds
if [ "$TRAVIS_BRANCH" != "material-branch" ] || [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Skip deploy."
  exit 0
fi

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_PYTHON_SITEPACKAGES=1

if [ ! -d $SDK_DIR ]; then
  mkdir -p $SDK_DIR
  curl -o /tmp/gcloud.tar.gz $CLOUDSDK_URL
  tar xzf /tmp/gcloud.tar.gz --strip 1 -C $SDK_DIR
  $SDK_DIR/install.sh
fi

openssl aes-256-cbc -d -k $KEY_PASSPHRASE \
        -in tools/web-central-44673aab0806.json.enc \
        -out tools/web-central-44673aab0806.json

$SDK_DIR/bin/gcloud components update gae-python -q
$SDK_DIR/bin/gcloud auth activate-service-account $SERVICE_ACCOUNT \
        --key-file tools/web-central-44673aab0806.json \
        --quiet
$SDK_DIR/bin/gcloud config set project web-central

# The gcloud API was updated for app engine updates and this reverts back to the old SDK behaviour
# We do this as the new behaviour doesn't work for our content :(
$SDK_DIR/bin/gcloud config set app/use_appengine_api false

$SDK_DIR/bin/gcloud --verbosity info preview app deploy --version material ./build/app.yaml
