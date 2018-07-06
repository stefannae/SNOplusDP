#!/bin/bash

# Instructions
# Call this script with
# $ sh process.sh run_no run_subfile
# or
# $ nohup sh process.sh run_no run_subfile > run_no_run_subfile.log &
# for all subfiles use ALL value for run_subfile

# Initialization

#ratVersion="6.5.2"
#ratVersion="6.5.3"
#ratVersion="dev"
ratVersion="6.15.0"

RUN="$1"
if [ "$2" == "ALL" ]; then
  SUBRUNS=("0" "1" "2")
else
  SUBRUNS=("$2")
fi

# Should add $3 for testing

echo "Starting processing of run "$RUN" with subfiles "${SUBRUNS[@]}" using RAT "$ratVersion"."

# File locations (should check if these exist)

# INPUT
filePath="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
zdabFilePath=${filePath}"L2/"

# OUTPUT
#fermiFilePath="/home/sno/stefan/AmBe/"
#outputFilePath=${fermiFilePath}"local/rat-"${ratVersion}"/in_grid/"${RUN}
outputFilePath=${filePath}"local/rat-"${ratVersion}"/in_grid/"${RUN}

if [ ! -d "$outputFilePath" ]; then
  mkdir $outputFilePath
fi

# MACRO
ratPath="/lstore/sno/stefan/rat/"

