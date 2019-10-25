#!/bin/bash -e
# Written by Mamoru Haruta

input="${1}"
cycle="${2}"
output="${1}.${2}"

#-- Usage out
if [ $# -ne 2 ]; then
    echo "-- Extract coordinate file from output --"
    echo ""
    echo "usage: `basename $0` [input] [cycle]"
    echo ""
    echo "input = Your GAMESS output dat file name"
    echo "cycle = The total cycle number you want to extract (number or 'last')"
    exit 1
fi

#-- Check whether .dat file
if echo "${input}" | grep -i ".dat" ; then
    : #Continue
else
    echo "ERROR: The data are only in \".dat\" file, not \".log\" or \".out\" file."
    echo "Aborted."
    exit 1
fi

echo "Running..."

#-- Check last cycle
lastcycle=`grep -i "icycle=" ${input} | grep -v -i "IMAGESX" | tail -n 1 | sed -r 's/^.*icycle= *([0-9]+).*$/\1/i'`
echo "This job was finished in ${lastcycle} cycles."

#-- Set cycle number to last cycle
if [ "${cycle}" = "last" ]; then
    cycle="${lastcycle}"
fi

#-- Extract cc1 data from outputfile (Single)
for line in `grep "Chem3D input in cc1 format for a movie" -n ${input} | cut -d ":" -f 1 | awk '{print $1+2}'`
do
    #echo "INFO: Reading line ${line}"
    data=`sed -n ${line}p ${input}`
    icycle=`echo ${data} | awk '{print $2}'`
    jcycle=`echo ${data} | awk '{print $4}'`
    if [ "${icycle}" -eq "${cycle}" ]; then
        nimages=`echo ${data} | awk '{print $6}'`
        natoms=`echo ${data} | awk '{print $8}'`
        nlines=`expr ${nimages} \* \( 1 + ${natoms} \)`
        startline=`expr ${line} + 1`
        endline=`expr ${line} + ${nlines}`
        echo "INFO: icycle=${icycle} jcycle=${jcycle} nimages=${nimages} natoms=${natoms}"
        sed -n ${startline},${endline}p ${input} > ${output}.cc1
        break
    fi
done

#-- Convert cc1 to xyz (Single)
cat ${output}.cc1 | cut -c 1-2,8- > tmp.cc1.$$
for i in `seq 1 ${nimages}`
do
    echo "${natoms}" >> tmp.xyz.$$
    startline=`expr 1 + \( ${i} - 1 \) \* \( 1 + ${natoms} \)`
    endline=`expr ${i} \* \( 1 + ${natoms} \)`
    #echo "INFO: startline = ${startline}"
    #echo "INFO:   endline = ${endline}"
    sed -n ${startline},${endline}p tmp.cc1.$$ >> tmp.xyz.$$
done
mv tmp.xyz.$$ ${output}.xyz
rm -f tmp.*.$$
echo "Done. Saved as ${output}.cc1 and ${output}.xyz"

#-- Extract cc1 data from outputfile (Overlap)
for line in `grep "Chem3D input in cc1 format for an overlap image" -n ${input} | cut -d ":" -f 1 | awk '{print $1+2}'`
do
    #echo "INFO: Reading line ${line}"
    data=`sed -n ${line}p ${input}`
    icycle=`echo ${data} | awk '{print $2}'`
    jcycle=`echo ${data} | awk '{print $4}'`
    if [ "${icycle}" -eq "${cycle}" ]; then
        nimages=`echo ${data} | awk '{print $6}'`
        natoms=`echo ${data} | awk '{print $8}'`
        datalines=`expr 1 + ${nimages} \* ${natoms}`
        startline=`expr ${line} + 1`
        endline=`expr ${line} + ${datalines}`
        echo "INFO: icycle=${icycle} jcycle=${jcycle} nimages=${nimages} natoms=${natoms}"
        sed -n ${startline},${endline}p ${input} > ${output}.ol.cc1
        break
    fi
done

#-- Convert cc1 to xyz (Overlap)
natoms=`expr ${natoms} \* ${nimages}`
echo "${natoms}" > ${output}.ol.xyz
cat ${output}.ol.cc1 | cut -c 1-2,8- >> ${output}.ol.xyz
echo "Done. Saved as ${output}.ol.cc1 and ${output}.ol.xyz"

