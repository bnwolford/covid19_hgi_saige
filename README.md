# covid19_hgi_saige
SAIGE pipeline adapted from Anita Pandit for COVID-19 Host Genetics Initiative 
Read about her pipeline here: /net/dumbo/home/anitapan/MGI/scripts/SAIGE/README.txt

## Software set up
Download (SAIGE)[https://github.com/weizhouUMICH/SAIGE] from Wei Zhou
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
Use prep-step1.R  to create sbatch script that calls SAIGE_step1.R

e.g.

```

sbatch submit-SAIGE-step1.sh

```

## Step 2 (SPAGMMATtest)
Use prep-step2.R to create sbatch script that calls SAIGE_step2.R

e.g

```
sbatch submit-SAIGE-step2.sh
```