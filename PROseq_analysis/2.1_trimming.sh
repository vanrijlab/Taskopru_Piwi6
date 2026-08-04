#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N trimming_part1
#$ -e ./trimming_part1.err.txt
#$ -pe smp 8

###############################################################################################################################################################################################
# Author:          Nynke van Eijk
# Contact:         nynke.vaneijk@radboudumc.nl

# Goal:			   trim read1 and read2
# 				   read1: trim readthrough into VRA5/RPI-X 
# 				   read2: trim UMI from start and readthrough into VRA3_x/RP1
# Input:		   ${sample}_R1.fastq
#				   ${sample}_R2.fastq
# Output:		   ${sample}_R1_fp.fastq
# 				   ${sample}_R2_fp.fastq
# Requires:		   fastp version
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"
## Adapter sequences to clip. Default = Tru-Seq small RNA
ADAPTOR_1="TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC"              		### r.c. of adapter at 5' (without UMI & 5 barcode; for readthrough in read 1)
ADAPTOR_2="GATCGTCGGACTGTAGAACTCTGAACGTGTAGATCTCGGTGGTCGCCGTATCATT" 	### adapter at 3' side (without 3 barcode; for readthrough in read 2)
UMI_LEN=7 								### Length of UMI in basepairs
									###  we have 6nt +C

mkdir -p ${projPath}/trimmed

# List samples
List="
PROseq1_piwi6_wt
PROseq2_piwi6_wt
PROseq1_piwi6_ko10
PROseq2_piwi6_ko10
PROseq1_piwi6_ko52
PROseq2_piwi6_ko52
"

# Run fastp
for sample in ${List}
do
# for R1: this step will remove, only if insert size shorter than 44 - the readthrough into the UMI and adapter 1
# for R2: this step will remove, always the UMI (first 7 nt) and only if insert size shorter than 44 - also the readthrough into adapter 2 (but not yet that of the 3' barcode that actually comes before it!)
fastp -i ${projPath}/${sample}_R1.fastq -I ${projPath}/${sample}_R2.fastq --out1 ${projPath}/trimmed/${sample}_R1_fp.fastq --out2 ${projPath}/trimmed/${sample}_R2_fp.fastq --adapter_sequence $ADAPTOR_1 --adapter_sequence_r2 $ADAPTOR_2 --umi --umi_loc=read2 --umi_len=${UMI_LEN} --html ${projPath}/trimmed/${sample}_fastp_log.html -w 8 --overlap_len_require 15 2> ${projPath}/trimmed/${sample}_fastp.log
done
