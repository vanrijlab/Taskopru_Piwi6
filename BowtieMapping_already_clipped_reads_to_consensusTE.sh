#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N mapping
#$ -e ./map_err.txt
#$ -q all.q@narrativum.umcn.nl

#changed this script to only map to the consensus TE sequences from lau lab

#requires: Bowtie v0.12.7 (Langmead et al., Genome Biol, 2009, PMID:19261174)

#Bowtie Index must be prepared in advance
#Needs to be done only once
#with bowtie-build AnnotationFiles/TE_repeat_Aealb_all.fa Bowtieindex_TE_repeat_Aealb

#TE consensus fasta can be downloaded from https://laulab.bu.edu/msrg/TE_repeat_Aealb_all.fa

date=$(date +%Y%m%d)

WORKDIR=`pwd`
cd "${WORKDIR}"

#############################################
#########General settings####################
#############################################

#path to bowtie index (change for the TE sequences
index=$HOME/Consensus_Repeats_Lau_Alb/Bowtieindex_TE_repeat_Aealb/Bowtieindex_TE_repeat_Aealb

#number of max mismatches allowed
mismatch=0

echo "This script was run on $(date)
        with
        Index: "${index}"
        Max. number of mismatches: "${mismatch}"
        Results will be stored in this folder"

echo -e "\n\n"


###############################################
###mapping with already clipped files #################
###############################################


#Run for all clipped.fq files in working directory#

for files in "${WORKDIR}"/*clipped.fq; do
	INFILE="${files}"
        FILENAME=$(echo $(basename "${files}") | sed 's/\.clipped.fq$//')
	CLIPPED="${FILENAME}".clipped.fq
        #Map with bowtie
        #options:
        #-k 1 --best: for multimappers, only give one (only the best) alignment
        #-v: number of mismatches
        #-S output is SAM file
        #samtools -F 4: don't print unmapped reads

        OUTBAM="${FILENAME}"_TE.bam

        bowtie "${index}" "${CLIPPED}" --best -k 1 --threads 24 -t -v "${mismatch}" -S |\
                samtools view -Sb -F 4 - | samtools sort - -o "${OUTBAM}"

        OUTBED="${FILENAME}"_TE.bed
        bedtools bamtobed -i "${OUTBAM}" > "${OUTBED}"

done
cd "${WORKDIR}"
