export TAG=BUILD22

git clone git@github.com:AGILESCIENCE/libagilepil.git 
cd libagilepil
git checkout $TAG
cd ..

git clone git@github.com:AGILESCIENCE/libagilewcs.git    
cd libagilewcs
git checkout $TAG
cd ..

git clone git@github.com:ASTRO-EDU/libagilesci.git    
cd libagilesci
git checkout $TAG
cd ..

git clone git@github.com:AGILESCIENCE/agilesci1.git 
cd agilesci1
git checkout $TAG
cd ..

