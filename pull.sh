#!/bin/sh
git submodule foreach --quiet git fetch
git submodule foreach git checkout -f origin/master
