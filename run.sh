#!/bin/bash
# Script for running all NEB jobs.

#-- rungms path
rungms="../../rungms"

#-- gamess version number
verno="00"

#-- number of process or machine file name
process="machine.lst"

for file in $(cat file.lst)
do
    echo "-- ${file} --"
    ${rungms} ${file} ${verno} ${process} > ${file}.log
done

