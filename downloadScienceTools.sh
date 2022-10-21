#!/usr/bin/env bash
#First parameter: git username

trap exit ERR

TAG_PIL=v1.0.4
TAG_WCS=v1.0.4
TAG_LIBSCI=v2.2.0
TAG_SCI1=v2.2.0
TAG_SCRIPTS=v2.5.6
TAG_AG_EXTSPOT=v1.4.2
TAG_EM=v1.4.1
TAG_WTOOLS=v2.1.0

git clone https://github.com/AGILESCIENCE/libagilepil.git
cd libagilepil
git checkout $TAG_PIL
cd ..

git clone https://github.com/AGILESCIENCE/libagilewcs.git
cd libagilewcs
git checkout $TAG_WCS
cd ..

git clone https://github.com/AGILESCIENCE/libagilesci.git
cd libagilesci
git checkout $TAG_LIBSCI
cd ..

git clone https://github.com/AGILESCIENCE/agilesci1.git
cd agilesci1
git checkout $TAG_SCI1
cd ..

git clone https://github.com/AGILESCIENCE/AGILE-GRID-scripts.git
cd AGILE-GRID-scripts
git checkout $TAG_SCRIPTS
cd ..

git clone https://github.com/AGILESCIENCE/agextspot-v2.git
cd agextspot-v2
git checkout $TAG_AG_EXTSPOT
cd ..

git clone https://github.com/AGILESCIENCE/EllipseMatching.git
cd EllipseMatching
git checkout $TAG_EM
cd ..

git clone https://github.com/AGILESCIENCE/WTOOLS.git
cd WTOOLS
git checkout $TAG_WTOOLS
cd ..
