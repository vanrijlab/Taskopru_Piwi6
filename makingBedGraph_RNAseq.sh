WORKDIR=$(pwd)
#Specify for each library the scale factor (from DEseq2 analysis). For example for the library RDVJ640, if DEseq2 scaling factor is 1.4721088:
#RDVJ640_scalefactor=1/1.4721088

#specify the scale factor variable before the for loop, and make it a command, not comment with #.

for file in ${WORKDIR}/*.bam; do
        INFILE="${file}"
        FILENAME=$(echo $(basename ${INFILE}) | sed 's/\Aligned.sortedByCoord.out.bam$//')
        scalefactor_varname="${FILENAME}_scalefactor"
 
#get the scale factor for the current file
if [[ ${!scalefactor_varname} ]]; then
        scalefactor=${!scalefactor_varname}
 
        genomeCoverageBed -ibam "${INFILE}" \
                        -g "${CHROMINFO}"  \
                        -bg \
                        -split \
                        -strand + |
                        -scale
                        sort -k1,1 -k2,2n> "${FILENAME}".plus.bedGraph
 
        bedGraphToBigWig "${FILENAME}".plus.bedGraph "${CHROMINFO}"  "${FILENAME}".plus.bw
 
 
        genomeCoverageBed -ibam "${INFILE}" \
                        -g "${CHROMINFO}"  \
                        -bg \
                        -split \
                        -strand - |
                        sort -k1,1 -k2,2n > "${FILENAME}".min.bedGraph
 
        bedGraphToBigWig "${FILENAME}".min.bedGraph "${CHROMINFO}"  "${FILENAME}".min.bw
 
 
 
 
 
 
        else
        continue
fi
echo "File : $file"
echo "Scale Factor Variable:  $scalefactor_varname"
echo "Scale Factor:  $scalefactor"
 
done

