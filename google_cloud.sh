#!/usr/bin/env bash
if [ ! -d $HOME/google-cloud-sdk/bin ]; then
    # The install script errors if this directory already exists,
    # but Travis already creates it when we mark it as cached.
    rm -rf $HOME/google-cloud-sdk;
    # The install script is overly verbose, which sometimes causes
    # problems on Travis, so ignore stdout.
    curl https://sdk.cloud.google.com | bash > /dev/null;
fi