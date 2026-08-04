#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N file_format_conversion
#$ -e ./file_format_conversion.err.txt

###############################################################################################################################################################################################
# Author:         Nynke van Eijk
# Contact:        nynke.vaneijk@radboudumc.nl

# Goal:           Convert filtered and deduplicated read pairs from BAM to a BED file with one fragment/insert per line
# Input:          ${sample}_bowtie2.dedup.bam
# Output:         ${sample}_bowtie2.namesorted.bam
#                 ${sample}_bedpe.bed
#                 ${sample}_fragment.bed
# Requires:       samtools version ...
#                 bedtools version ...
###############################################################################################################################################################################################

# Warning:
## We are interested in visualizing the Aedes albopictus mapped reads in IGV, therefore the follow-up scripts for the ${sample}_bowtie2.dedup.bam files are
## 5_file_format_conversion.sh and 6_merge_replicates.sh
## The repeat annotation mapped reads are used for counting and DESeq2 analysis, therefore the follow-up scripts for the ${sample}_ra_bowtie2.dedup.bam files are
## 5_counting.sh and 6_DESeq2_and_visualisation.Rmd

#Set-up
projPath="<path/to/directory>"
mkdir -p ${projPath}/bed

# List samples
List="
PROseq1_piwi6_wt
PROseq2_piwi6_wt
PROseq1_piwi6_ko10
PROseq2_piwi6_ko10
PROseq1_piwi6_ko52
PROseq2_piwi6_ko52
"

# Run samtools and bedtools
for sample in ${List}
do
## Sort by read name (required for a bedpe file) and convert to a paired-end BED (bedpe) file
samtools sort -n ${projPath}/removeDuplicate/${sample}_bowtie2.dedup.bam -o ${projPath}/removeDuplicate/${sample}_bowtie2.namesorted.bam
bedtools bamtobed -i ${projPath}/removeDuplicate/${sample}_bowtie2.namesorted.bam -bedpe > ${projPath}/bed/${sample}_bedpe.bed
## Process the bedpe file back into a conventional BED file
awk -v OFS='\t' '$1 == $4 { start = ($5 < $2) ? $5 : $2; end = ($3 > $6) ? $3 : $6; print $1, start, end, $7, $8, $9}' ${projPath}/bed/${sample}_bedpe.bed | sort -k1,1 -k2,2n > ${projPath}/bed/${sample}_fragment.bed
done
