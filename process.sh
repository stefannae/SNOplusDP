#!/bin/bash

# Initialization:

RATVersion="6.5.2"

# on Fermi
#/home/sno/stefan/
#source ~/load-rat-water.sh
#/lstore/sno/stefan/rat/
source /lstore/sno/stefan/rat/load-rat-6.5.2.sh
filePath="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
zdabFilePath=${filePath}"L2/"
macFilePath=${filePath}"local/rat-"${RATVersion}"/in_processing/"
outputFilePath=${filePath}"local/rat-"${RATVersion}"/in_processing/"

#source ~/load-rat-water.sh
#zdabFilePath="/lstore/sno/stefan/data/backgrounds/"
#macFilePath="/lstore/sno/stefan/data/"
#outputFilePath=${zdabFilePath}"processed/"

# on Stefan
#source ~/snoing/install/env_rat-water.sh
#zdabFilePath="/media/stefan/arhiva1/DATA/AmBe/center/"
#macFilePath="/media/stefan/arhiva1/DATA/AmBe/"
#outputFilePath=${zdabFilePath}"processed/"

RUNS="$@" #for run numbers as inputs to script
#for r in "$@"
for r in $RUNS
#fileList=$1
#for r in "$@" #for file with run numbers input to script
do
  for subfile in 0 1 2
  do
    #wc $r # with input file
    zdabFileName="SNOP_0000"$r"_00"$subfile".l2"
    #echo ${zdabFilePath}${zdabFileName}.zdab
    if [ -f ${zdabFilePath}${zdabFileName}.zdab ]
    then
        echo "Found L2 file "${zdabFilePath}${zdabFileName}.zdab

	# FIRST PASS
	time rat -n $r -i ${zdabFilePath}${zdabFileName}.zdab ${macFilePath}first_pass_data_cleaning.mac > ${outputFilePath}${zdabFileName}.first_pass.log
        #continue

	# SECOND PASS
	if [ -f ${outputFilePath}"second_pass/"${zdabFileName}.root ]
	then
	    echo "A second pass root file already exists."
	else
	    time rat -n $r -i ${zdabFilePath}${zdabFileName}.zdab -o ${outputFilePath}"second_pass/"${zdabFileName}.root ${macFilePath}second_pass_processing.mac > ${outputFilePath}${zdabFileName}.second_pass.log
	fi

	# THIRD PASS
	processedFileName="SNOP_0000"$r"_00"$subfile"_l2"
	if [ -f ${outputFilePath}"third_pass/"${processedFileName}.root ]
	then
	    echo "A third pass root file already exists."
	else
	    echo "Adding spices."
            time rat -n $r -i ${outputFilePath}"second_pass/"${zdabFileName}.root -o ${outputFilePath}"third_pass/"${processedFileName} ${macFilePath}third_pass_AmBe_processing.mac > ${outputFilePath}${zdabFileName}.third_pass.log
	fi
    fi
  done
done
