#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N trimming_part3
#$ -e ./trimming_part3.err.txt
#$ -pe smp 8

###############################################################################################################################################################################################
# Author:          Nynke van Eijk
# Contact:         nynke.vaneijk@radboudumc.nl

# Goal:            Cleave the first 7 nt/the 3' barcode
# Input:           ${sample}_R1_fp.fastq
# Output:          ${sample}_R1_trimmed.fastq
#                  ${sample}_R1_rc.fastq
# Requires:        fastx
#######################################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"

# List samples
List="
PROseq1_piwi6_wt
PROseq2_piwi6_wt
PROseq1_piwi6_ko10
PROseq2_piwi6_ko10
PROseq1_piwi6_ko52
PROseq2_piwi6_ko52
"

# Running script
for sample in ${List}
do
# Remove the 3' barcode (in r.c.) from the start of read1
fastx_trimmer -f 8 -v -i ${projPath}/trimmed/${sample}_R1_fp.fastq -o ${projPath}/trimmed/${sample}_R1_trimmed.fastq -Q33
# Generate the reverse complement of read1
fastx_reverse_complement -i ${projPath}/trimmed/${sample}_R1_trimmed.fastq -o ${projPath}/trimmed/${sample}_R1_rc.fastq -Q33
done
