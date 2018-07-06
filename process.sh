#!/bin/bash

# Instructions
# Call this script with
# $ sh process.sh run_no run_subfile
# for all subfiles use ALL value for run_subfile

# Initialization:

#LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH

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

echo "Starting processing of run "$RUN" with subfiles "${SUBRUNS[@]}" using RAT "$ratVersion"."

# File locations (should check if these exist)
# INPUT
filePath="/lstore/sno/snoplus/Data/Water/Calibration/AmBe/"
zdabFilePath=${filePath}"L2/"
# OUTPUT
outputFilePath=${filePath}"local/rat-"${ratVersion}"/in_grid/"${RUN}
if [ ! -d "$outputFilePath" ]; then
  mkdir $outputFilePath
fi
# MACRO
ratPath="/lstore/sno/stefan/rat/"
#macFilePath=${ratPath}"rat-"${ratVersion}"/mac/processing/water/"

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

    # FIRST PROCESSING PASS
    pass1FilePath=${filePath}"local/AmBe_pass1.sh"
    echo ""
    echo "FIRST PASS"
    echo "Parameters"
    echo "P1: "${pass1FilePath}
    echo "P2: "${ratPath}
    echo "P3: "${ratVersion}
    echo "P4: "${zdabFilePath}${zdabFileName}.zdab
    echo "P5: "${subOutputFilePath}
    sed -i "5s|.*|RAT_PATH=\"${ratPath}\"|" $pass1FilePath
    sed	-i "6s|.*|RAT_VERSION=\"${ratVersion}\"|" $pass1FilePath
    sed	-i "7s|.*|RAT_INPUT=\"${zdabFilePath}${zdabFileName}.zdab\"|" $pass1FilePath
    sed -i "8s|.*|OUTPUT_PATH=\"${subOutputFilePath}\"|" $pass1FilePath
    qsub $pass1FilePath

    # Wait for the FIRST PASS
    REQ_FILES=("TPMUONFOLLOWER.ratdb" "tpmuonfollowercut_${RUN}.json" "PedCut.ratdb" "MissedMuonFollower.ratdb" "LAST_MUON.ratdb" "LastAtmospheric.ratdb" "Atmospherics.ratdb")
    for req_file in ${REQ_FILES[@]}
    do
      while [ ! -f "${subOutputFilePath}/${req_file}" ]
      do
        echo "Waiting ..."
	sleep 60
      done
    done

    # SECOND PROCESSING PASS
    pass2FilePath=${filePath}"local/AmBe_pass2.sh"
    echo ""
    echo "SECOND PASS"
    if [ -f ${subOutputFilePath}/${zdabFileName}.root ]
    then
      echo "A second pass root file already exists."
    else
      echo "Parameters"
      echo "P1: "${pass2FilePath}
      echo "P2: "${ratPath}
      echo "P3: "${ratVersion}
      echo "P4: "${zdabFilePath}${zdabFileName}.zdab
      echo "P5: "${subOutputFilePath}/${zdabFileName}.root
      echo "P6: "${subOutputFilePath}
      sed -i "5s|.*|RAT_PATH=\"${ratPath}\"|" $pass2FilePath
      sed -i "6s|.*|RAT_VERSION=\"${ratVersion}\"|" $pass2FilePath
      sed -i "7s|.*|RAT_INPUT=\"${zdabFilePath}${zdabFileName}.zdab\"|" $pass2FilePath
      sed -i "8s|.*|RAT_OUTPUT=\"${subOutputFilePath}/${zdabFileName}.root\"|" $pass2FilePath
      sed -i "9s|.*|OUTPUT_PATH=\"${subOutputFilePath}\"|" $pass2FilePath
      qsub $pass2FilePath
    fi

    # Wait for the SECOND PASS
    # Get current and file times
    while [ ! -f "${subOutputFilePath}/${zdabFileName}.root" ]
    do
      echo "Waiting ... 60"
      sleep 60
    done


    while :
    do
      sysTimestamp=$(date +%s)
      rootFileTimestamp=$(stat "${subOutputFilePath}/${zdabFileName}.root" -c %Y)
      timeDiff=$(expr $sysTimestamp - $rootFileTimestamp)
      if [ $timeDiff -lt 90 ]
      then
        echo "Time differene is "$timeDiff
        echo "Waiting ... 180"
      	sleep 180
      else
        break
      fi
    done

    # THIRD PROCESSING PASS
    pass3FilePath=${filePath}"local/AmBe_pass3.sh"
    analysisFileName="Analysis_r0000"$RUN"_s00"$subfile"_p001"
    echo ""
    echo "THIRD PASS"
    if [ -f ${subOutputFilePath}/${analysisFileName}.root ]
    then
      echo "A third pass root file already exists."
    else
      echo "Parameters"
      echo "P1: "${pass3FilePath}
      echo "P2: "${ratPath}
      echo "P3: "${ratVersion}
      echo "P4: "${subOutputFilePath}/${zdabFileName}.root
      echo "P5: "${subOutputFilePath}/${analysisFileName}
      echo "P6: "${subOutputFilePath}
      sed -i "5s|.*|RAT_PATH=\"${ratPath}\"|" $pass3FilePath
      sed -i "6s|.*|RAT_VERSION=\"${ratVersion}\"|" $pass3FilePath
      sed -i "7s|.*|RAT_INPUT=\"${subOutputFilePath}/${zdabFileName}.root\"|" $pass3FilePath
      sed -i "8s|.*|RAT_OUTPUT=\"${subOutputFilePath}/${analysisFileName}\"|" $pass3FilePath
      sed -i "9s|.*|OUTPUT_PATH=\"${subOutputFilePath}\"|" $pass3FilePath
      qsub $pass3FilePath
    fi
  else
    echo ""
    echo "L2 file not found"${zdabFilePath}${zdabFileName}.zdab
  fi
done

exit 0
