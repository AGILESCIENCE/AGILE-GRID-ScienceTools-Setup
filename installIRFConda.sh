#!/usr/bin/env bash

trap exit ERR


cd Agilepy-extra/model
make install prefix=$AGILE
cd ../..


