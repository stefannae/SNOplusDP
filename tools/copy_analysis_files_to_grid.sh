#!/bin/bash

# Instructions
# Call this script with
# sh copy_analysis_files_to_grid.sh run_list

# Initialization
ratVersion="6.15.0"
rootPath="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
tagPath=${rootPath}"local/rat-"${ratVersion}
ratdsAnalysisPath=${tagPath}"/ratds/"
ntupleAnalysisPath=${tagPath}"/ntuple/"

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

RUN_LIST="$1"

while read RUN; do
  for SUB_FILE in ${SUB_RUNS[@]}; do
    analysisFileName="AmBe_r0000"$RUN"_s00"$SUB_FILE"_p00"$PASS

    # .root files
    ratdsAnalysisFile=$ratdsAnalysisPath$analysisFileName".root"
    ratdsGridFile=$gridRatdsPath$analysisFileName".root"
    ratdsLink=$linkRatdsPath$analysisFileName".root"
    if [ -f $ratdsAnalysisFile ]
    then
      echo "Found analysis .root file for run "$RUN" subfile "$SUB_FILE"."
      echo "Copying the file to the grid."
      gfal-copy -S SNOPLUSDISK_TOKEN $ratdsAnalysisFile $ratdsGridFile $ratdsLink
    else
      echo "Did not find analysis .root file for run "$RUN" subfile "$SUB_FILE"."
    fi

    # .ntuple.root files
    ntupleAnalysisFile=$ntupleAnalysisPath$analysisFileName".ntuple.root"
    ntupleGridFile=$gridNtuplePath$analysisFileName".ntuple.root"
    ntupleLink=$linkNtuplePath$analysisFileName".ntuple.root"
    if [ -f $ntupleAnalysisFile ]
    then
      echo "Found processed .ntuple.root file for run "$RUN" subfile "$SUB_FILE"."
      echo "Copying the file to the grid."
      gfal-copy -S SNOPLUSDISK_TOKEN $ntupleAnalysisFile $ntupleGridFile $ntupleLink
    else
      echo "Did not find a analysis .ntuple.root file for run "$RUN" subfile "$SUB_FILE"."
    fi

  done
done <$RUN_LIST

exit 0
