#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N merge_replicates
#$ -e ./merge_replicates.err.txt

###############################################################################################################################################################################################
# Author:          Nynke van Eijk
# Contact:         nynke.vaneijk@radboudumc.nl

# Goal:            Merge replicates per sample group and generate RPM-normalized tdf files
# Input:           ${sample}_bowtie2.fragments.bed
# Output:          ${group}_merged.fragments.bed
#                  ${group}_merged.RPMnormalized.bedgraph
#                  ${group}_merged.tdf
# Requires:        samtools version 1.20 (Danecek et al., GigaScience, 2021)
#                  bedtools version 2.27.1 (Quinlan & Hall, Bioinformatics, 2010) 
#                  igvtools version 2.17.3 (Robinson et al., Nature Biotechnology, 2011)
###############################################################################################################################################################################################

# Set-up
projPath="<path/to/directory>"
## Chromosome sizes file must be prepared in advance
## samtools faidx <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna 
## cut -f1,2 <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna.fai > Aalbo_primary.chrom.sizes
chromSizes_Aalbo_primary="<path/to/reference/genome>/Aalbo_primary.chrom.sizes"

mkdir -p ${projPath}/alignments/bed/merged
mkdir -p ${projPath}/alignments/bedgraph/merged
mkdir -p ${projPath}/alignments/tdf

# List groups (sample_name, replicate_1, replicate_2)
List="
CnT_pol2_wt,CnT_pol2_wt-1,CnT_pol2_wt-2
CnT_pol2_ko10,CnT_pol2_ko10-1,CnT_pol2_ko10-2
CnT_pol2_ko52,CnT_pol2_ko52-1,CnT_pol2_ko52-2
CnT_H3K9me3_wt,CnT_H3K9me3_wt-1,CnT_H3K9me3_wt-2
CnT_H3K9me3_ko10,CnT_H3K9me3_ko10-1,CnT_H3K9me3_ko10-2
CnT_H3K9me3_ko52,CnT_H3K9me3_ko52-1,CnT_H3K9me3_ko52-2
"

# Merge replicates, compute RPM scaling factor, and generate normalized tdf files
for entry in ${List}
do
group=$(echo ${entry}  | cut -d',' -f1)
rep1=$(echo ${entry}   | cut -d',' -f2)
rep2=$(echo ${entry}   | cut -d',' -f3)
## Concatenate and sort the two replicate fragment BED files
cat ${projPath}/alignments/bed/${rep1}_bowtie2.fragments.bed ${projPath}/alignments/bed/${rep2}_bowtie2.fragments.bed | sort -k1,1 -k2,2n -k3,3n >${projPath}/alignments/bed/merged/${group}_merged.fragments.bed
## Count total fragments in the merged file
total_fragments=$(wc -l < ${projPath}/alignments/bed/merged/${group}_merged.fragments.bed)
## Compute RPM scaling factor
scale=$(echo "1000000 / ${total_fragments}" | bc -l)
## Generate RPM-normalized bedgraph
bedtools genomecov -i ${projPath}/alignments/bed/merged/${group}_merged.fragments.bed -g ${chromSizes_Aalbo_primary} -bg -scale ${scale} >${projPath}/alignments/bedgraph/merged/${group}_merged.RPMnormalized.bedgraph
## Generate RPM-normalized tdf file
igvtools toTDF ${projPath}/alignments/bedgraph/merged/${group}_merged.RPMnormalized.bedgraph ${projPath}/alignments/tdf/${group}.tdf <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna
done
