#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N counting
#$ -e ./counting.err.txt

###############################################################################################################################################################################################
# Author: 				Nynke van Eijk
# Contact: 				nynke.vaneijk@radboudumc.nl

# Goal: 				Extract the number of reads mapped to each repeat annotation
# Input:				${sample}_ra_bowtie2.sorted.RG.bam
# Output:				${sample}_counts.tsv
# Requires:				samtools version 1.20 (Danecek et al., GigaScience, 2021)
###############################################################################################################################################################################################

# Warning:
## We are interested in visualizing the Aedes albopicutes mapped reads in IGV, therefore the follow-up scripts for the ${sample}_bowtie2.sorted.rmDup.sam files are
## 4_file_format_conversion.sh and 5_merge_replicates.sh
## The repeat annotation mapped reads are used for counting and DESeq2 analysis, therefore the follow-up scripts for the ${sample}_ra_bowtie2.sorted.RG.bam files are
## 4_counting.sh and 5_DESeq2_and_visualisation.Rmd

# Set-up
projPath="<path/to/directory>"
mkdir -p ${projPath}/alignments/counts

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

# Run samtools
for sample in ${List}
do
## Count the number of reads mapping to each repeat annotation
### note: BAM is already sorted and indexed by Picard, so go straight to counting
samtools idxstats ${projPath}/alignments/bam/${sample}_ra_bowtie2.sorted.RG.bam | awk '$1!="*"{print $1"\t"$3}' > ${projPath}/alignments/counts/${sample}_counts.tsv
done
