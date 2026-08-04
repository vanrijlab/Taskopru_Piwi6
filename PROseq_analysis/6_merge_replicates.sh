#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N merge_replicates
#$ -e ./merge_replicates.err.txt

###############################################################################################################################################################################################
# Author:         Nynke van Eijk
# Contact:        nynke.vaneijk@radboudumc.nl

# Goal:           Merge replicates per sample group and generate an RPM-normalized bedgraph
# Input:          ${sample}_fragment.bed
# Output:         ${group}_merged.fragments.bed
#                 ${group}_merged.RPMnormalized.bedgraph
#                 ${group}.tdf
# Requires:       bedtools version ... (Quinlan AR & Hall IM, Bioinformatics, 2010) --> CHECK!!
#                 igvtools version ...
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"
## Chromosome sizes file must be prepared in advance
## samtools faidx <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna 
## cut -f1,2 <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna.fai > Aalbo_primary.chrom.sizes
chromSizes_Aalbo_primary="<path/to/reference/genome>/Aalbo_primary.chrom.sizes"

mkdir -p ${projPath}/bed/merged
mkdir -p ${projPath}/bedgraph
mkdir -p ${projPath}/tdf

# List groups (sample_name, replicate_1, replicate_2)
declare -a SAMPLE_GROUPS=(
  "PROseq_wt	PROseq1_piwi6_wt	PROseq2_piwi6_wt"
  "PROseq_ko10	PROseq1_piwi6_ko10	PROseq2_piwi6_ko10"
  "PROseq_ko52	PROseq1_piwi6_ko52	PROseq2_piwi6_ko52"
)

# Run bedtools
for entry in "${SAMPLE_GROUPS[@]}"
do
## Parse the group name and the replicate names
read -r group rep1 rep2 <<< "${entry}"
## Concatenate and sort the two replicate fragment BED files
cat ${projPath}/bed/${rep1}_fragment.bed ${projPath}/bed/${rep2}_fragment.bed | sort -k1,1 -k2,2n > ${projPath}/bed/merged/${group}_merged.fragments.bed
## Count the total number of fragments in the merged file
total_fragments=$(wc -l < ${projPath}/bed/merged/${group}_merged.fragments.bed)
## Compute the RPM scaling factor (1,000,000 / total fragments)
scale=$(echo "1000000 / ${total_fragments}" | bc -l)
## Generate the RPM-normalized bedgraph from the merged fragments
bedtools genomecov -i ${projPath}/bed/merged/${group}_merged.fragments.bed -g ${chromSizes_Aalbo_primary} -bg -scale ${scale} > ${projPath}/bedgraph/${group}_merged.RPMnormalized.bedgraph
## Generate RPM-normalized tdf file
igvtools toTDF ${projPath}/bedgraph/${group}_merged.RPMnormalized.bedgraph ${projPath}/tdf/${group}.tdf <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna
done
