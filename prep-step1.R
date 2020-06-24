### June 2020 Anita Pandit & Brooke Wolford

rm(list=ls())
options(stringsAsFactors=F)

## load R libraries 
library(optparse)
library(data.table)

option_list <- list(
    make_option("--traitList", type="character",default="",
                help="path to list of phenotypes; no header"),
    make_option("--partition",type="character",default="nomosix",
                help="list of partitions for slurm (comma separated)"),
    make_option("--memPerCPU",type="integer",default=12,
                help="memory per CPU for slurm [default=12]"),
    make_option("--time",type="character",default="12:00:00",
                help="HH:MM:SS for tine request for slurm"),
    make_option("--logOutDir", type="character",default=".",
                help="path to output folder for slurm logs"),
    make_option("--jobName",type="character",default="step1",
                help="string for slurm log prefix and to show in slurm queue"),
    make_option("--codeDir",type="character",default="",
                help="path to github repo with pipeline and code"),
    make_option("--outDir", type="character", default="",
                help="path to the output folder"),
    make_option("--plinkFile", type="character",default="",
                help="path to plink file to be used for the kinship matrix"),
    make_option("--phenoFile", type="character", default="",
                help="path to the phenotype file, a column 'IID' is required"),
    make_option("--covarColList", type="character", default="",
                help="list of covariates (comma separated)"),
    make_option("--sampleIDColinphenoFile", type="character", default="IID",
                help="Column name of the IDs in the phenotype file"),
    make_option("--minMAFforGRM",type="numeric",default=0.01,
                help="minum MAF for GRM"),
    make_option("--skipModelFitting", type="logical", default=FALSE,
                help="skip model fitting, [default='FALSE']"),
    make_option("--traitType", type="character", default="binary",
                help="binary/quantitative [default=binary]"),
    make_option("--numMarkers", type="integer", default=30,
                help="An integer greater than 0 Number of markers to be used for estimating the variance ratio [default=30]"),
    make_option("--nThreads", type="integer", default=16,
                help="Number of threads"),
    make_option("--invNormalize", type="logical",default=FALSE,
                help="inverse normalize [default='FALSE']"),
    make_option("--memoryChunk",type="numeric",default=4,
                help="memory chunk [default=4]"),
    make_option("--IsOverwriteVarianceRatioFile",type="logical",default=TRUE,
                help="overwrite variance ratio file of the same name [default=TRUE]"),
    make_option("--IsSparseKin",type="logical",default=FALSE,
                help="Is kinship matrix sparse [default=FALSE]"),
    make_option("--isCovariateTransform",type="logical",default=FALSE,
                help="Transform covariates? [default=FALSE]")
)
## list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)


## check for missing arguments
try(if(length(which(opt == "")) > 0) stop("Missing arguments"))

# read in trait list (pheno col in the phenotype file must match this)
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

#where to find script 
script<-paste(sep="/",opt$codeDir,"SAIGE_step1.R")

for (i in 1:length(trait.list.final)) {
    output<-paste(sep="/",opt$outDir,trait.list.final[i])
    current.cmd <- paste0("jobs[",i,"]=\"/usr/bin/time -o ",opt$logOutDir,"/",opt$jobName,"_",i,".runinfo.txt -v Rscript ",script," --plinkFile ",opt$plinkFile," --phenoFile ",opt$phenoFile," --phenoCol ",trait.list.final[i]," --sampleIDColinphenoFile ",opt$sampleIDColinphenoFile," --covarColList ",opt$covarColList," --traitType ",opt$traitType," --invNorm ",opt$invNorm," --minMAFforGRM ",opt$minMAFforGRM," --skipModelFitting ",opt$skipModelFitting," --IsOverwriteVarianceRatioFile ", opt$IsOverwriteVarianceRatioFile, " --IsSparseKin ", opt$IsSparseKin, " --isCovariateTransform ",opt$isCovariateTransform," --outputPrefix ", output," --numMarkers ",opt$numMarkers," --nThreads ",opt$nThreads," --memoryChunk ",opt$memoryChunk,"\"")
  slurm.cmd <- c(slurm.cmd,current.cmd)
}

cat(slurm.cmd)
sbatch.cmd <- c("#!/bin/bash",
paste0("#SBATCH --array=1-",length(trait.list.final)),
paste0("#SBATCH --job-name=",opt$jobName),
paste0("#SBATCH --partition=",opt$partition),
paste0("#SBATCH --cpus-per-task=",opt$nThreads),
paste0("#SBATCH --mem-per-cpu=",opt$memPerCPU),
paste0("#SBATCH --time=",opt$time),
paste0("#SBATCH --error=",opt$logOutDir,"/",opt$jobName,"_%a.err"),
paste0("#SBATCH --output=",opt$logOutDir,"/",opt$jobName,"_%a.out"),
"declare -a jobs",
slurm.cmd,
"eval ${jobs[${SLURM_ARRAY_TASK_ID}]}")

file<-paste0("submit_SAIGE_",opt$jobName,".sh")
write(sbatch.cmd,file)
cat("You can use the follow cmd to submit jobs to slurm.\n")
cat(paste0("sbatch ",file))
