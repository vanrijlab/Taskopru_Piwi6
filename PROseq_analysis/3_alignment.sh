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

# Goal: 		  Map PRO-seq reads to the Aedes albopictus genome
#				  and/or the Aedes albopictus repeat annotation
# Input:		  ${sample}_R1_rc.fastq
# 				  ${sample}_R2_trimmed.fastq
# Output:		  ${sample}_allmap.bam
#				  ${sample}_bowtie2.bam
#				  ${sample}_ra_allmap.bam
#				  ${sample}_ra_bowtie2.bam
# Requires:       bowtie2 version 2.5.4 (Langmead & Salzberg, Nature methods, 2012)
#				  samtools version
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"
## Bowtie index must be prepared in advance
## bowtie2-build <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna Bowtie2index_Aalbo_primary
genome_Aalbo_primary="<path/to/reference/genome>/Bowtie2index_Aalbo_primary"
## bowtie2-build <path/to/repeat/annotation>/TE_repeat_Aal_combined_with_AalERV1region.fa Bowtie2index_repeat_annotation
repeat_annotation="<path/to/repeat/annotation>/Bowtie2index_repeat_annotation"

mkdir -p ${projPath}/alignments

# List samples
List="
PROseq1_piwi6_wt
PROseq2_piwi6_wt
PROseq1_piwi6_ko10
PROseq2_piwi6_ko10
PROseq1_piwi6_ko52
PROseq2_piwi6_ko52
"

# Run Bowtie2
for sample in ${List}
do
## Mapping total reads to total Aedes albopictus genome
bowtie2 -p8 -q --end-to-end --very-sensitive --ff --dovetail -x ${genome_Aalbo_primary} -1 ${projPath}/trimmed/${sample}_R1_rc.fastq -2 ${projPath}/trimmed/${sample}_R2_trimmed.fastq | samtools view -S -b '-' > ${projPath}/alignments/${sample}_allmap.bam
# Filtering of the bam file
samtools view -b -hf 0x2 ${projPath}/alignments/${sample}_allmap.bam > ${projPath}/alignments/${sample}_bowtie2.bam

## Mapping total reads to repeat annotation
bowtie2 -p8 -q --end-to-end --very-sensitive --ff --dovetail -x ${repeat_annotation} -1 ${projPath}/trimmed/${sample}_R1_rc.fastq -2 ${projPath}/trimmed/${sample}_R2_trimmed.fastq | samtools view -S -b '-' > ${projPath}/alignments/${sample}_ra_allmap.bam
## Filtering of the bam file
samtools view -b -hf 0x2 ${projPath}/alignments/${sample}_ra_allmap.bam > ${projPath}/alignments/${sample}_ra_bowtie2.bam
done
