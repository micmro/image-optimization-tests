#!/usr/bin/env bash

#variables
echo "Provision VM START"
echo "=========================================="
echo ""

sudo apt-get update


echo ">>>>>> install ImageMagick"
sudo apt-get install -y ImageMagick


echo ">>>>>> install Adobe ICC colour profiles for conversion"
cd /home/vagrant
wget ftp://ftp.adobe.com/pub/adobe/iccprofiles/linux/AdobeColorProfiles-end-user.rpm.tar.gz
tar -xzf AdobeColorProfiles-end-user.rpm.tar.gz
rm AdobeColorProfiles-end-user.rpm.tar.gz
sudo apt-get install alien
sudo alien --to-deb adobe-color-profiles-1.0-1.noarch.rpm
sudo dpkg -i adobe-color-profiles_1.0-2_all.deb
#mkdir /usr/share/color/icc
#/usr/share/color/icc/Adobe ICC Profiles/
#http://download.adobe.com/pub/adobe/iccprofiles/win/AdobeICCProfiles.zip


#http://blarg.co.uk/blog/how-to-install-mozjpeg
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
#http://blarg.co.uk/blog/how-to-install-mozjpeg
# sudo make install prefix=/usr/local libdir=/usr/local/lib64
sudo make install
#install as mozjpeg
# sudo ln -s /opt/mozjpeg/bin/ /usr/local/bin/mozjpeg
# sudo unlink /usr/local/bin/mozjpeg
sudo ln -s /opt/mozjpeg/bin/cjpeg /usr/local/bin/mozcjpeg
sudo ln -s /opt/mozjpeg/bin/jpegtran /usr/local/bin/mozjpegtran


echo ">>>>>> build and install imgmin for lossy compression"
sudo apt-get install -y autoconf imagemagick libgraphicsmagick1-dev libmagickwand-dev perlmagick apache2-prefork-dev pngnq pngcrush pngquant
sudo apt-get update
cd /home/vagrant
# wget https://github.com/rflynn/imgmin/archive/v1.1.tar.gz
wget https://github.com/rflynn/imgmin/archive/ea2b77c654421f7ae0da8e537829b16b810e8941.tar.gz -O imgmin.tar.gz
tar -xzf imgmin.tar.gz
rm imgmin.tar.gz
cd imgmin-ea2b77c654421f7ae0da8e537829b16b810e8941
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
echo ">>>>>> install DSSIM for measurement"
sudo apt-get install -y libpng12-0
# sudo apt-add-repository -y ppa:lkwg82/dssim
# sudo apt-get update
# sudo apt-get install -y dssim

cd /home/vagrant
wget https://github.com/pornel/dssim/archive/1.1.1.tar.gz
tar -xzf 1.1.1.tar.gz
rm 1.1.1.tar.gz
cd dssim-1.1.1
make
mkdir -p /home/vagrant/bin
cp ./bin/dssim /home/vagrant/bin
chmod +x /home/vagrant/bin/dssim
source ~/.profile

# https://pornel.net/dssim
# dssim file.png file-modified.png
# Will output something like 0.2341. 0 means exactly the same image, >0 (unbounded) is amount of difference.

#depends on jpegoptim, dssim & mozjpeg to be installed
echo ">>>>>> install cjpeg-dssim for measurement & optimization"
mkdir -p /home/vagrant/bin
#use local modified csjepg-dssim
# wget https://raw.githubusercontent.com/technopagan/cjpeg-dssim/master/cjpeg-dssim -P /home/vagrant/bin
# chmod +x /home/vagrant/bin/cjpeg-dssim
chmod +x /vagrant_shared/cjpeg-dssim
sudo ln -s /vagrant_shared/cjpeg-dssim /home/vagrant/bin/cjpeg-dssim
source ~/.profile

echo ""
echo ""
echo ">>>>>> ALL DONE"