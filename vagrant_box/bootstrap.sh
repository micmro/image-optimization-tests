#!/usr/bin/env bash

#variables
echo "Provision VM START"
echo "=========================================="

sudo apt-get update


echo ">>>>>> install ImageMagick"
sudo apt-get install -y ImageMagick


echo ">>>>>> build and install mozjpeg for lossy compression"
sudo apt-get install -y autoconf automake libtool nasm gcc
#for TurboJPEG Java wrapper
#sudo apt-get install -y openjdk-7-jdk
sudo apt-get update
cd /home/vagrant
wget https://github.com/mozilla/mozjpeg/releases/download/v3.1/mozjpeg-3.1-release-source.tar.gz
tar -xzf mozjpeg-3.1-release-source.tar.gz
rm mozjpeg-3.1-release-source.tar.gz
cd mozjpeg
./configure
sudo make install prefix=/usr/local libdir=/usr/local/lib64


echo ">>>>>> build and install imgmin for lossy compression"
sudo apt-get install -y autoconf imagemagick libgraphicsmagick1-dev libmagickwand-dev perlmagick apache2-prefork-dev pngnq pngcrush pngquant
sudo apt-get update
cd /home/vagrant
# wget https://github.com/rflynn/imgmin/archive/v1.1.tar.gz
wget https://github.com/micmro/imgmin/archive/d7969f32ee06eb4b717c92d8c43d5a5f2eab4de9.tar.gz -O imgmin_micmro.tar.gz
tar -xzf imgmin_micmro.tar.gz
rm imgmin_micmro.tar.gz
cd imgmin-d7969f32ee06eb4b717c92d8c43d5a5f2eab4de9
autoreconf -fi
./configure
make
sudo make install
# imgmin original.jpg optimized.jpg

#you can use mozjpeg like this
#cjpeg -quality 70 -outfile compressed-image.jpg source-image.png

#http://www.imagemagick.org/script/compare.php
#compare -compose src rose.jpg reconstruct.jpg difference.png


echo ">>>>>> build and install jpegoptim for lossless compression"
sudo apt-get install -y libjpeg62
sudo apt-get update
cd /home/vagrant
# wget https://github.com/tjko/jpegoptim/archive/RELEASE.1.4.3.tar.gz
wget https://github.com/tjko/jpegoptim/archive/master.tar.gz
tar -xzf RELEASE.1.4.3.tar.gz
rm RELEASE.1.4.3.tar.gz
cd jpegoptim-RELEASE.1.4.3
./configure
make
make strip
sudo make install
# apt-get install jpegoptim
# sudo ln -sv /usr/lib/x86_64-linux-gnu/libjpeg.so.62.0.0 /usr/lib/x86_64-linux-gnu/libjpeg.so.6
# ln -s /usr/bin/bar /opt/foo


#install dssim (PNG only)
echo ">>>>>> install DSSIM for measurement"
sudo apt-add-repository -y ppa:lkwg82/dssim
sudo apt-get update
sudo apt-get install dssim

#depends on jpegoptim, dssim & mozjpeg to be installed
echo ">>>>>> install cjpeg-dssim for measurement & optimization"
mkdir -p ~/bin
wget https://raw.githubusercontent.com/technopagan/cjpeg-dssim/master/cjpeg-dssim -P ~/bin
chmod +x ~/bin/cjpeg-dssim
source ~/.profile


echo ">>>>>> ALL DONE"