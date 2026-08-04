#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -q all.q@narrativum.umcn.nl

#set -x
date=$(date +%Y%m%d)
WORKDIR=`pwd`
ChromInfo=$HOME/AlbCanu/AnnotationFiles/AlbCanuChromosome.info

echo "This script was run on $date in the directory $WORKDIR"

for files in "${WORKDIR}"/*.bam; do
        FILENAME=$(echo $(basename "${files}") | sed 's/\.bam$//')
        BAM="${FILENAME}".bam
	FILTERED_BAM="${FILENAME}"_filtered25-30.bam
	MIRNACOUNTS=$(\
		bedtools intersect -a $HOME/U4.4KO_rawfiles/20200928.BowtieMapping/"${FILENAME}".bed -b $HOME/U4.4_microRNAs.bed | awk 'END{print NR}')
        NormFac=$(\
                echo "scale=9; 1/ ${MIRNACOUNTS} * 1000000" | bc)
	
	printf "File: ${FILENAME}
        MIRNACOUNTS: ${MIRNACOUNTS}
        Normalization factor used: ${NormFac}"
	samtools view -h ${BAM} | awk '(length($10) <= 30 && length($10) >= 25) || $1 ~ /^@/' | samtools view -bS - > "${FILTERED_BAM}"

	bedtools genomecov -ibam "${FILTERED_BAM}" \
                -g $ChromInfo \
		-bg \
                -strand + \
                -scale ${NormFac} > ${FILENAME}.plus.bedgraph
		
	bedtools genomecov -ibam "${FILTERED_BAM}" \
                -g $ChromInfo \
		-bg \
                -strand - \
                -scale ${NormFac} > ${FILENAME}.min.bedgraph
done





