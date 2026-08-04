#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N counting
#$ -e ./counting.err.txt

###############################################################################################################################################################################################
# Author:         Nynke van Eijk
# Contact:        nynke.vaneijk@radboudumc.nl

# Goal:           Extract the number of reads mapped to each repeat annotation
# Input:          ${sample}_ra_bowtie2.dedup.bam
# Output:         ${sample}_ra_bowtie2.dedup.sorted.bam
#                 ${sample}_ra_bowtie2.dedup.sorted.bam.bai
#                 ${sample}_counts.tsv
# Requires:       samtools version (Danecek P et al., GigaScience, 2021) --> CHECK!!
###############################################################################################################################################################################################

# Warning:
## We are interested in visualizing the Aedes albopictus mapped reads in IGV, therefore the follow-up scripts for the ${sample}_bowtie2.dedup.bam files are
## 5_file_format_conversion.sh and 6_merge_replicates.sh
## The repeat annotation mapped reads are used for counting and DESeq2 analysis, therefore the follow-up scripts for the ${sample}_ra_bowtie2.dedup.bam files are
## 5_counting.sh and 6_DESeq2_and_visualisation.Rmd

# Set-up
projPath="<path/to/directory>"
mkdir -p ${projPath}/counts

# List samples
List="
PROseq1_piwi6_wt
PROseq2_piwi6_wt
PROseq1_piwi6_ko10
PROseq2_piwi6_ko10
PROseq1_piwi6_ko52
PROseq2_piwi6_ko52
"

# Run samtools
for sample in ${List}
do
## Sort and index the deduplicated reads
samtools sort ${projPath}/removeDuplicate/${sample}_ra_bowtie2.dedup.bam -o ${projPath}/removeDuplicate/${sample}_ra_bowtie2.dedup.sorted.bam
samtools index ${projPath}/removeDuplicate/${sample}_ra_bowtie2.dedup.sorted.bam
## Count the number of reads mapping to each repeat annotation
samtools idxstats ${projPath}/removeDuplicate/${sample}_ra_bowtie2.dedup.sorted.bam | awk '$1!="*"{print $1"\t"$3}' > ${projPath}/counts/${sample}_counts.tsv
done
