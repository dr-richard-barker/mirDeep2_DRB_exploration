#!/bin/bash

bowtie-build hsa_GCA_000001405.15_GRCh38_genomic.fna hsa_GCA_000001405.15_GRCh38_genomic
ec=`echo $?`
if [ $ec != 0 ];then
	echo An error occured, exit code $ec
fi

mapper.pl SRR950892_trimmed.fa -c -j -k TCGTATGCCGTCTTCTGCTTGT  -l 18 -m -p hsa_GCA_000001405.15_GRCh38_genomic.fna -s SRR950892_trimmed_collapsed.fa -t SRR950892_trimmed_collapsed_vs_genome.arf -v -n 
ec=`echo $?`
if [ $ec != 0 ];then
	echo An error occured, exit code $ec
fi

miRDeep2.pl SRR950892_trimmed_collapsed.fa hsa_GCA_000001405.15_GRCh38_genomic.fna SRR950892_trimmed_collapsed_vs_genome.arf mature_ut.part_hsa.fasta mature_ut_No-HSA.fa hairpin_ut.part_hsa.fasta -t Human

ec=`echo $?`
if [ $ec != 0 ];then
	echo An error occured, exit code $ec
fi

