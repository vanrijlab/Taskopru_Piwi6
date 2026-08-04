#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N file_format_conversion
#$ -e ./file_format_conversion.err.txt

###############################################################################################################################################################################################
# Author: 				Nynke van Eijk
# Contact: 				nynke.vaneijk@radboudumc.nl
# Adapted from: 		Zheng Y et al (2020). Protocol.io

# Goal: 				Convert SAM to BAM and BED formats
# Input:				${sample}_bowtie2.sorted.rmDup.sam
# Output:				${sample}_bowtie2.mapped.bam
#						${sample}_bowtie2.mapped.namesort.bam
#						${sample}_bowtie2.bed
#						${sample}_bowtie2.clean.bed
#						${sample}_bowtie2.fragments.bed
# Requires:				bedtools version 2.27.1 (Quinlan & Hall, Bioinformatics, 2010) 
#						samtools version 1.20 (Danecek et al., GigaScience, 2021)
###############################################################################################################################################################################################

# Warning:
## We are interested in visualizing the Aedes albopicutes mapped reads in IGV, therefore the follow-up scripts for the ${sample}_bowtie2.sorted.rmDup.sam files are
## 4_file_format_conversion.sh and 5_merge_replicates.sh
## The repeat annotation mapped reads are used for counting and DESeq2 analysis, therefore the follow-up scripts for the ${sample}_ra_bowtie2.sorted.RG.bam files are
## 4_counting.sh and 5_DESeq2_and_visualisation.Rmd

# Set-up
projPath="<path/to/directory>"

# List samples
List="
CnT_pol2_wt-1
CnT_pol2_wt-2
CnT_pol2_ko10-1
CnT_pol2_ko10-2
CnT_pol2_ko52-1
CnT_pol2_ko52-2
CnT_H3K9me3_wt-1
CnT_H3K9me3_wt-2
CnT_H3K9me3_ko10-1
CnT_H3K9me3_ko10-2
CnT_H3K9me3_ko52-1
CnT_H3K9me3_ko52-2
"

# Run samtools and bedtools
for sample in ${List}
do
## Filter and keep the mapped read pairs
samtools view -bS -F 0x04 ${projPath}/alignments/removeDuplicate/${sample}_bowtie2.sorted.rmDup.sam >${projPath}/alignments/bam/${sample}_bowtie2.mapped.bam
## Sort by name
samtools sort -n ${projPath}/alignments/bam/${sample}_bowtie2.mapped.bam -o ${projPath}/alignments/bam/${sample}_bowtie2.mapped.namesort.bam
## Convert into bed file format
bedtools bamtobed -i ${projPath}/alignments/bam/${sample}_bowtie2.mapped.namesort.bam -bedpe >${projPath}/alignments/bed/${sample}_bowtie2.bed
## Keep the read pairs that are on the same chromosome and fragment length less than 1000bp
awk '$1==$4 && $6-$2 < 1000 {print $0}' ${projPath}/alignments/bed/${sample}_bowtie2.bed >${projPath}/alignments/bed/${sample}_bowtie2.clean.bed
## Only extract the fragment related columns
cut -f 1,2,6 ${projPath}/alignments/bed/${sample}_bowtie2.clean.bed | sort -k1,1 -k2,2n -k3,3n  >${projPath}/alignments/bed/${sample}_bowtie2.fragments.bed
done
