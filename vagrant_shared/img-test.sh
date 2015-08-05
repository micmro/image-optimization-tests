#!/usr/bin/env bash

echo ">>>>>> TEST"
folderName=optim-test-$(date +%Y%m%d_%H%M%S)
sourceImgName=IMG_3368
optimBase=${sourceImgName}_optim
diffBase=${sourceImgName}_diff
echo "\nFolder:$folderName \nSouce:$sourceImgName\n\n"

cd /vagrant_shared/sample-images/
mkdir $folderName
cp ${sourceImgName}.jpg $folderName
cd $folderName


#Mozjpeg
cjpegMozJpeg () {
	dest_file_name=${optimBase}_mozjpeg_q${1}.jpg
	cjpeg -quality ${1} -outfile ${dest_file_name} ${sourceImgName}.jpg
	file_size_kb=`du -k "$dest_file_name" | cut -f1`
	echo "MozJpeg\t\tq:${1}\t${file_size_kb}kb"
}

file_size_kb=`du -k "${sourceImgName}.jpg" | cut -f1`
echo "original size\t\t${file_size_kb}kb"
cjpegMozJpeg 70
cjpegMozJpeg 80
cjpegMozJpeg 90


#https://www.yireo.com/blog/1559-jpegoptim-wrong-jpeg-library-version
jpegoptim ${sourceImgName}.jpg -d ${optimBase}_jpegoptim.jpg -m 95 --strip-all



# #imgmin original.jpg optimized.jpg
# imgminOutput=`imgmin ${sourceImgName}.jpg ${optimBase}_imgmin.jpg`
# file_size_kb=`du -k "${optimBase}_imgmin.jpg" | cut -f1`
# echo "imgmin size\t\t${file_size_kb}kb"
# echo "\n\n"
# echo $imgminOutput

# #cjpeg-dssim jpegoptim /path/to/input-image.jpg
# #cjpeg-dssim jpegoptim /path/to/input-image.jpg


# echo "\nCreate Diffs\n\n"
# #http://www.imagemagick.org/script/compare.php
# compare -compose src ${sourceImgName}.jpg ${optimBase}_mozjpeg_q70.jpg ${diffBase}_mozjpeg_q70.jpg
# compare -compose src ${sourceImgName}.jpg ${optimBase}_mozjpeg_q80.jpg ${diffBase}_mozjpeg_q80.jpg
# compare -compose src ${sourceImgName}.jpg ${optimBase}_mozjpeg_q90.jpg ${diffBase}_mozjpeg_q90.jpg

# compare -compose src ${sourceImgName}.jpg ${optimBase}_imgmin.jpg ${diffBase}_imgmin.jpg
# #compare -compose src rose.jpg reconstruct.jpg difference.png