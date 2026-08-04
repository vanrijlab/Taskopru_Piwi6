#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N deduplication
#$ -e ./deduplication.err.txt

###############################################################################################################################################################################################
# Author:              Nynke van Eijk
# Contact:             nynke.vaneijk@radboudumc.nl
# Adapted from:        Zheng Y et al (2020). Protocol.io

# Goal:                Remove duplicates from aligned CUT&Tag reads
# Input:               ${sample}_${tag}.sam
# Output:              ${sample}_${tag}.sorted.sam
#                      ${sample}_${tag}.sorted.RG.bam
#                      ${sample}_${tag}.sorted.dupMarked.sam
#                      ${sample}_${tag}_picard.dupMark.txt
#                      ${sample}_${tag}.sorted.rmDup.sam
#                      ${sample}_${tag}_picard.rmDup.txt
# Requires:            Picard version 3.3.0 (Broad Institute, 2019) - https://broadinstitute.github.io/picard/
###############################################################################################################################################################################################

# Warning:
## CUT&Tag integrates adapters into DNA near the antibody-bound pA-Tn5, and the exact sites of integration are affected by the accessibility of surrounding DNA.
## As a result, it's common for multiple fragments to share identical start and end coordinates, so these apparent 'duplicates' don't necessarily arise from PCR amplification.

# Set-up
projPath="<path/to/directory>"
## Depending on how you load picard and your server environment, the picardCMD can be different. Adjust accordingly.
picardCMD="java -jar <path/to/picard>/picard.jar"

mkdir -p ${projPath}/alignments/removeDuplicate/picard_summary

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

tags="
bowtie2
ra_bowtie2
"

# Run Picard
for sample in ${List}
do
  for tag in ${tags}
  do
  ## Sort by coordinate
  ${picardCMD} SortSam -I ${projPath}/alignments/sam/${sample}_${tag}.sam -O ${projPath}/alignments/sam/${sample}_${tag}.sorted.sam -SORT_ORDER coordinate
  ## Add read groups
  ${picardCMD} AddOrReplaceReadGroups -I ${projPath}/alignments/sam/${sample}_${tag}.sorted.sam -O ${projPath}/alignments/bam/${sample}_${tag}.sorted.RG.bam -RGID "${sample}" -RGLB lib1 -RGPL ILLUMINA -RGPU unit1 -RGSM "${sample}" -CREATE_INDEX true
  ## Mark duplicates
  ${picardCMD} MarkDuplicates -I ${projPath}/alignments/bam/${sample}_${tag}.sorted.RG.bam -O ${projPath}/alignments/removeDuplicate/${sample}_${tag}.sorted.dupMarked.sam -METRICS_FILE ${projPath}/alignments/removeDuplicate/picard_summary/${sample}_${tag}_picard.dupMark.txt
  ## remove duplicates
  ${picardCMD} MarkDuplicates -I ${projPath}/alignments/bam/${sample}_${tag}.sorted.RG.bam -O ${projPath}/alignments/removeDuplicate/${sample}_${tag}.sorted.rmDup.sam -REMOVE_DUPLICATES true -METRICS_FILE ${projPath}/alignments/removeDuplicate/picard_summary/${sample}_${tag}_picard.rmDup.txt
  done
done
