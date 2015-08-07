#!/usr/bin/env bash

folderName=optim-test-$(date +%Y%m%d_%H%M%S)
sourceImgName=IMG_3368
optimBase=${sourceImgName}_optim
diffBase=${sourceImgName}_diff

echo ">>>>>> TEST"
echo "\nFolder:$folderName \nSouce:$sourceImgName\n\n"


#make output folder
cd /vagrant_shared/sample-images/
mkdir $folderName
cp ${sourceImgName}.jpg $folderName
cd $folderName

originalFileSize=`du -k "${sourceImgName}.jpg" | cut -f1`
printFileSize () {
	file_size_kb=`du -k $2 | cut -f1`
	file_size_diff=$(expr $originalFileSize - $file_size_kb)
	echo "$1\t\t${file_size_kb}kb (-${file_size_diff}kb)"
}

# file_size_kb=`du -k "${sourceImgName}.jpg" | cut -f1`
# echo "original size\t\t${file_size_kb}kb"
printFileSize "original size" "${sourceImgName}.jpg"

#######################
# Mozjpeg


# cjpegMozJpeg () {
# 	dest_file_name=${optimBase}_mozjpeg_q${1}.jpg
# 	cjpeg -quality ${1} -outfile ${dest_file_name} ${sourceImgName}.jpg
# 	file_size_kb=`du -k "$dest_file_name" | cut -f1`
# 	echo "MozJpeg\t\tq:${1}\t${file_size_kb}kb"
# }
# cjpegMozJpeg 70
# cjpegMozJpeg 80
# cjpegMozJpeg 90


#######################
# jpegOptim

#https://www.yireo.com/blog/1559-jpegoptim-wrong-jpeg-library-version
jpegOptimSrc=${optimBase}_jpegoptim.jpg

cp ${sourceImgName}.jpg $jpegOptimSrc
#jpegoptim ${sourceImgName}.jpg -d ${optimBase}_jpegoptim.jpg -m 95 --strip-all
jpegoptim --strip-all $jpegOptimSrc
printFileSize "jpegoptim" "$jpegOptimSrc"


#######################
# imgmin

#imgmin original.jpg optimized.jpg
# imgminOutput=`imgmin ${sourceImgName}.jpg ${optimBase}_imgmin.jpg`
# file_size_kb=`du -k "${optimBase}_imgmin.jpg" | cut -f1`
# echo "imgmin size\t\t${file_size_kb}kb"
# echo "\n\n"
# echo $imgminOutput

#######################
#cjpeg-dssim


cjpegDssimASrc=${optimBase}_cjpeg-dssim_jpegoptim.jpg

cp ${sourceImgName}.jpg $cjpegDssimASrc
cjpeg-dssim jpegoptim $cjpegDssimASrc
printFileSize "cjpeg-dssim" "$cjpegDssimASrc"
# cp ${sourceImgName}.jpg ${optimBase}_cjpeg-dssim_mozjpeg.jpg
# cjpeg-dssim mozjpeg ${optimBase}_cjpeg-dssim_mozjpeg.jpg


#######################
#######################
# DIFFs

# echo "\nCreate Diffs\n\n"
# #http://www.imagemagick.org/script/compare.php
# compare -compose src ${sourceImgName}.jpg ${optimBase}_mozjpeg_q70.jpg ${diffBase}_mozjpeg_q70.jpg
# compare -compose src ${sourceImgName}.jpg ${optimBase}_mozjpeg_q80.jpg ${diffBase}_mozjpeg_q80.jpg
# compare -compose src ${sourceImgName}.jpg ${optimBase}_mozjpeg_q90.jpg ${diffBase}_mozjpeg_q90.jpg

# compare -compose src ${sourceImgName}.jpg ${optimBase}_jpegoptim.jpg ${diffBase}_jpegoptim.jpg
# compare -compose src ${sourceImgName}.jpg ${optimBase}_imgmin.jpg ${diffBase}_imgmin.jpg
# #compare -compose src rose.jpg reconstruct.jpg difference.png