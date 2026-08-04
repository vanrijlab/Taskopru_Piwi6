#!/bin/bash -l
#$ -S /bin/bash
#$ -cwd
#$ -V
#$ -N file_format_conversion
#$ -e ./file_format_conversion.err.txt
 
###############################################################################################################################################################################################
# Author:          Nynke van Eijk
# Contact:         nynke.vaneijk@radboudumc.nl
 
# Goal:            Select 25-30 nt reads (piRNA size range) and generate strand-specific, RPM-normalized tdf files for visualisation in IGV
# Input:           ${sample}.bam
# Output:          ${sample}_filtered.bam
#                  ${sample}_filtered.bam.bai
#                  ${sample}_filtered.bed
#                  ${sample}_filtered_pl.bedgraph / ${sample}_filtered_mn.bedgraph
#                  ${sample}_filtered_pl.RPMnormalized.bedgraph / ${sample}_filtered_mn.RPMnormalized.bedgraph
#                  ${sample}_filtered_pl.tdf / ${sample}_filtered_mn.tdf
# Requires:        samtools version 1.9 (Danecek et al., GigaScience, 2021) -->CHECK!!
#                  bedtools version 2.27.1 (Quinlan & Hall, Bioinformatics, 2010) -->CHECK!!
#                  igvtools version 2.17.3 (Robinson et al., Nature Biotechnology, 2011) -->CHECK!!
###############################################################################################################################################################################################
 
# Set-up
projPath="<path/to/directory>"
## Chromosome sizes file must be prepared in advance
## samtools faidx <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna
## cut -f1,2 <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna.fai > Aalbo.chrom.sizes
chromSizes_Aalbo_primary="<path/to/reference/genome>/Aalbo.chrom.sizes"
 
## Minimum and maximum read length to keep
minLength=25
maxLength=30
 
mkdir -p ${projPath}/BowtieMapping/filtered/bam
mkdir -p ${projPath}/BowtieMapping/filtered/bed
mkdir -p ${projPath}/BowtieMapping/filtered/bedgraph
mkdir -p ${projPath}/BowtieMapping/filtered/tdf
 
# List samples
List="
sRNA_gfp_IP
sRNA_piwi6_IP
"
 
# Run samtools, bedtools and igvtools
for sample in ${List}
do
## Keep the reads within the selected length range, then sort and index
samtools view -h ${projPath}/BowtieMapping/bam/${sample}.bam | awk -v min=${minLength} -v max=${maxLength} 'BEGIN{OFS="\t"} /^@/ {print; next} {if (length($10) >= min && length($10) <= max) print}' | samtools view -Sb - | samtools sort - -o ${projPath}/BowtieMapping/filtered/bam/${sample}_filtered.bam
samtools index ${projPath}/BowtieMapping/filtered/bam/${sample}_filtered.bam
## Convert the filtered bam into bed file format
bedtools bamtobed -i ${projPath}/BowtieMapping/filtered/bam/${sample}_filtered.bam >${projPath}/BowtieMapping/filtered/bed/${sample}_filtered.bed
## Split by strand and compute the coverage per strand
awk '$6=="+"' ${projPath}/BowtieMapping/filtered/bed/${sample}_filtered.bed | bedtools genomecov -i stdin -bg -g ${chromSizes_Aalbo_primary} >${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_pl.bedgraph
awk '$6=="-"' ${projPath}/BowtieMapping/filtered/bed/${sample}_filtered.bed | bedtools genomecov -i stdin -bg -g ${chromSizes_Aalbo_primary} >${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_mn.bedgraph
## Count total filtered reads and compute the RPM scaling factor
total_reads=$(wc -l < ${projPath}/BowtieMapping/filtered/bed/${sample}_filtered.bed)
scale=$(echo "1000000 / ${total_reads}" | bc -l)
## Generate the RPM-normalized bedgraphs
awk -v scale=${scale} 'BEGIN{OFS="\t"} {print $1, $2, $3, $4*scale}' ${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_pl.bedgraph >${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_pl.RPMnormalized.bedgraph
awk -v scale=${scale} 'BEGIN{OFS="\t"} {print $1, $2, $3, $4*scale}' ${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_mn.bedgraph >${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_mn.RPMnormalized.bedgraph
## Generate the RPM-normalized tdf files
igvtools toTDF ${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_pl.RPMnormalized.bedgraph ${projPath}/BowtieMapping/filtered/tdf/${sample}_filtered_pl.tdf <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna
igvtools toTDF ${projPath}/BowtieMapping/filtered/bedgraph/${sample}_filtered_mn.RPMnormalized.bedgraph ${projPath}/BowtieMapping/filtered/tdf/${sample}_filtered_mn.tdf <path/to/reference/genome>/GCF_006496715.1_Aalbo_primary.1_genomic.fna
done