for subfile in ${SUBRUNS[@]}
do
  zdabFileName="SNOP_0000"$RUN"_00"$subfile".l2"

  if [ -f ${zdabFilePath}${zdabFileName}.zdab ]
  then
    echo ""
    echo "L2 file "${zdabFilePath}${zdabFileName}.zdab

    subOutputFilePath=${outputFilePath}"/"${subfile}
    if [ ! -d "$subOutputFilePath" ]; then
      mkdir $subOutputFilePath
    fi

    # If I cd here the .o and .e files do not get in the folder. Pass one dumps the files directly to lstore. I cd in the pass file.
    cd $subOutputFilePath

    # FIRST PROCESSING PASS
    pass1FilePathTemplate=$filePath"templates/AmBe_pass1.sh"
    pass1FilePath=${filePath}"local/AmBe_pass1.sh"
    echo ""
    echo "FIRST PASS"
    # Check for FIRST PASS files and submit job if needed
    REQ_FILES=("TPMUONFOLLOWER.ratdb" "tpmuonfollowercut_${RUN}.json" "PedCut.ratdb" "MissedMuonFollower.ratdb" "LAST_MUON.ratdb" "LastAtmospheric.ratdb" "Atmospherics.ratdb")
    for req_file in ${REQ_FILES[@]}
    do
      if [ ! -f "${subOutputFilePath}/${req_file}" ]
      then
        echo "Parameters"
        echo "P1: "$pass1FilePath
        echo "P2: "$ratPath
        echo "P3: "$ratVersion
        echo "P4: "$RUN
        echo "P5: "$subfile

       (head -5 "$pass1FilePathTemplate"; echo "RAT_PATH=\"$ratPath\""; echo "RAT_VERSION=\"$ratVersion\""; echo "RUN=\"$RUN\""; echo "SUBFILE=\"$subfile\""; tail -n +10 "$pass1FilePathTemplate") > $pass1FilePath

        qsub $pass1FilePath
        #sh $pass1FilePath
        break
      fi
      echo $req_file" already exists."
    done

    #exit 0
    #qsub $pass1FilePath

    # Wait for the FIRST PASS
    for req_file in ${REQ_FILES[@]}
    do
      while [ ! -f "${subOutputFilePath}/${req_file}" ]
      do
        echo "Waiting ... 60"
        sleep 60
      done
    done

    #exit 0
    #cd $subOutputFilePath

    # SECOND PROCESSING PASS
    pass2FilePathTemplate=$filePath"templates/AmBe_pass2.sh"
    pass2FilePath=${filePath}"local/AmBe_pass2.sh"
    echo ""
    echo "SECOND PASS"
    if [ -f ${subOutputFilePath}/${zdabFileName}.root ]
    then
      echo "A second pass root file already exists."
    else
      echo "Parameters"
      echo "P1: "$pass2FilePath
      echo "P2: "$ratPath
      echo "P3: "$ratVersion
      echo "P4: "$RUN
      echo "P5: "$subfile

      (head -5 "$pass2FilePathTemplate"; echo "RAT_PATH=$ratPath"; echo "RAT_VERSION=$ratVersion"; echo "RUN=$RUN"; echo "SUBFILE=$subfile"; tail -n +10 "$pass2FilePathTemplate") > $pass2FilePath

      qsub $pass2FilePath
      #sh  $pass2FilePath
    fi

    #exit 0

    # Wait for the SECOND PASS
    # 1. Wait for the root file to exist
    while [ ! -f "${subOutputFilePath}/${zdabFileName}.root" ]
    do
      echo "Waiting ... 60"
      sleep 60
    done
    # 2. Wait for the pass to finish when the file is processed at lstore
    while :
    do
      # Get current and file times
      sysTimestamp=$(date +%s)
      rootFileTimestamp=$(stat "${subOutputFilePath}/${zdabFileName}.root" -c %Y)
      timeDiff=$(expr $sysTimestamp - $rootFileTimestamp)
      if [ $timeDiff -lt 60 ]
      then
        echo "Time differene is "$timeDiff
        echo "Waiting ... 120"
      	sleep 120
      else
        break
      fi
    done

    # THIRD PROCESSING PASS
    pass3FilePathTemplate=${filePath}"templates/AmBe_pass3.sh"
    pass3FilePath=${filePath}"local/AmBe_pass3.sh"
    #analysisFileName="Analysis_r0000"$RUN"_s00"$subfile"_p001"
    analysisFileName="output"
    echo ""
    echo "THIRD PASS"
    if [ -f ${subOutputFilePath}/${analysisFileName}.root ]
    then
      echo "A third pass root file already exists."
    else
      echo "Parameters"
      echo "P1: "$pass3FilePath
      echo "P2: "$ratPath
      echo "P3: "$ratVersion
      echo "P4: "$RUN
      echo "P5: "$subfile

      (head -5 "$pass3FilePathTemplate"; echo "RAT_PATH=$ratPath"; echo "RAT_VERSION=$ratVersion"; echo "RUN=$RUN"; echo "SUBFILE=$subfile"; tail -n +10 "$pass3FilePathTemplate") > $pass3FilePath

      echo "Skipping THIRD PASS. This is for the FOURTH PASS. FIX ME!"
      #qsub $pass3FilePath
      #sh $pass3FilePath
    fi

    # FOURTH PROCESSING PASS
    # assumes the third pass was already performed and the data for a run was archived in a /backup directory at the same level with the runs (eg $ cp -a 109133 backup/) while the output files from the third pass were removed from the run folder.
    pass4FilePathTemplate=${filePath}"templates/AmBe_pass4.sh"
    pass4FilePath=${filePath}"local/AmBe_pass4.sh"
    #analysisFileName="Analysis_r0000"$RUN"_s00"$subfile"_p001"
    analysisFileName="output"
    echo ""
    echo "FOURTH PASS"
    if [ -f ${subOutputFilePath}/${analysisFileName}.root ]
    then
      echo "A fourth pass root file already exists."
    else
      echo "Parameters"
      echo "P1: "$pass4FilePath
      echo "P2: "$ratPath
      echo "P3: "$ratVersion
      echo "P4: "$RUN
      echo "P5: "$subfile

      (head -5 "$pass4FilePathTemplate"; echo "RAT_PATH=$ratPath"; echo "RAT_VERSION=$ratVersion"; echo "RUN=$RUN"; echo "SUBFILE=$subfile"; tail -n +10 "$pass4FilePathTemplate") > $pass4FilePath

      qsub $pass4FilePath
      #sh $pass4FilePath
    fi

  else
    echo ""
    echo "L2 file not found"${zdabFilePath}${zdabFileName}.zdab
  fi
done

exit 0
