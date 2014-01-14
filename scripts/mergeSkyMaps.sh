##/bin/tcsh -m

set file1 = $1
set file2 = $2
set output = $3
set emin = $4
set emax = $5
echo ${file1} ${file2} ${output} ${emin} ${emax}
ftcopy ${file1}+0 \!${output} copyall=NO
fimgmerge ${file1}+1 ${file2}+1 \!${output}.1 0 0
fparkey ${emin} ${output}.1+0 E_MIN
fparkey ${emax} ${output}.1+0 E_MAX
ftappend ${output}.1 ${output}
rm ${output}.1
exit

