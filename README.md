## These are adapted by DRB to install and run mirDeep2
The miRDeep2 tutorial can be found here -> https://drmirdeep.github.io/mirdeep2_tutorial.html

### Use the files from the mirdeep2_patch repository as they are a updated version of mirdeep2 scripts which improve performance
To get files from this repository do 
git clone https://github.com/Drmirdeep/mirdeep2_patch.git

The original release packages of miRDeep2 are available at
https://github.com/rajewsky-lab/mirdeep2

## Script overview
This script requires genome.fa, mature.fa, hairpin.fa, and smallRNAseq.fastq.gz as inputs.
This script produced quantification of known and novel microRNA's and hairpin small RNAseq as text .bed and .html file format as outputs.
This script is designed to provide commonents for a bash command executed via a .sh script. 
``
!/usr/bin/env bash
``

## install mini conda
curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
source ~/.bashrc

## install mirdeep2 using mamba
```
conda install -y -n base -c conda-forge mamba
mamba create -y -n mirdeep2 -c conda-forge -c bioconda -c defaults mirdeep2
```

## Activate a conda environment:
```
conda activate mirdeep2
```

## Download miRNA sequences from miRBase (only need to do once per genome)
https://mirbase.org/download/CURRENT/mature.fa
https://mirbase.org/download/CURRENT/hairpin.fa

## URL of the file to be downloaded
```
URL="https://mirbase.org/download/CURRENT/hairpin.fa"
```

## Destination folder where you want to download the file
```
DESTINATION_FOLDER="/path/to/your/folder"
```

## Create the destination folder if it doesn't exist
```
mkdir -p "$DESTINATION_FOLDER"
```

## Use wget to download the file
```
wget -O "${DESTINATION_FOLDER}/hairpin.fa" "$URL"
```

## Extract all hsa miRNA sequences from miRBase
```
grep -A 1 --no-group-separator "^>hsa" mature_ut.fa > mature_hsa_ut.fa
```

## remove just hsa from the mature_ut.fa file
```
grep -v "^>hsa" mature_ut.fa > mature_ut_No-HSA.fa
```

--- 

## Get you reference species genome from NCBI or your favourite repo
Human: https://www.ncbi.nlm.nih.gov/genome/guide/human/

Arabidopsis: https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001735.3/

etc...

## make bowtie index (only need to do once per genome) this is slow and can take some time. 
```
bowtie-build (Species)_genomic_no_space.fna (Species)_genomic
```

### Human example
```
bowtie-build Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl.fa Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl
```

---

## remove "spaces" from ref genome fasta is required by mirDeep2 ( only need to do once per genome)
```
sed 's/ /_/g' genome.fna > genome.fna
```

### Human example
```
sed 's/ /_/g' Homo_sapiens.GRCh38.dna.primary_assembly.fna > Homo_sapiens.GRCh38.dna.primary_assembly_no_space.fna
```

## Raw FastQC
Install SRA tool bench For Mac OS X, (or use wget if you prefer)
```
curl --output sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-mac64.tar.gz
```

### Human example
eg Get samples from SRA 
```
prefetch SRR950892
prefetch SRR950893
prefetch SRR950894
prefetch SRR950895
 
fastq-dump SRR950892
fastq-dump SRR950893
fastq-dump SRR950894
fastq-dump SRR950895 
```

## Pre-processing steps recommended but no code here
TrimGalore.
Post-trim FastX QC analysis.
Kraken2 is a tool for evaluating the degree of contamination in the individual samples and produces html reports for each sample.

## looping over input files based on unique part of identifiers for accuracy test 
### Human example
Note: this bottom section can be converted into a loop / .sh command
for sample in SRR950892 SRR950893 SRR950894 SRR950895
#do

## just a notification of which sample we're on
```
print f "\n\n    Working on: ${sample}\n\n"
```

## gunzip *.fastq.gz
```
gunzip ${sample}.gz
```

## remove_white_space script is required to get the quantification tool to function
```
remove_white_space_in_id.pl ${sample} > ${sample}_trimmed_no_whitespace_pl.fastq
```

## Convert the FASTQ files to FASTA format using seqkit:
```
seqkit fq2fa ${sample}_trimmed.fq.gz -o ${sample}.fa
```

## remove white spaces from GeneLab assembly for each species (I recommend using the current "GeneLab" genome)
```
remove_white_space_in_id.pl {species}genome.fa > {species}genome_no_whitespace.fa
remove_white_space_in_id.pl mature_ut_No-{species}.fa > mature_ut_No-{species}_no_whitespace.fa
remove_white_space_in_id.pl hairpin_ut_No-{species}.fa > hairpin_ut_No-{species}_no_whitespace.fa
```

### Human example
```
remove_white_space_in_id.pl Homo_sapiens.GRCh38.dna.primary_assembly.fa > Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl.fa
remove_white_space_in_id.pl mature_ut_No-HSA.fa > mature_ut_No-HSA_no_whitespace.fa
```

# removing spaces from read fasta (this could probably be the fastq files)
```
sed 's/ /_/g' ${sample}_trimmed.fa > ${sample}_trimmed_no_spaces.fa
```

# running mapping replace sample with file (eg SRR950892) name or use in .sh lopp 
```
mapper.pl ${sample}_trimmed_no_spaces.fa -c -j -k TCGTATGCCGTCTTCTGCTTGT  -l 18 -m -p ${spcies}_no_space_pl -s ${sample}_trimmed_collapsed.fa -t ${sample}_trimmed_collapsed_vs_genome.arf -v -n
```

### Human example
```
mapper.pl ${sample}_trimmed_no_whitespace_pl.fastq -e -h -j -k TCGTATGCCGTCTTCTGCTTGT  -l 18 -m -p Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl -s ${sample}_trimmed_collapsed.fa -t ${sample}2_trimmed_collapsed_vs_genome_no_space_pl.arf -v -n 
```

# running mirDeep2 with target mature or hairpin templates
```
miRDeep2.pl ${sample}_trimmed_collapsed.fa Homo_sapiens.GRCh38.dna.primary_assembly_no_space_pl.fa ${sample}_trimmed_collapsed_vs_genome_no_space_pl.arf  mature_ut.part_hsa_no_whitespace.fasta mature_ut_No-HSA_NOWHITESPACE.fa hairpin_ut.part_hsa_no_whitespace.fasta -t Human 2>report.log
```

--- 

## This script worked and produced an accurate quantification of known microRNA's and predicted detection of some new/novel microRNA's and hairpins. 
Now to work out how to extract counts and other useful stats from the results tables. 


Please cite
Friedlaender M.R.; Mackowiak S.D.; Li N.; Chen W.; Rajewsky N. 
miRDeep2 accurately identifies known and hundreds of novel microrna genes in seven animal clades, Nucleic Acids Research, vol. 40, pp. 37–52, Jan 2012
when using miRDeep2 in a publication.
