#!/usr/bin/env bash

folder_name=optim-test-$(date +%Y%m%d_%H%M%S)
source_img_name=original
source_img_file="${source_img_name}.jpg"
optimBase=${source_img_name}_optim
diffBase=${source_img_name}_diff
size_output="\n"

echo ">>>>>> TEST"
echo "\nFolder:$folder_name \nSouce:$source_img_file\n\n"


#make output folder
cd /vagrant_shared/sample-images/
mkdir $folder_name
cp ${source_img_file} $folder_name
cd $folder_name

originalFileSize=`du -k "${source_img_file}" | cut -f1`
convert ${source_img_file} ${source_img_name}.png

printFileSize () {
	file_size_kb=`du -k $2 | cut -f1`
	file_size_diff=$(expr $originalFileSize - $file_size_kb)
	file_size_diff_perc=$(echo "scale=2;(100 * $file_size_diff / $originalFileSize)" | bc -l)

	if [ $2 != $source_img_file ]; then
		convert $2 ${2}.png
		# #print DSSIM of image
		dssim_output=`dssim ${source_img_name}.png ${2}.png`
		rm ${2}.png

		size_output="${size_output}\n$1\t\t${file_size_kb}kb\t(-${file_size_diff}kb\t-${file_size_diff_perc}%)\t${dssim_output}"
	else
		size_output="$size_output\n$1\t\t${file_size_kb}kb"
	fi
}

printFileSize "original size\t" "${source_img_file}"


#######################
# Mozjpeg

cjpegMozJpeg () {
	dest_file=${optimBase}_mozjpeg_q${1}.jpg
	#TODO: readd -quality argument
	#https://github.com/mozilla/mozjpeg/blob/master/usage.txt

	mozcjpeg -outfile "${dest_file}" -quality ${1} "${source_img_file}"
	# mozcjpeg -rgb -optimize "${1}" -outfile ${dest_file} ${source_img_file}
	printFileSize "MozJpeg (q${1})\t" "$dest_file"
}
cjpegMozJpeg 70
cjpegMozJpeg 80
cjpegMozJpeg 90

# Libraries have been installed in:
# ==> default:    /opt/mozjpeg/lib64
# ==> default: If you ever happen to want to link against installed libraries
# ==> default: in a given directory, LIBDIR, you must either use libtool, and
# ==> default: specify the full pathname of the library, or use the '-LLIBDIR'
# ==> default: flag during linking and do at least one of the following:
# ==> default:    - add LIBDIR to the 'LD_LIBRARY_PATH' environment variable
# ==> default:      during execution
# ==> default:    - add LIBDIR to the 'LD_RUN_PATH' environment variable
# ==> default:      during linking
# ==> default:    - use the '-Wl,-rpath -Wl,LIBDIR' linker flag
# ==> default:    - have your system administrator add LIBDIR to '/etc/ld.so.conf'
# ==> default: See any operating system documentation about shared libraries for
# ==> default: more information, such as the ld(1) and ld.so(8) manual pages.



# #######################
# jpegOptim
#>>>>>>> WORKS
#https://www.yireo.com/blog/1559-jpegoptim-wrong-jpeg-library-version
jpegOptimSrc=${optimBase}_jpegoptim.jpg

cp ${source_img_file} $jpegOptimSrc
# lossy:
# jpegoptim -m 75 --strip-all $jpegOptimSrc

# lossless:
jpegoptim --strip-all $jpegOptimSrc
printFileSize "jpegoptim (lossless)" "$jpegOptimSrc"



#######################
# imgmin
#>>>>>>> WORKS
# imgmin original.jpg optimized.jpg
imgmin ${source_img_file} ${optimBase}_imgmin.jpg
printFileSize "imgmin\t\t" "${optimBase}_imgmin.jpg"

#######################
#cjpeg-dssim

# cp ${source_img_file} $cjpegDssim_jpegoptim_src
../../cjpeg-dssim jpegoptim $source_img_file "_cjpeg-dssim_jpegoptim"
printFileSize "cjpeg-dssim (jpegoptim)" "${source_img_name}_cjpeg-dssim_jpegoptim.jpg"

#original_cjpeg-dssim_jpegoptim.jpg

../../cjpeg-dssim mozjpeg $source_img_file "_cjpeg-dssim_mozjpeg"
printFileSize "cjpeg-dssim (mozjpeg)" "${source_img_name}_cjpeg-dssim_mozjpeg.jpg"
# cp ${source_img_file} $cjpegDssim_mozjpeg_src
# cjpeg-dssim mozjpeg $cjpegDssim_mozjpeg_src
# printFileSize "cjpeg-dssim\t" "$cjpegDssim_mozjpeg_src"


#######################
#######################
# Output size differences
echo $size_output

#######################
#######################
# DIFFs

# echo "\nCreate Diffs\n\n"
# #http://www.imagemagick.org/script/compare.php
# compare -compose src ${source_img_file} ${optimBase}_mozjpeg_q70.jpg ${diffBase}_mozjpeg_q70.jpg
# compare -compose src ${source_img_file} ${optimBase}_mozjpeg_q80.jpg ${diffBase}_mozjpeg_q80.jpg
# compare -compose src ${source_img_file} ${optimBase}_mozjpeg_q90.jpg ${diffBase}_mozjpeg_q90.jpg

# compare -compose src ${source_img_file} ${optimBase}_jpegoptim.jpg ${diffBase}_jpegoptim.jpg
# compare -compose src ${source_img_file} ${optimBase}_imgmin.jpg ${diffBase}_imgmin.jpg
# #compare -compose src rose.jpg reconstruct.jpg difference.png