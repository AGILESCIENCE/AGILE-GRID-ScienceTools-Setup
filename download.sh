#!/usr/bin/env bash

trap exit ERR

## BUILD23 ##
TAG_PIL=v1.0.1
TAG_WCS=v1.0.1
TAG_LIBSCI=v1.2.0
TAG_SCI1=v1.1.0

git clone git@github.com:AGILESCIENCE/libagilepil.git 
cd libagilepil
git checkout $TAG_PIL
cd ..

git clone git@github.com:AGILESCIENCE/libagilewcs.git    
cd libagilewcs
git checkout $TAG_WCS
cd ..

git clone git@github.com:ASTRO-EDU/libagilesci.git    
cd libagilesci
git checkout $TAG_LIBSCI
cd ..

git clone git@github.com:AGILESCIENCE/agilesci1.git 
cd agilesci1
git checkout $TAG_SCI1
cd ..
