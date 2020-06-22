rm(list=ls())

options(echo=TRUE, stringsAsFactors=F) # if you want see commands in output file
.libPaths( c( .libPaths(), "/net/dumbo/home/anitapan/bin/Rlibs"))

library(optparse)
library(data.table)

option_list <- list(
  make_option("--traitList", type="character",default="",
              help="path to list of phenotypes; no header"),
  make_option("--logOutDir", type="character",default="",
              help="path to output folder for logs"),
  make_option("--genoFile", type="character",default="",
              help="path to the genotype file (.bed format, filtered/pruned, autosomes only)"),
  make_option("--phenoFile", type="character",default="",
              help="path to the phenotype file"),
  make_option("--covarList",type="character",default="",
              help="comma separated list of covariate column names"),
  make_option("--sampleID", type="character", default="",
              help="column name of the sample ID"),
  make_option("--binary", type="logical", default=FALSE,
              help="whether phenotype is binary or quantitative, default is F"),
  make_option("--invNorm", type="logical", default=FALSE,
              help="whether to inverse normalize the outcome, default is F"),
  make_option("--outDir", type="character", default="",
              help="path to the output folder")
)

parser <- OptionParser(usage="%prog [options]", option_list=option_list)

args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

try(if(length(which(opt == "")) > 0) stop("Missing arguments"))

# read in trait list
trait.list <- fread(opt$traitList,header=F)
colnames(trait.list) <- "NAME"

# subset trait list to those that don't already have existing step1 results
trait.list.final <- c()

for (i in 1:length(trait.list$NAME)) {
  varFile <- paste0(opt$outDir,"/",trait.list[i],".varianceRatio.txt")
  rdaFile <- paste0(opt$outDir,"/",trait.list[i],".rda")
  if(file.info(varFile)$size == 0 & file.exists(varFile)) {
    # remove varianceRatio file (SAIGE will complain otherwise) and rerun
    file.remove(varFile)
  } else if ((file.exists(rdaFile) & file.info(rdaFile)$size==0) | file.info(varFile)$size==0 | !file.exists(rdaFile)){
    trait.list.final <- c(trait.list.final,trait.list$NAME[i])
  }
}

slurm.cmd <- character()

for (i in 1:length(trait.list.final)) {
  current.cmd <- paste0("jobs[",i,"]=\"Rscript /net/dumbo/home/anitapan/MGI/scripts/SAIGE/step1_spagmmat.R --genoFile ",opt$genoFile," --phenoFile ",opt$phenoFile," --pheno ",trait.list.final[i]," --sampleID ",opt$sampleID," --covarList ",opt$covarList," --binary ",opt$binary," --invNorm ",opt$invNorm," --outDir ",opt$outDir,"\"")
  slurm.cmd <- c(slurm.cmd,current.cmd)
}


slurm.cmd <- c("#!/bin/bash",
paste0("#SBATCH --array=1-",length(trait.list.final)),
"#SBATCH --job-name=step1",
"#SBATCH --partition=t2dgenes,got2d,esp,main,genesforgood,nomosix",
"#SBATCH --cpus-per-task=16",
"#SBATCH --mem-per-cpu=500",
"#SBATCH --time=400:00:00",
paste0("#SBATCH --output=",opt$logOutDir,"/step1_%a.log"),
"declare -a jobs",
slurm.cmd,
"eval ${jobs[${SLURM_ARRAY_TASK_ID}]}")


write(slurm.cmd,"submit-SAIGE-step1.sh")