# covid19_hgi_saige
SAIGE pipeline adapted from Anita Pandit for COVID-19 Host Genetics Initiative 
Read about her pipeline here: /net/dumbo/home/anitapan/MGI/scripts/SAIGE/README.txt

## Software set up
Download [SAIGE](https://github.com/weizhouUMICH/SAIGE) from Wei Zhou
src_branch=master
repo_src_url=https://github.com/weizhouUMICH/SAIGE
git clone --depth 1 -b $src_branch $repo_src_url
R CMD INSTALL --library=SAIGE SAIGE
The latest version is loaded /net/snowwhite/home/bwolford/SAIGE

## Make a trait list
Make a trait list file that contains the names of all the traits you wish to run, each on a separate line.
e.g.
ANA_1
ANA_2
ANA_3

## Step 1 (fitNULLGLM)
Use prep-step1.R to create sbatch script that calls SAIGE_step1.R. Check the script with --help for customizable parameters and their defaults

e.g.

```
Rscript ../covid19_hgi_saige/prep-step1.R --plinkFile /net/hunt/disk2/bwolford/COVID_HGI/Willer/plink_GRM/MGI_Freeze3_HRC_hg19_allchr_pruned \
--codeDir ../covid19_hgi_saige \
--phenoFile MGI_all_data_2020_HPI4638_COVID.tab \
--covarColList "sex,birth_year,whole_cohort_PC1,whole_cohort_PC2,whole_cohort_PC3,whole_cohort_PC4,whole_cohort_PC5" \
--sampleIDColinphenoFile Encrypted_PatientID \
--traitType binary \
--outDir "." \
--traitList traitlist.txt \
--memoryChunk 2 \ 
--jobName step1

sbatch submit-SAIGE-step1.sh

```

## Step 2 (SPAGMMATtest)
Use prep-step2.R to create sbatch script that calls SAIGE_step2.R

e.g

```
Rscript ../covid19_hgi_saige/prep-step2.R --chromList 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 \
--traitList traitlist.txt \
--filetype VCF \
--vcfFile "/net/hunt/disk2/MGI_data_2/MGI_all_data_2020_HPI4638/Willer_HPI4638_HUM00094409_MGI_Freeze3_HRC_hg19_unfiltered.chr*.vcf.gz" \
--codeDir ../covid19_hgi_saige \
--vcfFileIndex "/net/hunt/disk2/MGI_data_2/MGI_all_data_2020_HPI4638/Willer_HPI4638_HUM00094409_MGI_Freeze3_HRC_hg19_unfiltered.chr*.vcf.gz.tbi" \
--GMMATmodelFile COVID.rda \
--varianceRatioFile COVID.varianceRatio.txt \
--memPerCPU 1GB \
--SAIGEOutputFile MGI \
--partition nomosix \
--time 48:00:00
--nThreads 8

--jobName step2

sbatch submit_SAIGE_step2.sh
```