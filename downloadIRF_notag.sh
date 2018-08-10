#!/usr/bin/env bash

trap exit ERR

#TAG_IRF=
#TAG_SKY=

git clone https://github.com/AGILESCIENCE/AG_IRF.git
cd AG_IRF/H0025
#git checkout $TAG_IRF
make install prefix=$AGILE/model/scientific_analysis/data/
cd ../..

cd AG_IRF/I0025
make install prefix=$AGILE/model/scientific_analysis/data/
cd ../..

git clone https://github.com/AGILESCIENCE/AG_SKY_DISPCONV.git
cd AG_SKY_DISPCONV/SKY002_I0025
#git checkout $TAG_SKY
make install prefix=$AGILE/model/scientific_analysis/data/
cd ../..
cd AG_SKY_DISPCONV/SKY002_H0025
make install prefix=$AGILE/model/scientific_analysis/data/
cd ../..

