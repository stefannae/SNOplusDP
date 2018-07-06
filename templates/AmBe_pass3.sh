#!/bin/bash

#$ -V

RAT_PATH="/lstore/sno/stefan/rat/"
RAT_VERSION="6.15.0"
RAT_INPUT="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/local/rat-6.15.0/in_grid/109133/0/SNOP_0000109133_000.l2.root"
RAT_OUTPUT="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/local/rat-6.15.0/in_grid/109133/0/Analysis_r0000109133_s000_p001"
OUTPUT_PATH="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/local/rat-6.15.0/in_grid/109133/0"

RAT_MACRO=${RAT_PATH}"rat-"${RAT_VERSION}"/mac/processing/water/third_pass_AmBe_processing_wSelection.mac"
#RATDB_CONN="postgres://snoplus:dontestopmenow@pgsql.snopl.us:5400/ratdb"

#..#$ -v SGEIN1=$RAT_MACRO
#..#$ -v SGEIN2=$RAT_INPUT

#..#$ -v SGEOUT1=${RAT_OUTPUT}.root
#..#$ -v SGEOUT1=${RAT_OUTPUT}.ntuple.root

# Default
# Looks like solip misses liblzma.so.0 but I did not get errors all the time, sometimes it runs
#..#$ -q solip
#$ -q lipq

# Env
# Option 0
# preload the env and inherit it with "#$ -V"

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
#rat -i $RAT_INPUT -o $RAT_OUTPUT -b $RATDB_CONN $RAT_MACRO
rat -i $RAT_INPUT $RAT_MACRO

exit 0
