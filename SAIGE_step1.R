#!/usr/bin/Rscript

### June 2020 Anita Pandit & Brooke Wolford

### file to call step 1 of SAIGE (custom for v.39, June 2020)
options(stringsAsFactors=F)

## load R libraries
library("SAIGE",lib.loc="/net/snowwhite/home/bwolford/SAIGE")
require(optparse) #install.packages("optparse")

## print versions
print(packageVersion("SAIGE"))
print(packageVersion("SPAtest"))
print(Sys.time())
print(sessionInfo())

## set list of cmd line arguments
option_list <- list(
    make_option("--plinkFile", type="character",default="",
              help="path to plink file to be used for the kinship matrix"),
  make_option("--phenoFile", type="character", default="",
              help="path to the phenotype file, a column 'IID' is required"),
  make_option("--phenoCol", type="character", default="",
              help="coloumn name for phenotype in phenotype file, a column 'IID' is required"),
  make_option("--covarColList", type="character", default="",
              help="list of covariates (comma separated)"),
  make_option("--sampleIDColinphenoFile", type="character", default="IID",
              help="Column name of the IDs in the phenotype file [default='IID']"),
  make_option("--minMAFforGRM",type="numeric",default=0.01,
              help="minum MAF for GRM [default=0.01]"),
  make_option("--skipModelFitting", type="logical", default=FALSE,
              help="skip model fitting, [default='FALSE']"),
  make_option("--traitType", type="character", default="binary",
              help="binary/quantitative [default=binary]"),
  make_option("--outputPrefix", type="character", default="~/",
              help="path to the output files [default='~/']"),
  make_option("--numMarkers", type="integer", default=30,
              help="An integer greater than 0 Number of markers to be used for estimating the variance ratio [default=30]"),
  make_option("--nThreads", type="integer", default=16,
              help="Number of threads [default=16]"),
  make_option("--invNormalize", type="logical",default=FALSE,
              help="inverse normalize [default='FALSE']"),
  make_option("--memoryChunk",type="numeric",default=4,
              help="memory chunk [default=4]"),
  make_option("--IsOverwriteVarianceRatioFile",type="logical",default=TRUE,
              help="overwrite variance ratio file of the same name [default=TRUE]")
  
)
## list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

## check for missing arguments
try(if(length(which(opt == "")) > 0) stop("Missing arguments"))

## check which variables are default in the variant call  because not included in this script 

#covariate list 
covarCols <- strsplit(opt$covarColList,",")[[1]]

fitNULLGLMM(plinkFile=opt$plinkFile,
            phenoFile = opt$phenoFile,
            phenoCol = opt$phenoCol,
            traitType = opt$traitType,
            invNormalize = opt$invNormalize,
            covarColList = covarCols,
            qCovarCol = NULL,
            sampleIDColinphenoFile = opt$sampleIDColinphenoFile,
            minMAFforGRM=opt$minMAFforGRM,
            nThreads = opt$nThreads,
            numMarkers = opt$numMarkers,
            skipModelFitting = opt$skipModelFitting,
            outputPrefix = opt$outputPrefix,
            memoryChunk = opt$memoryChunk,
            IsOverwriteVarianceRatioFile=opt$IsOverwriteVarianceRatioFile
           )


