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

git clone https://github.com/AGILESCIENCE/libagilepil.git 
cd libagilepil
#git checkout v1.0.0
make install prefix=$AGILE
cd ..

git clone https://github.com/AGILESCIENCE/libagilewcs.git    
cd libagilewcs
#git checkout v1.0.0
make install prefix=$AGILE
cd ..

git clone https://github.com/AGILESCIENCE/libagilesci.git    
cd libagilesci
#git checkout v1.0.0
make install prefix=$AGILE
cd ..

git clone https://github.com/AGILESCIENCE/agilesci1.git 
cd agilesci1
make install prefix=$AGILE
cd ..


