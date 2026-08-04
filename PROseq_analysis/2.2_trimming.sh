#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N trimming_part2
#$ -e ./trimming_part2.err.txt
#$ -pe smp 8

###############################################################################################################################################################################################
# Author:          Nynke van Eijk
# Contact:         nynke.vaneijk@radboudumc.nl

# Goal:            trim readthrough into sample-specific 3' barcode
# Input:           ${sample}_R2_fp.fastq (part1)
# Output:          ${sample}_R2_trimmed.fastq
# Requires:        cutadapt version 
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"

# Define parameters
        # I used VRA3_1 so coming from read 2 that reads as GAUCACG --> GATCACGX
declare -A barcodes
barcodes["PROseq1_piwi6_wt"]="GATCACGX"                  #VRA3_1 at the 3' side
barcodes["PROseq2_piwi6_wt"]="GATCACGX"                  #VRA3_1 at the 3' side
barcodes["PROseq1_piwi6_ko10"]="GATCACGX"                #VRA3_1 at the 3' side
barcodes["PROseq2_piwi6_ko10"]="GATCACGX"                #VRA3_1 at the 3' side
barcodes["PROseq1_piwi6_ko52"]="GATCACGX"                #VRA3_1 at the 3' side
barcodes["PROseq2_piwi6_ko52"]="GATCACGX"                #VRA3_1 at the 3' side

# List samples
List="
PROseq1_piwi6_wt
PROseq2_piwi6_wt
PROseq1_piwi6_ko10
PROseq2_piwi6_ko10
PROseq1_piwi6_ko52
PROseq2_piwi6_ko52
"

# Run cutadapt
for sample in ${List}
do
# Remove the 7 nt long 3' barcode arising in read2 from readthrough/for short inserts
barcode="${barcodes[${sample}]}"
cutadapt -a ${barcode} -o ${projPath}/trimmed/${sample}_R2_trimmed.fastq ${projPath}/trimmed/${sample}_R2_fp.fastq
done
