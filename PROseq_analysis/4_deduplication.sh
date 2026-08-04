#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N deduplication
#$ -e ./deduplication.err.txt

###############################################################################################################################################################################################
# Author:         Nynke van Eijk
# Contact:        nynke.vaneijk@radboudumc.nl

# Goal:           Remove PCR duplicates from PRO-seq reads mapped to the Aedes albopictus genome, using the UMI present in the read name
# Input:          ${sample}_bowtie2.bam
#                 ${sample}_ra_bowtie2.bam
# Output:         ${sample}_bowtie2.sorted.bam
#                 ${sample}_bowtie2.sorted.bam.bai
#                 ${sample}_bowtie2.dedup.bam
#                 ${sample}_ra_bowtie2.sorted.bam
#                 ${sample}_ra_bowtie2.sorted.bam.bai
#                 ${sample}_ra_bowtie2.dedup.bam
# Requires:       samtools version <version> (Danecek P et al., GigaScience, 2021) --> CHECK!!
#                 UMI-tools version <version> (Smith T et al., Genome Research, 2017) --> CHECK!!
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"
mkdir -p ${projPath}/removeDuplicate

# List samples
List="
PROseq1_piwi6_wt
PROseq2_piwi6_wt
PROseq1_piwi6_ko10
PROseq2_piwi6_ko10
PROseq1_piwi6_ko52
PROseq2_piwi6_ko52
"
tags="
bowtie2
ra_bowtie2
"

# Run samtools and UMI-tools
for sample in ${List}
do
  for tag in ${tags}
  do
  ## Sort the mapped reads by coordinate
  samtools sort ${projPath}/alignments/${sample}_${tag}.bam -o ${projPath}/alignments/${sample}_${tag}.sorted.bam
  ## Index the sorted reads
  samtools index ${projPath}/alignments/${sample}_${tag}.sorted.bam
  ## Deduplicate the reads mapped to the Aedes albopictus genome
  umi_tools dedup -I ${projPath}/alignments/${sample}_${tag}.sorted.bam --paired -S ${projPath}/removeDuplicate/${sample}_${tag}.dedup.bam --umi-separator=":"
  done
done
