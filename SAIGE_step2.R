#!/usr/bin/Rscript


### June 2020 Anita Pandit & Brooke Wolford
### file to call step 2 of SAIGE (custom for v.39, June 2020) 

options(stringsAsFactors=F)

## load R libraries
library("SAIGE",lib.loc="/net/snowwhite/home/bwolford/SAIGE") 

## print versions
print(packageVersion("SAIGE"))
print(packageVersion("SPAtest"))
print(Sys.time())
print(sessionInfo())
require(optparse) 


option_list <- list(
  make_option("--filetype",type="character",default="", help="VCF, BGEN, SAV, or DOS"),
  make_option("--bgenFile", type="character",default="",
              help="path to bgenFile."),
  make_option("--bgenFileIndex", type="character",default="",
              help="path to bgenFile index file."),
  make_option("--sampleFile", type="character",default="",
              help="File contains one column for IDs of samples in the bgen file, no header"),
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
              help="path to savFile."),
  make_option("--savFileIndex", type="character",default="",
              help="path to savvy index file."),
  make_option("--vcfFile",type="character",default="",
              help="VCF file"),
  make_option("--vcfFileIndex",type="character",default="",
              help="VCF tabix file index"),
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


###hardcoded options
#numLinesOutput=100 
#IsOutputAFinCaseCtrl=TRUE (only for binary)

### default single variant options for the R function that are not provided as options in this script
# IsDropMissingDosages, SPAcutoff, IsSparse, IsOutputHetHomCountsinCaseCtrl, IsOutputNinCaseCtrl, LOCO, kernel

try(if(length(which(opt == "")) > 0) stop("Missing arguments"))

if (opt$filetype=="BGEN") {

    SPAGMMATtest(bgenFile=opt$bgenFile,
	     bgenFileIndex=opt$bgenFileIndex,
             sampleFile=opt$sampleFile,
             GMMATmodelFile=opt$GMMATmodelFile,
             varianceRatioFile=opt$varianceRatioFile,
             SAIGEOutputFile=opt$SAIGEOutputFile,
             idstoIncludeFile=opt$idstoIncludeFile,
             idstoExcludeFile=opt$idstoExcludeFile,
             numLinesOutput=100,
             IsOutputAFinCaseCtrl=TRUE,
             minMAC=opt$minMAC,
             minMAF=opt$minMAF
             )
    
} else if (opt$filetype=="DOS") {

    SPAGMMATtest(dosageFile=opt$dosageFile,
             dosageFileNrowSkip=opt$dosageFileNrowSkip,
             dosageFileNcolSkip=opt$dosageFileNcolSkip,
             dosageFileChrCol=opt$dosageFileChrCol,
             sampleFile=opt$sampleFile,
             GMMATmodelFile=opt$GMMATmodelFile,
             varianceRatioFile=opt$varianceRatioFile,
             SAIGEOutputFile=opt$SAIGEOutputFile,
             idstoIncludeFile=opt$idstoIncludeFile,
             numLinesOutput=100,
             IsOutputAFinCaseCtrl=TRUE,
             minMAC=opt$minMAC,
             minMAF=opt$minMAF
             )
    
} else if (opt$filetype=="VCF") {

    SPAGMMATtest(vcfFile = opt$vcfFile,
                 vcfFileIndex = opt$vcfFileIndex,
                 vcfField = opt$vcfField,
                 chrom=opt$chrom,
                 start=opt$start,
                 end=opt$end,
                 sampleFile=opt$sampleFile,
                 GMMATmodelFile=opt$GMMATmodelFile,
                 varianceRatioFile=opt$varianceRatioFile,
                 SAIGEOutputFile=opt$SAIGEOutputFile,
                 IsOutputAFinCaseCtrl=TRUE,
                 numLinesOutput=100,
                 minMAC=opt$minMAC,
                 minMAF=opt$minMAF
                 )
              

    
} else if (opt$filetype=="SAV") {

    SPAGMMATtest(savFile=opt$savFile,
                 savFileIndex=opt$savFileIndex,
                 chrom=opt$chrom,
                 minMAF=opt$minMAF,
                 sampleFile=opt$sampleFile,
                 GMMATmodelFile=opt$GMMATmodelFile,
                 varianceRatioFile=opt$varianceRatioFile,
                 SAIGEOutputFile=opt$SAIGEOutputFile,
                 IsOutputAFinCaseCtrl=TRUE,
                 numLinesOutput=100,
                 IsOutputAFinCaseCtrl=TRUE,
                 minMAC=opt$minMAC,
                 minMAF=opt$minMAF
                 )
    
} else {
    stop("Please enter SAV, VCF, BGEN, or DOS as an argument for --filetype\n")
}
  
