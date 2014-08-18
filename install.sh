### check DPS environmental variables ###
if [ -z "$AGILE" ] || [ -z $(env | grep AGILE) ]; then
  	echo "AGILE environmental variable not set. Abort."
	exit
fi
if [ -z "$CFITSIO" ] || [ -z $(env | grep CFITSIO) ]; then
        echo "CFITSIO environmental variable not set. Abort."
	exit
fi
if [ -z "$ROOTSYS" ] || [ -z $(env | grep ROOTSYS) ]; then
        echo "ROOTSYS environmental variable not set. Abort."
	exit
fi

cd libagilepil
make install prefix=$AGILE
cd ..

cd libagilewcs
make install prefix=$AGILE
cd ..

cd libagilesci
make install prefix=$AGILE
cd ..

cd agilesci1
make install prefix=$AGILE
cd ..

cp profile $AGILE

echo "install scripts"
mkdir $AGILE/scripts

cp -rf scripts/* $AGILE/scripts
