#!/usr/bin/env bash

folder_name=optim-test-$(date +%Y%m%d_%H%M%S)
if [ -z $1 ]; then
	source_img_name="original"
	source_img_file="${source_img_name}.jpg"
else
	source_img_file="$1"
	source_img_name="${source_img_file%.*}"
fi

optimBase=${source_img_name}_optim
diffBase=${source_img_name}_diff
size_output="\n"

echo "\n\n---------------------------------"
echo "Jpeg optization tests\n\n"
echo "Folder:$folder_name \nSouce:$source_img_file\n\n"


#make output folder
cd /vagrant_shared/sample-images/
mkdir $folder_name
cp ${source_img_file} $folder_name
cd $folder_name

colourspace=$(identify -format "%[colorspace]" ${source_img_file})

#convert file 
if [ $colourspace = "CMYK" ]; then
	mv ${source_img_file} ${source_img_name}_nonRGB.jpeg
	convert ${source_img_name}_nonRGB.jpeg -profile "/usr/share/color/icc/Adobe ICC Profiles/CMYK Profiles/USWebCoatedSWOP.icc" -profile "/usr/share/color/icc/Adobe ICC Profiles/RGB Profiles/sRGB Color Space Profile.icm" ${source_img_file}
elif [ $colourspace != "rgb" ] && [ $colourspace != "sRGB" ] && [ $colourspace != "Gray" ]; then
	echo "\n\nError: Unsupported colourspace"
	echo $(identify -format "%[colorspace]" ${source_img_file})
	exit
fi

originalFileSize=`du -k "${source_img_file}" | cut -f1`
convert ${source_img_file} ${source_img_name}.png

printFileSize () {
	file_size_kb=`du -k $2 | cut -f1`
	file_size_diff=$(expr $originalFileSize - $file_size_kb)
	file_size_diff_perc=$(echo "scale=2;(100 * $file_size_diff / $originalFileSize)" | bc -l)

	if [ $2 != $source_img_file ]; then
		convert $2 ${2}.png
		# print DSSIM of image (without diff img)
		#dssim_output=`dssim ${source_img_name}.png ${2}.png`
		# print DSSIM of image (with diff img)
		dssim_output=`dssim -o diff_${2}.png ${source_img_name}.png ${2}.png`
		
		# Create Diff of image with imgmagic
		# compare -compose src ${source_img_name}.png ${2}.png diff_${2}.png
		rm ${2}.png

		size_output="${size_output}\n$1\t\t${file_size_kb}kb\t(-${file_size_diff}kb\t-${file_size_diff_perc}%\t)\t${dssim_output}"
	else
		size_output="$size_output\n$1\t\t${file_size_kb}kb"
	fi
}

printFileSize "original size\t" "${source_img_file}"



# #######################
# jpegOptim
#>>>>>>> WORKS
#https://www.yireo.com/blog/1559-jpegoptim-wrong-jpeg-library-version
jpegOptimSrcLossless=${optimBase}_jpegoptim.jpg
# jpegOptimSrcLossy=${optimBase}_jpegoptim_lossy75.jpg

cp ${source_img_file} $jpegOptimSrcLossless
# cp ${source_img_file} $jpegOptimSrcLossy

jpegOptimLossy () {
	jpegOptimSrcLossy=${optimBase}_jpegoptim_lossy${1}.jpg
	cp ${source_img_file} $jpegOptimSrcLossy
	jpegoptim --max=$1 --strip-all --all-progressive --threshold=1 $jpegOptimSrcLossy
	printFileSize "jpegoptim (${1}%)\t" "$jpegOptimSrcLossy"
}

# lossless:
jpegoptim --strip-all $jpegOptimSrcLossless
printFileSize "jpegoptim (lossless)" "$jpegOptimSrcLossless"

jpegOptimLossy 90
jpegOptimLossy 80
jpegOptimLossy 70

# lossy:
# jpegoptim --max=75 --strip-all --all-progressive --threshold=1% $jpegOptimSrcLossy
# printFileSize "jpegoptim (lossy 70%)" "$jpegOptimSrcLossy"

#######################
# Mozjpeg

cjpegMozJpeg () {
	dest_file=${optimBase}_mozjpeg_q${1}.jpg
	#TODO: readd -quality argument
	#https://github.com/mozilla/mozjpeg/blob/master/usage.txt

	mozcjpeg -quality ${1} -tune-ssim -optimize -outfile "${dest_file}" "${source_img_file}"
	# mozcjpeg -rgb -optimize "${1}" -outfile ${dest_file} ${source_img_file}
	printFileSize "MozJpeg (${1}%)\t" "$dest_file"
}
cjpegMozJpeg 90
cjpegMozJpeg 80
cjpegMozJpeg 70

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

