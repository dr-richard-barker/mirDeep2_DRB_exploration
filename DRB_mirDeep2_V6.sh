
## This script requires genome.fa, mature.fa, hairpin.fa, and smallRNAseq.fastq.gz as inputs
## This script produced quantification of known and novel microRNA's and hairpin small RNAseq as text .bed and .html file format as outputs

!/usr/bin/env bash


## install mini conda
# curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh


# source ~/.bashrc

## install mirdeep2 using mamba
# conda install -y -n base -c conda-forge mamba
# mamba create -y -n mirdeep2 -c conda-forge -c bioconda -c defaults mirdeep2

## Activate a conda environment:
# conda activate mirdeep2

##### (commented out only need to do once per genome)
## Download miRNA sequences from miRBase
# https://mirbase.org/download/CURRENT/mature.fa
# https://mirbase.org/download/CURRENT/hairpin.fa


# URL of the file to be downloaded
# URL="https://mirbase.org/download/CURRENT/hairpin.fa"

# Destination folder where you want to download the file
# DESTINATION_FOLDER="/path/to/your/folder"

# Create the destination folder if it doesn't exist
# mkdir -p "$DESTINATION_FOLDER"

# Use wget to download the file
# wget -O "${DESTINATION_FOLDER}/hairpin.fa" "$URL"

######

## Extract all hsa miRNA sequences from miRBase
# grep -A 1 --no-group-separator "^>hsa" mature_ut.fa > mature_hsa_ut.fa
## remove just hsa from the mature_ut.fa file
# grep -v "^>hsa" mature_ut.fa > mature_ut_No-HSA.fa

## removing spaces from ref genome fasta (commented out only need to do once per genome)
# sed 's/ /_/g' Homo_sapiens.GRCh38.dna.primary_assembly.fna > Homo_sapiens.GRCh38.dna.primary_assembly_no_space.fna

## making bowtie index (commented out only need to do once per genome)
#   bowtie-build (Species)_genomic_no_space.fna (Species)_genomic
#   bowtie-build Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl.fa hsa_GCA_000001405.15_GRCh38_genomic
# looping over input files based on unique part of identifiers
for sample in SRR950892 SRR950893 SRR950894 SRR950895
do

## just a notification of which sample we're on
# printf "\n\n    Working on: ${sample}\n\n"


## gunzip *.fastq.gz
# unzip ${sample}_trimmed.fq.gz


## Convert the FASTQ files to FASTA format using seqkit:
# seqkit fq2fa ${sample}_trimmed.fq.gz -o ${sample}.fa


#remove white spaces from GeneLab assembly for each species
   # remove_white_space_in_id.pl Homo_sapiens.GRCh38.dna.primary_assembly.fa > Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl.fa
   # remove_white_space_in_id.pl mature_ut_No-HSA.fa > mature_ut_No-HSA_no_whitespace.fa
   
    # # remove_white_space_in_id.pl {species}genome.fa > {species}genome_no_whitespace.fa
    # # remove_white_space_in_id.pl mature_ut_No-{species}.fa > mature_ut_No-{species}_no_whitespace.fa
    # # remove_white_space_in_id.pl hairpin_ut_No-{species}.fa > hairpin_ut_No-{species}_no_whitespace.fa

# build a bowtie index from GeneLab assembly for each species
   #bowtie-build Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl.fa Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl


# removing spaces from read fasta (this should probably be the fastq files once we know it all works, so we aren't unnecessarily adding another program to convert to fasta and do the dereplication if mirdeep2 can)
#sed 's/ /_/g' ${sample}_trimmed.fa > ${sample}_trimmed_no_spaces.fa
  
# running mapping
mapper.pl ${sample}_trimmed_no_spaces.fa -c -j -k TCGTATGCCGTCTTCTGCTTGT  -l 18 -m -p Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl -s ${sample}_trimmed_collapsed.fa -t ${sample}_trimmed_collapsed_vs_genome_no_space_pl.arf -v -n
#   mapper.pl ${sample}_trimmed_no_spaces.fa -c -j -k TCGTATGCCGTCTTCTGCTTGT  -l 18 -m -p ${spcies}_no_space_pl -s ${sample}_trimmed_collapsed.fa -t ${sample}_trimmed_collapsed_vs_genome.arf -v -n

# running mirDeep2 with target mature or hairpin templates
miRDeep2.pl ${sample}_trimmed_collapsed.fa Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl.fa ${sample}_trimmed_collapsed_vs_genome_no_space_pl.arf  mature_ut.part_hsa_no_whitespace.fasta mature_ut_No-HSA_NOWHITESPACE.fa hairpin_ut.part_hsa_no_whitespace.fasta -t Human 2>report.log

done


### Now work out how to extract counts and other useful stats from the results tables. 