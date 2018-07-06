#!/bin/bash

# Instructions
# Call this script with
# sh copy_processed_files_for_analysis.sh run_list

# Initialization
ratVersion="6.15.0"
rootPath="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
tagPath=${rootPath}"local/rat-"${ratVersion}
processingPath=${tagPath}"/in_grid/"
ratdsAnalysisPath=${tagPath}"/ratds/"
ntupleAnalysisPath=${tagPath}"/ntuple/"

#PASS="0"
PASS="1"

SUB_RUNS=("0" "1" "2")

RUN_LIST="$1"

while read RUN; do
  for SUB_FILE in ${SUB_RUNS[@]}; do
    analysisFileName="AmBe_r0000"$RUN"_s00"$SUB_FILE"_p00"$PASS

    # .root files
    ratdsProcessingFile=$processingPath$RUN"/"$SUB_FILE"/output.root"
    ratdsAnalysisFile=$ratdsAnalysisPath$analysisFileName".root"
    if [ -f $ratdsProcessingFile ]
    then
      echo "Found processed .root file for run "$RUN" subfile "$SUB_FILE"."

      if [ -f $ratdsAnalysisFile ]
      then
        echo "The file is already available for analysis."
      else
        echo "Copying the file for analysis."
        #scp -p $ratdsProcessingFile $ratdsAnalysisFile
        cp -p $ratdsProcessingFile $ratdsAnalysisFile
      fi

    else
      echo "Did not find a processed .root file for run "$RUN" subfile "$SUB_FILE"."
    fi

    # .ntuple.root files
    ntupleProcessingFile=$processingPath$RUN"/"$SUB_FILE"/output.ntuple.root"
    ntupleAnalysisFile=$ntupleAnalysisPath$analysisFileName".ntuple.root"
    if [ -f $ntupleProcessingFile ]
    then
      echo "Found processed .ntuple.root file for run "$RUN" subfile "$SUB_FILE"."

      if [ -f $ntupleAnalysisFile ]
      then
        echo "The file is already available for analysis."
      else
        echo "Copying the file for analysis."
        #scp -p $ntupleProcessingFile $ntupleAnalysisFile
        cp -p $ntupleProcessingFile $ntupleAnalysisFile
      fi

    else
      echo "Did not find a processed .ntuple.root file for run "$RUN" subfile "$SUB_FILE"."
    fi


  done
done <$RUN_LIST

exit 0
