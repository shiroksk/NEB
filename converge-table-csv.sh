#!/bin/bash -e
# Written by Mamoru Haruta

input="${1}"
row="${2}"
output="${1}.i${2}.csv"

if [ $# -ne 2 ]; then
    echo "-- Extract Force and displacement from log file --"
    echo "usage: `basename $0` [input] [image]"
    echo ""
    echo "input = Your GAMESS output log file name"
    echo "image = The image number you want to extract or \"Maximum\"."
    exit 1
fi

#-- Get a number of images
nimages=`grep "Number of images" ${input} | grep "(IMAGES)" | head -n 1 | awk '{print $6}'` 

#-- Calc reading linse
readlines=`expr ${nimages} + 7` #row of the table

#-- Space padding etc
if [ "${row}" = "Maximum" ]; then
    row="Maximum"
else
    row="`printf '%6s\n' ${row}`"
fi

#-- Make CSV
echo "Cycles,Image,F(OPT)MAX,F(OPT)RMS,DispMAX,DispRMS" > ${output}
grep "EXAMINATION OF CONVERGENCES 2" -A ${readlines} ${input} | grep -E -i "^ *${row}" | awk '{print NR","$1","$2","$3","$4","$5}' >> ${output}

echo "Done. Saved as ${output}"

