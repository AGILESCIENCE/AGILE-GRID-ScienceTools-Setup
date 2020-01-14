#!/usr/bin/env bash

trap exit ERR

TAG=v1.0.0

git clone https://github.com/AGILESCIENCE/Agilepy-extra.git
cd Agilepy-extra
git checkout $TAG
cd ..

