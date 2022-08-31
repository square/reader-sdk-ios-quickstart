#!/bin/bash
set -ex

source "$HOME/.rvm/scripts/rvm"

# Set the version of SquareReaderSDK to download
VERSION="1.6.1"
APP_ID="REPLACE_ME"
REPO_PASSWORD="REPLACE_ME"

echo "version is: $VERSION"

# Switch to cwd to the location of this script.
pushd $(dirname "$0")

# Use a cache directory adjacent to this script.
CACHE_DIR="/var/tmp/SquareReaderSDK/Cache"

# Create base cache directory, if it does not exist.
mkdir -p "$CACHE_DIR"

# Download Location
DOWNLOAD_LOCATION="$CACHE_DIR/$VERSION"

FRAMEWORK="$DOWNLOAD_LOCATION/SquareReaderSDK.xcframework"

# Download the SquareReader artifact, if necessary.
if [ -d $FRAMEWORK ]; then
    echo "Download for SquareReader $VERSION exists, skipping download"
else
    ruby <(curl https://connect.squareup.com/readersdk-installer) install -v $VERSION \
        --app-id $APP_ID \
        --repo-password $REPO_PASSWORD \
        --installation-dir "$DOWNLOAD_LOCATION"
fi

ln -sf "$DOWNLOAD_LOCATION/SquareReaderSDK.xcframework" $(pwd)

popd
