#!/usr/bin/env bash

trap exit ERR

## preBUILD24_1 ##
TAG_PIL=v1.0.2
TAG_WCS=v1.0.2
TAG_LIBSCI=v1.4.0
TAG_SCI1=v1.4.0

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
