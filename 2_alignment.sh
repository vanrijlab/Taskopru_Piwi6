#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N alignment
#$ -e ./alignment.err.txt
#$ -pe smp 8
 
###############################################################################################################################################################################################
# Author:          Nynke van Eijk
# Contact:         nynke.vaneijk@radboudumc.nl
 
# Goal:            Clip adapters from small RNA sequencing reads and map them to the Aedes albopictus genome
# Input:           ${sample}_R1.fastq.gz
# Output:          ${sample}.clipped.fq (temporary)
#                  ${sample}.bam
#                  ${sample}.bed
#                  ${sample}_bowtie.txt
# Requires:        cutadapt version 1.14 (Martin, EMBnet.journal, 2011) -->CHECK!!
#                  bowtie version 0.12.7 (Langmead et al., Genome Biology, 2009) --> CHECK!!
#                  samtools version 1.9 (Danecek et al., GigaScience, 2021) --> CHECK!!
#                  bedtools version 2.27.1 (Quinlan & Hall, Bioinformatics, 2010) --> CHECK!!
###############################################################################################################################################################################################
 
# Warning:
## Make sure the adapter below matches the kit that was used to prepare the libraries.
## Reads are length-filtered to 15-35 nt here; the 25-30 nt piRNA window is selected in 3_filtering_and_normalisation.sh
 
# Set-up
projPath="<path/to/directory>"
## Bowtie index must be prepared in advance
## bowtie-build <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna BowtieIndex_Aalbo_primary
genome_Aalbo_primary="<path/to/reference/genome>/BowtieIndex_Aalbo_primary"

## Adapter to be clipped from the reads. 
## adapter NEBNext
adapter="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
 
## Maximum number of mismatches allowed during mapping
mismatch=0
## Number of threads; keep in line with the -pe smp value in the header
threads=8
 
mkdir -p ${projPath}/BowtieMapping/bam
mkdir -p ${projPath}/BowtieMapping/bed
mkdir -p ${projPath}/BowtieMapping/tmp
mkdir -p ${projPath}/BowtieMapping/bowtie_summary
 
# List samples
List="
sRNA_gfp_IP
sRNA_piwi6_IP
"
 
# Run cutadapt, bowtie, samtools and bedtools
for sample in ${List}
do
## Clip the adapter and keep reads of 15-35 nt that were successfully trimmed
gunzip -c ${projPath}/fastq/${sample}_R1.fastq.gz | cutadapt -a ${adapter} -m 15 -M 35 --discard-untrimmed - >${projPath}/BowtieMapping/tmp/${sample}.clipped.fq
## Map with bowtie, reporting only the best alignment for multimappers, and keep the mapped reads only
bowtie ${genome_Aalbo_primary} ${projPath}/BowtieMapping/tmp/${sample}.clipped.fq --best -k 1 --threads ${threads} -t -v ${mismatch} -S 2>${projPath}/BowtieMapping/bowtie_summary/${sample}_bowtie.txt | samtools view -Sb -F 4 - | samtools sort - -o ${projPath}/BowtieMapping/bam/${sample}.bam
## Convert into bed file format
bedtools bamtobed -i ${projPath}/BowtieMapping/bam/${sample}.bam >${projPath}/BowtieMapping/bed/${sample}.bed
done
 
# Clean up the clipped fastq files
rm -r ${projPath}/BowtieMapping/tmp
