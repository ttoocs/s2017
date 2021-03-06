#!/bin/bash

updateSub(){
  git submodule init ./
  git submodule update --remote ./
}


##the  actual run/setup command.
RUN(){
sudo sh $MASTERDIR/setup/pacman.sh

echo "Apacman"
cd /tmp
curl -O "https://raw.githubusercontent.com/oshazard/apacman/master/apacman"
sudo bash ./apacman -S apacman --noconfirm
apacman -S apacman-deps --noconfirm

echo "Flann"
cd $MASTERDIR
cd setup/flann			#Use local files to get it.
makepkg -s -i -C -f
#apacman -S flann --noconfirm  #Use Apacman to get it

echo "G2o"
cd $MASTERDIR
cd setup/g2o
makepkg -s -i	-C -f

#echo "G2O (for ER)"
#apacman -S g2o-git --noconfirm                                                                                                                      

echo "Openni (needed for PCL to build stuff properly.)"
apacman -S openni --noconfirm

echo "OpenNI2"
cd $MASTERDIR
cd OpenNI2
updateSub
git checkout devmerge
cd aur
makepkg -s -i -f -C

echo "LibFreenect2"
cd $MASTERDIR
cd libfreenect2
updateSub
cd aur
makepkg -s -i -f -C


echo "PCL"
cd $MASTERDIR
cd setup/pcl
makepkg -s -i -f -C

echo "ER"
cd $MASTERDIR
cd er
updateSub
git checkout master
mkdir build
cd build
cmake ../
make -j $NUMCPUS

cd $MASTERDIR

echo "Note: see remark at bottom of readme.md."
}


MASTERDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../"

#Setup CCache
PATH="/usr/lib/ccache/bin/:$PATH"

NUMCPUS=`nproc`
if [ "$NUMCPUS" == "" ]; then
  NUMCPUS=4
fi

if [ "$1" == "RUN" ]; then
	RUN
	exit
fi

echo "Fix git randomly dropping directories or submodules or something.."
cd $MASTERDIR
(
BRANCH=`git rev-parse --abbrev-ref HEAD`
git checkout $BRANCH
git pull
sh $MASTERDIR/setup/setup.sh RUN
)
