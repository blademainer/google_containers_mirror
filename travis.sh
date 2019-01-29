#!/usr/bin/env bash
args="$1"
docker run --rm -it -v $(pwd):/project skandyla/travis-cli $args

