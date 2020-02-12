#!/usr/bin/env bash

trap exit ERR


cd Agilepy-extra
make install prefix=$AGILE
cd ../


