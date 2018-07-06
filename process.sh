#!/bin/bash

# Initialization:

# on Fermi
source ~/load-rat-water.sh
filePath="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
zdabFilePath=${filePath}"L2/trimmed/"
macFilePath=${filePath}"local/rat-6.5.0/raw/"
outputFilePath=${filePath}"local/rat-6.5.0/raw/"

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
    zdabFileName="SNOP_0000"$r"_00"$subfile".l2.t_800_n1_16_n2_4"
    #echo ${zdabFilePath}${zdabFileName}.zdab
    if [ -f ${zdabFilePath}${zdabFileName}.zdab ]
    then
        echo ${zdabFilePath}${zdabFileName}.zdab

	# FIRST PASS
	#nohup time rat -i ${zdabFilePath}${zdabFileName}.zdab ${macFilePath}first_pass_data_cleaning.mac > ${outputFilePath}SNOP_0000109133_001.l2.t_800_n1_16_n2_4.first_pass.log &
	time rat -i ${zdabFilePath}${zdabFileName}.zdab ${macFilePath}first_pass_data_cleaning.mac > ${outputFilePath}${zdabFileName}.first_pass.log
        #continue

	# SECOND PASS
	if [ -f ${outputFilePath}${zdabFileName}.root ]
	then
	    echo "A second pass root file already exists."
	else
	    #nohup time rat -i ${zdabFilePath}${zdabFileName}.zdab -o ${outputFilePath}{zdabFileName}.root ${macFilePath}second_pass_processing.mac > ${outputFilePath}${zdabFileName}.second_pass.log &
	    time rat -i ${zdabFilePath}${zdabFileName}.zdab -o ${outputFilePath}${zdabFileName}.root ${macFilePath}second_pass_processing.mac > ${outputFilePath}${zdabFileName}.second_pass.log
	fi

	# THIRD PASS
	processedFileName="SNOP_0000"$r"_00"$subfile"_l2_t_800_n1_16_n2_4"
	if [ -f ${outputFilePath}${processedFileName}_third_pass.root ]
	then
	    echo "A third pass root file already exists."
	else
           # nohup time rat -i ${outputFilePath}${zdabFileName}.root -o ${outputFilePath}${processedFileName} ${macFilePath}third_pass_analysis_processing_AmBe5-testing.mac > ${outputFilePath}${zdabFileName}.third_pass.log &
           #time rat -i ${outputFilePath}${zdabFileName}.root -o ${outputFilePath}${processedFileName} ${macFilePath}third_pass_analysis_processing_AmBe5-testing2.mac > ${outputFilePath}${zdabFileName}.third_pass.log
           time rat -i ${outputFilePath}${zdabFileName}.root -o ${outputFilePath}${processedFileName} ${macFilePath}third_pass_AmBe_processing.mac > ${outputFilePath}${zdabFileName}.third_pass.log
	fi
    fi
  done
done
