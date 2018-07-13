#!/bin/bash

#$ -V

# INPUTS
RAT_PATH="/lstore/sno/stefan/rat/"
RAT_VERSION="6.15.0"
RUN="109134"
SUBFILE="2"

# DATA
if [ $SUBFILE -gt 9 ]; then
  FILE_NAME="SNOP_0000"$RUN"_0"$SUBFILE".l2"
else
  FILE_NAME="SNOP_0000"$RUN"_00"$SUBFILE".l2"
fi

# relative way / scp
FILE_PATH="rat-"$RAT_VERSION"/in_grid/"$RUN"/"$SUBFILE"/"

# lstore way
LSTORE_AMBE="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
RAT_INPUT=$LSTORE_AMBE"L2/"$FILE_NAME".zdab"
OUTPUT_PATH=$LSTORE_AMBE"local/"$FILE_PATH

# fermi way
#FERMI_AMBE="/home/sno/stefan/AmBe/"
#OUTPUT_PATH=$FERMI_AMBE"local/"$FILE_PATH

# RAT
RAT_MACRO=${RAT_PATH}"rat-"${RAT_VERSION}"/mac/processing/water/first_pass_data_cleaning.mac"
#RATDB_CONN="postgres://snoplus:pass@pgsql.snopl.us:5400/ratdb"

# INs
#..#$ -v SGEIN1=$RAT_MACRO:first_pass_data_cleaning.mac
#..#$ -v SGEIN2=$RAT_INPUT:$FILE_NAME".zdab"

# OUTs
# The following	list should be updated
TABLE1="TPMUONFOLLOWER.ratdb"
TABLE2="PedCut.ratdb"
TABLE3="MissedMuonFollower.ratdb"
TABLE4="LAST_MUON.ratdb"
TABLE5="LastAtmospheric.ratdb"
TABLE6="Atmospherics.ratdb"
TABLE7="tpmuonfollowercut_"${RUN}".json"
#..#$ -v SGEOUT1=$OUTPUT_PATH$TABLE1
#..#$ -v SGEOUT2=$OUTPUT_PATH$TABLE2
#..#$ -v SGEOUT3=$OUTPUT_PATH$TABLE3
#..#$ -v SGEOUT4=$OUTPUT_PATH$TABLE4
#..#$ -v SGEOUT5=$OUTPUT_PATH$TABLE5
#..#$ -v SGEOUT6=$OUTPUT_PATH$TABLE6
#..#$ -v SGEOUT7=$OUTPUT_PATH$TABLE7

#..#$ -v SGEOUT1=$TABLE1
#..#$ -v SGEOUT2=$TABLE2
#..#$ -v SGEOUT3=$TABLE3
#..#$ -v SGEOUT4=$TABLE4
#..#$ -v SGEOUT5=$TABLE5
#..#$ -v SGEOUT6=$TABLE6
#..#$ -v SGEOUT7=$TABLE7
#..#$ -v SGEOUT8="rat.*.log"

# Resources
#..#$ -l h_vmem=2G,h_fsize=2G
#..#$ -l h_vmem=4G
#$ -l h=!(wn174|wn181|wn187|wn200|wn201|wn202|wn203|wn216)

# QUEUE (default is lipq)
#..#$ -q lipq
# Looks like solip misses liblzma.so.0 but I did not get errors all the time, sometimes it runs.
#..#$ -q solip

# Env
# Option 0
# preload the env (like Option 2) and inherit it with "#$ -V"

# For options 1 and 2 - not sure it is necessary, it worked without it.
#source /etc/profile.d/modules.sh

# Option 1
#module load geant/4.10.00.p02
#module load root-5.34.14
#module load scons/2.3.4
#module load curl/7.26.0
#module load python-2.7.9
#source /lstore/sno/stefan/rat/rat-${RAT_VERSION}/env.sh

# Option 2
#source /exper-sw/sno/snoplus/snoing/install/env_rat-${RAT_VERSION}.sh
#source /lstore/sno/stefan/rat/load-rat-${RAT_VERSION}.sh
#source ${RAT_PATH}load-rat-${RAT_VERSION}.sh

# Set output location
cd $OUTPUT_PATH

# Job
#rat -i $RAT_INPUT -b $RATDB_CONN $RAT_MACRO
#rat -i $RAT_INPUT $RAT_MACRO
#rat -d water-ndecay-v2 -i $RAT_INPUT $RAT_MACRO

#touch ${FILE_PATH}"time_"${RUN}"_"${SUBFILE}".log"
#/usr/bin/time --verbose --output=${OUTPUT_PATH}"time_pass1_"${RUN}"_"${SUBFILE}".log" rat -d water-ndecay-v2 -i $RAT_INPUT $RAT_MACRO
/usr/bin/time --verbose --output=${OUTPUT_PATH}"time_pass1_"${RUN}"_"${SUBFILE}".log" /lstore/sno/stefan/rat/rat-6.15.0/bin/rat -d water-ndecay-v2 -i $RAT_INPUT $RAT_MACRO

#rat -d water-ndecay-v2 $RAT_INPUT $RAT_MACRO
#rat -i $RAT_INPUT first_pass_data_cleaning.mac
#rat -i ${FILE_NAME}".zdab" first_pass_data_cleaning.mac

exit 0
