rm(list=ls())

options(stringsAsFactors=F) 

library(optparse)
library(data.table)

option_list <- list(
    make_option("--traitList", type="character",default="",
                help="path to list of phenotypes; no header"),
    make_option("--partition",type="character",default="nomosix",
                help="list of partitions for slurm (comma separated)"),
    make_option("--memPerCPU",type="integer",default=12,
                help="memory per CPU for slurm [default=12]"),
    make_option("--chromList",type="character",default="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22",
                help="list of chromosomes to replace * with, must match chr1 or 1 in VCF"),
    make_option("--time",type="character",default="12:00:00",
                help="HH:MM:SS for tine request for slurm"),
    make_option("--nThreads", type="integer", default=1,
                help="Number of threads"),
    make_option("--logOutDir", type="character",default=".",
                help="path to output folder for slurm logs"),
    make_option("--jobName",type="character",default="step2",
                help="string for slurm log prefix and to show in slurm queue"),
    make_option("--codeDir",type="character",default="",
                help="path to github repo with pipeline and code"),
    make_option("--outDir", type="character", default=".",
                help="path to the output folder"),
    make_option("--filetype",type="character",default="", help="VCF, BGEN, SAV, or DOS"),
    make_option("--bgenFile", type="character",default="",
                help="path to bgenFile, * for chromosome."),
    make_option("--bgenFileIndex", type="character",default="",
                help="path to bgenFile index file, * for chromosome."),
    make_option("--sampleFile", type="character",default="",
                help="File contains one column for IDs of samples in the bgen file, no header, * for chromosome"),
    make_option("--minMAF", type="numeric", default=0,
                help="minimum minor allele frequency for markers to be tested (highest between this and minMAC used)"),
    make_option("--minMAC",type="numeric",default=0.5,
                help="minimum minor allele count for markers to be tested (highest between this and minMAF used)"),
    make_option("--minInfo",type="numeric",default=0,
                help="minimum info score for markers to best tested"),
    make_option("--GMMATmodelFile", type="character",default="",
                help="path to the input file containing the glmm model"),
    make_option("--varianceRatioFile", type="character",default="",
                help="path to the input file containing the variance ratio"),
    make_option("--SAIGEOutputFile", type="character", default="",
                help="path to the output file containing the SAIGE test results"),
  make_option("--idstoIncludeFile",type="character", default="",
              help="path to the file with IDs to include (markerQueryFile)"),
  make_option("--idstoExcludeFile",type="character",default="",
              help="path to the file with IDs to exclude"),
  make_option("--dosageFile", type="character",
              help="path to the dosage file"),
  make_option("--dosageFileNrowSkip",type="integer",
              help="number of lines to be skipped in the dosage file"),
  make_option("--dosageFileNcolSkip",type="integer",
              help="Number of columns to be skiped in the dosage file"),
  make_option("--dosageFileChrCol",type="character",
              help="Column name for the chromosome column, only need for LOCO"),
  make_option("--savFile", type="character",default="",
              help="path to savFile, * for chromosome"),
  make_option("--savFileIndex", type="character",default="",
              help="path to savvy index file, * for chromosome"),
  make_option("--vcfFile",type="character",default="",
              help="VCF file, * for chromosome"),
  make_option("--vcfFileIndex",type="character",default="",
              help="VCF tabix file index, * for chromosome"),
  make_option("--vcfField",type="character",default="DS",
              help="genotype or dosage field"),
  make_option("--chrom",type="character",default="",
              help="chromosome string"),
  make_option("--start", type="numeric", default=1,
              help="start position"),
  make_option("--end", type="numeric", default=250000000,
              help="end position")
  )


parser <- OptionParser(usage="%prog [options]", option_list=option_list)

args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

try(if(length(which(opt == "")) > 0) stop("Missing arguments"))

# read in trait list
trait.list <- fread(opt$traitList,header=F)
colnames(trait.list) <- "NAME"


slurm.cmd <- character()
script<-paste(sep="/",opt$codeDir,"SAIGE_step2.R")
chromosomes <- strsplit(opt$chromList,",")[[1]]

for (i in 1:length(trait.list$NAME)) {
    output<-paste(sep="/",opt$outDir,paste0(trait.list[i],"_",opt$chrom))
    for (c in 1:length(chromosomes)) {
        if (opt$filetype=="BGEN"){
                                        #for all chromosomes
            stop("BGEN not supported yet\n")
                                        #opt$bgenFileIndex
                                        #opt$bgenFile
                                        #opt$idstoIncludeFile
                                        #opt$idstoExcludeFile
                                        #opt$sampleFile
            current.cmd <- paste0("sh /net/dumbo/home/anitapan/MGI/scripts/SAIGE/step2_SPATests.sh ",opt$outDir," ",trait.list$NAME[i]," ",j,"\"")
        } else if (opt$filetype=="DOS"){
            stop("Dosage files no longer supported\n")
            
        } else if (opt$filetype=="VCF"){
            vcf<-gsub("\\*",chromosomes[c],opt$vcfFile)
            index<-gsub("\\*",chromosomes[c],opt$vcfFileIndex)
            current.cmd <- paste0("jobs[",i,"]=\"/usr/bin/time -o ",opt$logOutDir,"/",opt$jobName,"_",i,".runinfo.txt -v Rscript ",script," --filetype ", opt$filetype,  " --vcfFile ", vcf," --vcfFileIndex " , index, " --vcfField  ",  opt$vcfField, " --chrom ",  chromosomes[c], " --start ",  opt$start, " --end ",  opt$end, " --GMMATmodelFile ", opt$GMMATmodelFile, " --varianceRatioFile ", opt$varianceRatioFile,"\"")
        } else if (opt$filetype=="SAV"){
            sav<-gsub("\\*",chromosomes[c],opt$savFile)
            index<-gsub("\\*",chromosomes[c],opt$savFileIndex)
            current.cmd <- paste0("jobs[",i,"]=\"/usr/bin/time -o ",opt$logOutDir,"/",opt$jobName,"_",i,".runinfo.txt -v Rscript ",script," --savFile ", sav, " --savFileIndex ", index, " --chrom ",  chromosomes[c]," --GMMATmodelFile ", opt$GMMATmodelFile, " --varianceRatioFile ", opt$varianceRatioFile,"\"")
        } else {
            stop("Please enter SAV, VCF, BGEN, or DOS as an argument for --filetype\n")
        }
        slurm.cmd<-c(slurm.cmd,current.cmd)
    }
}


for (i in 1:length(slurm.cmd)) {
  slurm.cmd[i] <- paste0("jobs[",i,"]=\"",slurm.cmd[i])
}


sbatch.cmd <- c("#!/bin/bash",
                paste0("#SBATCH --array=1-",length(slurm.cmd)),
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

