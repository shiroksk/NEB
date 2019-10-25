#!/bin/bash -e
# Written by Mamoru Haruta

input="${1}"
row="${2}"
tmp="tmp.$$."
output="${1}.data.csv"

#if [ $# -ne 1 ]; then
#    echo "-- Extract data as CSV from log file --"
#    echo "usage: `basename $0` <input> [<image>]"
#    echo ""
#    echo "<input> = Your GAMESS output log file name"
#    echo "<image> = The image number you want to extract. (Optional)"
#    echo "          "
#    exit 1
#fi

#-- Get a number of images
nimages=`grep "Number of images" ${input} | grep "(IMAGES)" | head -n 1 | awk '{print $6}'` 

#-- Check last cycle
lastcycle=`grep -i "Total cycle =" ${input} | tail -n 1 | sed -r 's/^.*Total cycle = *([0-9]+).*$/\1/i'`
echo "This job was finished in ${lastcycle} cycles."

#-- Calc reading lines
readlines=`expr ${nimages} + 7` #row of the table

#-- Make CSV
if [ "${row}" = "" ]; then

    #-- Generate cycle row
    for i in `seq 1 ${lastcycle}`
    do
        for j in `seq 1 ${nimages}`
        do
            echo "${i}" >> ${tmp}1
        done
    done
    echo "Row,Cycle," > ${tmp}2
    cat ${tmp}1 | awk '{print NR","$1","}' >> ${tmp}2
    
    #-- DATA TABLE OF DISTANCES, ENERGIES, AND FORCES
    echo "Image,Stotal[sqrt(u)*bohr],DeltaS[sqrt(u)*bohr],TotalEnergy[hartree],RelativeE[kcal/mol]," > ${tmp}3
    grep "DATA TABLE OF DISTANCES, ENERGIES, AND FORCES" -A ${readlines} ${input} | grep -E -i "^ *[0-9]+" | awk '{print $1","$2","$3","$4","$5","}' | sed -e 's/*//g' >> ${tmp}3
    
    #-- DATA TABLE OF FORCES [hartree/bohr]
    echo "F(RAW)RMS[hartree/bohr],F(OPT)RMS[hartree/bohr],F(perp)RMS[hartree/bohr],F(para)RMS[hartree/bohr],Fs(para)RMS[hartree/bohr]," > ${tmp}4
    grep "DATA TABLE OF FORCES \[hartree/bohr\]" -A ${readlines} ${input} | grep -E -i "^ *[0-9]+" | awk '{print $2","$3","$4","$5","$6","}' >> ${tmp}4
    
    #-- EXAMINATION OF CONVERGENCES [atomic units]
    echo "F(OPT)MAX[hartree/bohr],F(OPT)RMS[hartree/bohr],DispMAX[bohr],DispRMS[bohr]," > ${tmp}5
    grep "EXAMINATION OF CONVERGENCES \[atomic units\]" -A ${readlines} ${input} | grep -E -i "^ *[0-9]+" | awk '{print $2","$3","$4","$5","}' >> ${tmp}5
    
    #-- DATA TABLE OF FORCES [kcal/mol/angs]
    echo "F(RAW)RMS[kcal/mol/angs],F(OPT)RMS[kcal/mol/angs],F(perp)RMS[kcal/mol/angs],F(para)RMS[kcal/mol/angs],Fs(para)RMS[kcal/mol/angs]," > ${tmp}6
    grep "DATA TABLE OF FORCES \[kcal/mol/angs\]" -A ${readlines} ${input} | grep -E -i "^ *[0-9]+" | awk '{print $2","$3","$4","$5","$6","}' >> ${tmp}6
    
    #-- EXAMINATION OF CONVERGENCES [commonly used units]
    echo "F(OPT)MAX[kcal/mol/angs],F(OPT)RMS[kcal/mol/angs],DispMAX[angs],DispRMS[angs]" > ${tmp}7
    grep "EXAMINATION OF CONVERGENCES \[commonly used units\]" -A ${readlines} ${input} | grep -E -i "^ *[0-9]+" | awk '{print $2","$3","$4","$5}' >> ${tmp}7

else
    #-- Generate cycle row
    for i in `seq 1 ${lastcycle}`
    do
        echo "${i}" >> ${tmp}1
    done
    echo "Row,Cycle," > ${tmp}2
    cat ${tmp}1 | awk '{print NR","NR","}' >> ${tmp}2

    #-- Space padding
    row="`printf '%6s\n' ${row}`"
    
    #-- DATA TABLE OF DISTANCES, ENERGIES, AND FORCES
    echo "Image,Stotal[sqrt(u)*bohr],DeltaS[sqrt(u)*bohr],TotalEnergy[hartree],RelativeE[kcal/mol]," > ${tmp}3
    grep "DATA TABLE OF DISTANCES, ENERGIES, AND FORCES" -A ${readlines} ${input} | grep -E -i "^ *${row}" | awk '{print $1","$2","$3","$4","$5","}' | sed -e 's/*//g' >> ${tmp}3
    
    #-- DATA TABLE OF FORCES [hartree/bohr]
    echo "F(RAW)RMS[hartree/bohr],F(OPT)RMS[hartree/bohr],F(perp)RMS[hartree/bohr],F(para)RMS[hartree/bohr],Fs(para)RMS[hartree/bohr]," > ${tmp}4
    grep "DATA TABLE OF FORCES \[hartree/bohr\]" -A ${readlines} ${input} | grep -E -i "^ *${row}" | awk '{print $2","$3","$4","$5","$6","}' >> ${tmp}4
    
    #-- EXAMINATION OF CONVERGENCES [atomic units]
    echo "F(OPT)MAX[hartree/bohr],F(OPT)RMS[hartree/bohr],DispMAX[bohr],DispRMS[bohr]," > ${tmp}5
    grep "EXAMINATION OF CONVERGENCES \[atomic units\]" -A ${readlines} ${input} | grep -E -i "^ *${row}" | awk '{print $2","$3","$4","$5","}' >> ${tmp}5
    
    #-- DATA TABLE OF FORCES [kcal/mol/angs]
    echo "F(RAW)RMS[kcal/mol/angs],F(OPT)RMS[kcal/mol/angs],F(perp)RMS[kcal/mol/angs],F(para)RMS[kcal/mol/angs],Fs(para)RMS[kcal/mol/angs]," > ${tmp}6
    grep "DATA TABLE OF FORCES \[kcal/mol/angs\]" -A ${readlines} ${input} | grep -E -i "^ *${row}" | awk '{print $2","$3","$4","$5","$6","}' >> ${tmp}6
    
    #-- EXAMINATION OF CONVERGENCES [commonly used units]
    echo "F(OPT)MAX[kcal/mol/angs],F(OPT)RMS[kcal/mol/angs],DispMAX[angs],DispRMS[angs]" > ${tmp}7
    grep "EXAMINATION OF CONVERGENCES \[commonly used units\]" -A ${readlines} ${input} | grep -E -i "^ *${row}" | awk '{print $2","$3","$4","$5}' >> ${tmp}7

fi

#-- Concatenate
paste -d "\0" ${tmp}2 ${tmp}3 ${tmp}4 ${tmp}5 ${tmp}6 ${tmp}7> ${output}
rm -f ${tmp}*

echo "Done. Saved as ${output}"

