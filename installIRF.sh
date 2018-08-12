#!/usr/bin/env bash

trap exit ERR


cd AG_IRF/H0025
make install prefix=$AGILE
cd ../..

cd AG_IRF/I0025
make install prefix=$AGILE
cd ../..

cd AG_SKY_DISPCONV/SKY002_I0025
make install prefix=$AGILE
cd ../..

cd AG_SKY_DISPCONV/SKY002_H0025
make install prefix=$AGILE
cd ../..

