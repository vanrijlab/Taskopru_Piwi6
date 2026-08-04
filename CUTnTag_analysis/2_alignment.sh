#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N alignment
#$ -e ./alignment.err.txt
#$ -pe smp 8

###############################################################################################################################################################################################
# Author:         Nynke van Eijk
# Contact:        nynke.vaneijk@radboudumc.nl
# Adapted from:   Zheng Y et al (2020). Protocol.io

# Goal:           Map CUT&Tag reads to the Aedes albopictus genome
#                 and/or the Aedes albopictus repeat annotation
# Input:          *.fastq.gz
# Output:         ${sample}_bowtie2.sam
#                 ${sample}_bowtie2.txt
#Requires:        bowtie2 version 2.5.4 (Langmead & Salzberg, Nature methods, 2012)
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"
## Bowtie index must be prepared in advance
## bowtie2-build <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna Bowtie2index_Aalbo_primary
genome_Aalbo_primary="<path/to/reference/genome>/Bowtie2index_Aalbo_primary"
## bowtie2-build <path/to/repeat/annotation>/TE_repeat_Aal_combined_with_AalERV1region.fa Bowtie2index_repeat_annotation
repeat_annotation="<path/to/repeat/annotation>/Bowtie2index_repeat_annotation"

mkdir -p ${projPath}/alignments/sam/bowtie2_summary
mkdir -p ${projPath}/alignments/bam
mkdir -p ${projPath}/alignments/bed
mkdir -p ${projPath}/alignments/bedgraph

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

# Run Bowtie2
for sample in ${List}
do
## Mapping total reads to total aedes albopictus genome
bowtie2 --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p 8 -x ${genome_Aalbo_primary} -1 ${projPath}/fastq/${sample}_R1.fastq.gz -2 ${projPath}/fastq/${sample}_R2.fastq.gz -S ${projPath}/alignments/sam/${sample}_bowtie2.sam &> ${projPath}/alignments/sam/bowtie2_summary/${sample}_bowtie2.txt
## Mapping total reads to repeat annotation
bowtie2 --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p 8 -x ${repeat_annotation} -1 ${projPath}/fastq/${sample}_R1.fastq.gz -2 ${projPath}/fastq/${sample}_R2.fastq.gz -S ${projPath}/alignments/sam/${sample}_ra_bowtie2.sam &> ${projPath}/alignments/sam/bowtie2_summary/${sample}_ra_bowtie2.txt
done
