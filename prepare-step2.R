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
  make_option("--outDir", type="character",default="",
              help="path to folder containing step1 and step2 folders"),
  make_option("--analyzeX",type="logical",default=FALSE,
              help="T/F analyze X chromosome?"))

parser <- OptionParser(usage="%prog [options]", option_list=option_list)

args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

try(if(length(which(opt == "")) > 0) stop("Missing arguments"))

# read in trait list
trait.list <- fread(opt$traitList,header=F)
colnames(trait.list) <- "NAME"

slurm.cmd <- character()

if (opt$analyzeX) {
  for (i in 1:length(trait.list$NAME)) {
      current.cmd <- paste0("sh /net/dumbo/home/anitapan/MGI/scripts/SAIGE/step2_SPATests-X.sh ",opt$outDir," ",trait.list$NAME[i]," X\"")
      slurm.cmd <- c(slurm.cmd,current.cmd)
}
}

if (!opt$analyzeX) {
  for (i in 1:length(trait.list$NAME)) {
  for (j in 1:22) {
    current.cmd <- paste0("sh /net/dumbo/home/anitapan/MGI/scripts/SAIGE/step2_SPATests.sh ",opt$outDir," ",trait.list$NAME[i]," ",j,"\"")
    slurm.cmd <- c(slurm.cmd,current.cmd)
  }
}
}


for (i in 1:length(slurm.cmd)) {
  slurm.cmd[i] <- paste0("jobs[",i,"]=\"",slurm.cmd[i])
}


slurm.cmd <- c("#!/bin/bash",
paste0("#SBATCH --array=1-",length(slurm.cmd)),
"#SBATCH --job-name=step2",
"#SBATCH --partition=t2dgenes,got2d,esp,main,genesforgood,nomosix",
"#SBATCH --cpus-per-task=8",
"#SBATCH --mem-per-cpu=1000",
"#SBATCH --time=400:00:00",
paste0("#SBATCH --output=",opt$logOutDir,"/step2_%a.log"),
"declare -a jobs",
slurm.cmd,
"eval ${jobs[${SLURM_ARRAY_TASK_ID}]}")

if (opt$analyzeX) {
  write(slurm.cmd,"submit-SAIGE-step2-chrX.sh")
}

if (!opt$analyzeX) {
  write(slurm.cmd,"submit-SAIGE-step2.sh")
}