#!/bin/sh
git submodule foreach git fetch
git submodule foreach git checkout -f origin/master
