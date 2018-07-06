#!/bin/bash

# Instructions
# Call this script with
# sh list_files_on_grid.sh fileType run_list
# where fileType is in {ntuple, ratds}

# Initialization
ratVersion="6.15.0"
gridPath="srm://srm01.ncg.ingrid.pt:8444/srm/managerv2?SFN=/snoplus.snolab.ca/user/stefannae/data/AmBe/"
gridTagPath=${gridPath}"rat-"${ratVersion}
gridRatdsPath=${gridTagPath}"/ratds/"
gridNtuplePath=${gridTagPath}"/ntuple/"

linkPath="lfn:/grid/snoplus.snolab.ca/user/stefannae/data/AmBe/"
linkTagPath=${linkPath}"rat-"${ratVersion}
linkRatdsPath=${linkTagPath}"/ratds/"
linkNtuplePath=${linkTagPath}"/ntuple/"

PASS="0"

SUB_RUNS=("0" "1" "2")

FILE_TYPE="$1"
RUN_LIST="$2"

echo "GUID" > filelist.dat

while read RUN; do
  for SUB_FILE in ${SUB_RUNS[@]}; do
    analysisFileName="AmBe_r0000"$RUN"_s00"$SUB_FILE"_p00"$PASS

    if [ $FILE_TYPE = "ratds" ]
    then
      # .root files
      ratdsAnalysisFile=$ratdsAnalysisPath$analysisFileName".root"
      ratdsGridFile=$gridRatdsPath$analysisFileName".root"
      ratdsLink=$linkRatdsPath$analysisFileName".root"

      RATDS_STAT="$(gfal-ls -l $ratdsGridFile 2>&1 | grep -o '\w*'$ratdsAnalysisFile)"
      if [ "$RATDS_STAT" = $ratdsAnalysisFile ]
      then
        echo "Found grid .root file for run "$RUN" subfile "$SUB_FILE"."
        R_GUID="$(gfal-xattr $ratdsLink user.guid)"
        R_CHECKSUM="$(lcg-get-checksum $ratdsGridFile | grep -o '^\w*\b')"
        R_SIZE="$(gfal-stat $ratdsLink | grep 'Size' | grep -o '[0-9]*')"
	echo $analysisFileName".root     "$R_SIZE"     guid:"$R_GUID"     "$R_CHECKSUM
        echo $analysisFileName".root     "$R_SIZE"     guid:"$R_GUID"     "$R_CHECKSUM >> filelist.dat
      else
        echo "Did not find grid .root file for run "$RUN" subfile "$SUB_FILE"."
      fi
    elif [ $FILE_TYPE = "ntuple" ]
    then
      # .ntuple.root files
      ntupleAnalysisFile=$ntupleAnalysisPath$analysisFileName".ntuple.root"
      ntupleGridFile=$gridNtuplePath$analysisFileName".ntuple.root"
      ntupleLink=$linkNtuplePath$analysisFileName".ntuple.root"

      NTUPLE_STAT="$(gfal-ls -l $ntupleGridFile 2>&1 | grep -o '\w*'$ntupleAnalysisFile)"
      if [ "$NTUPLE_STAT" = $ntupleAnalysisFile ]
      then
        echo "Found grid .ntuple.root file for run "$RUN" subfile "$SUB_FILE"."
        N_GUID="$(gfal-xattr $ntupleLink user.guid)"
        N_CHECKSUM="$(lcg-get-checksum $ntupleGridFile | grep -o '^\w*\b')"
        N_SIZE="$(gfal-stat $ntupleLink | grep 'Size' | grep -o '[0-9]*')"
        echo $analysisFileName".ntuple.root     "$N_SIZE"     guid:"$N_GUID"     "$N_CHECKSUM
        echo $analysisFileName".ntuple.root     "$N_SIZE"     guid:"$N_GUID"     "$N_CHECKSUM >> filelist.dat
      else
        echo "Did not find a grid .ntuple.root file for run "$RUN" subfile "$SUB_FILE"."
      fi
    fi
  done
done <$RUN_LIST

exit 0
