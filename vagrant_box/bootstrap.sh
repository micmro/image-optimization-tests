#!/usr/bin/env bash

#variables
echo "Provision VM START"
echo "==========================================\n\n\n\n"

sudo apt-get update


echo "\n\n>>>>>> install ImageMagick\n\n"
sudo apt-get install -y ImageMagick


#http://blarg.co.uk/blog/how-to-install-mozjpeg
echo "\n\n>>>>>> build and install mozjpeg for lossy compression\n\n"
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
#http://blarg.co.uk/blog/how-to-install-mozjpeg
# sudo make install prefix=/usr/local libdir=/usr/local/lib64
#sudo ln -s /opt/libmozjpeg/bin/jpegtran /usr/local/bin/mozjpeg

echo "\n\n>>>>>> build and install imgmin for lossy compression\n\n"
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


echo "\n\n>>>>>> build and install jpegoptim for lossless compression\n\n"
sudo apt-get install -y libjpeg62
sudo apt-get update
cd /home/vagrant
# wget https://github.com/tjko/jpegoptim/archive/RELEASE.1.4.3.tar.gz
wget https://github.com/tjko/jpegoptim/archive/master.tar.gz
tar -xzf master.tar.gz
rm master.tar.gz
cd jpegoptim-master 
./configure
make
make strip
sudo make install
# apt-get install jpegoptim

#https://www.yireo.com/blog/1559-jpegoptim-wrong-jpeg-library-version
#http://webhostingneeds.com/wrong_jpeg_library_version:_library_is_62,_caller_expects_80
# sudo ln -sv /usr/lib/x86_64-linux-gnu/libjpeg.so.62.0.0 /usr/lib/x86_64-linux-gnu/libjpeg.so.6
# ln -s /usr/bin/bar /opt/foo


#install dssim (PNG only)
echo "\n\n>>>>>> install DSSIM for measurement\n\n"
sudo apt-add-repository -y ppa:lkwg82/dssim
sudo apt-get update
sudo apt-get install dssim

# https://pornel.net/dssim
# dssim file.png file-modified.png
# Will output something like 0.2341. 0 means exactly the same image, >0 (unbounded) is amount of difference.

# dssim -o totally-rad-visualisation.png file.png file-modified.png

#depends on jpegoptim, dssim & mozjpeg to be installed
echo "\n\n>>>>>> install cjpeg-dssim for measurement & optimization\n\n"
mkdir -p ~/bin
wget https://raw.githubusercontent.com/technopagan/cjpeg-dssim/master/cjpeg-dssim -P ~/bin
chmod +x ~/bin/cjpeg-dssim
source ~/.profile


echo "\n\n\n\n>>>>>> ALL DONE\n\n"