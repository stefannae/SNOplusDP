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
ROOT_FILE=$FILE_PATH$FILE_NAME".root"

# lstore way
LSTORE_AMBE="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
RAT_INPUT=$LSTORE_AMBE"L2/"$FILE_NAME".zdab"
RAT_OUTPUT=$LSTORE_AMBE"local/"$ROOT_FILE
OUTPUT_PATH=$LSTORE_AMBE"local/"$FILE_PATH

# RAT
RAT_MACRO=$RAT_PATH"rat-"$RAT_VERSION"/mac/processing/water/second_pass_processing.mac"
#RATDB_CONN="postgres://snoplus:pass@pgsql.snopl.us:5400/ratdb"

# INs
# The following list should be updated
#TABLE1="TPMUONFOLLOWER.ratdb"
#TABLE2="PedCut.ratdb"
#TABLE3="MissedMuonFollower.ratdb"
#TABLE4="LAST_MUON.ratdb"
#TABLE5="tpmuonfollowercut_"${RUN}".json"
#..#$ -v SGEIN1=$RAT_MACRO
#..#$ -v SGEIN2=$TABLE1
#..#$ -v SGEIN3=$TABLE2
#..#$ -v SGEIN4=$TABLE3
#..#$ -v SGEIN5=$TABLE4
#..#$ -v SGEIN6=$TABLE5

# OUTs
# Transfer the outputs (relative path)
#..#$ -v SGEOUT1=rat.*.log
#..#$ -v SGEOUT2=SNOP_*.l2.root

# Resources
#..#$ -l h=!wn200
#$ -l h=!((wn163|wn164|wn166|wn167|wn168|wn169|wn170|wn174|wn177|wn178|wn179|wn181|wn183|wn184|wn185|wn187|wn200|wn201|wn202|wn203|wn216)

# QUEUE (default is lipq)
#..#$ -q lipq
# Looks like solip misses liblzma.so.0 but I did not get errors all the time, sometimes it runs.
#..#$ -q solip

# Env
# Option 0
# preload the env (like Option 2) and inherit it with "#$ -V"

# For options 1 and 2 - not sure it is necessary, it worked without it.
# source /etc/profile.d/modules.sh

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
# /lstore
#rat -i $RAT_INPUT -o $RAT_OUTPUT -b $RATDB_CONN $RAT_MACRO
#rat -i $RAT_INPUT -o $RAT_OUTPUT $RAT_MACRO
#rat -d water-ndecay-v2 -i $RAT_INPUT -o $RAT_OUTPUT $RAT_MACRO

#/usr/bin/time --verbose --output=${OUTPUT_PATH}"time_pass2_"${RUN}"_"${SUBFILE}".log" rat -d water-ndecay-v2 -i $RAT_INPUT -o $RAT_OUTPUT $RAT_MACRO
/usr/bin/time --verbose --output=${OUTPUT_PATH}"time_pass2_"${RUN}"_"${SUBFILE}".log" /lstore/sno/stefan/rat/rat-6.15.0/bin/rat -d water-ndecay-v2 -i $RAT_INPUT -o $RAT_OUTPUT $RAT_MACRO

# mixed
#rat -i $RAT_INPUT $RAT_MACRO
#rat -i $RAT_INPUT -o $FILE_NAME".root" $RAT_MACRO
#rat -d water-ndecay-v2 -i $RAT_INPUT -o $FILE_NAME".root" $RAT_MACRO

exit 0
