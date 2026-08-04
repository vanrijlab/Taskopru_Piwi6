#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N fastqc
#$ -e ./fastqc.err.txt

###############################################################################################################################################################################################
# Author:          Nynke van Eijk
# Contact:         nynke.vaneijk@radboudumc.nl

# Goal:            Quality control of FASTQ files
# Input:           *.fastq.gz
# Output:          *_fastqc.html
#                  *_fastqc.zip
# Requires:        fastqc v0.11.7 (Andrews, 2010) - http://www.bioinformatics.babraham.ac.uk/projects/fastqc
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"
mkdir -p ${projPath}/fastq/fastQC

# Run FastQC
fastqc -q ${projPath}/fastq/*.fastq.gz -o ${projPath}/fastq/fastQC/
