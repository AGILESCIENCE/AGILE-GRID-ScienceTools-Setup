#!/usr/bin/env bash

trap exit ERR

TAG_IRF=v1.0.0
TAG_SKY=v1.1.0

git clone https://github.com/AGILESCIENCE/AG_IRF.git
cd AG_IRF
git checkout $TAG_IRF
cd ..

git clone https://github.com/AGILESCIENCE/AG_SKY_DISPCONV.git
cd AG_SKY_DISPCONV
git checkout $TAG_SKY
cd ..

