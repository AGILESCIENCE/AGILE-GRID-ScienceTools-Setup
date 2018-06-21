#!/usr/bin/env bash

trap exit ERR

#preBUILD25_2
TAG_PIL=v1.0.2
TAG_WCS=v1.0.2
TAG_LIBSCI=v1.5.0
TAG_SCI1=v1.5.0
TAG_AG_EXTSPOT=v1.3.1

git clone https://github.com/AGILESCIENCE/libagilepil.git
cd libagilepil
git checkout $TAG_PIL
cd ..

git clone https://github.com/AGILESCIENCE/libagilewcs.git
cd libagilewcs
git checkout $TAG_WCS
cd ..

git clone https://github.com/ASTRO-EDU/libagilesci.git
cd libagilesci
git checkout $TAG_LIBSCI
cd ..

git clone https://github.com/AGILESCIENCE/agilesci1.git
cd agilesci1
git checkout $TAG_SCI1
cd ..

git clone https://$1@github.com/Leofaber/agextspot-v2.git
cd agextspot-v2
git checkout $TAG_AG_EXTSPOT
cd ..
