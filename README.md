# covid19_hgi_saige
SAIGE pipeline adapted from Anita Pandit for COVID-19 Host Genetics Initiative 


## Step 0
Download (SAIGE)[https://github.com/weizhouUMICH/SAIGE] from Wei Zhou
src_branch=master
repo_src_url=https://github.com/weizhouUMICH/SAIGE
git clone --depth 1 -b $src_branch $repo_src_url
R CMD INSTALL --library=SAIGE SAIGE
The latest version is loaded /net/snowwhite/home/bwolford/SAIGE

## Step 1 (fitNULLGLM)
SAIGE_step1.R

## Step 2 (SPAGMMATtest)
SAIGE_step2.R
