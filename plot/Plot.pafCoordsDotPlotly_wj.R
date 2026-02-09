#!/usr/bin/env Rscript
rm(list = ls())
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(viridis))

option_list <- list(
  make_option(c("-i","--input"), type="character", default=NULL,
              help="coords file from mummer program 'show.coords' [default %default]",
              dest="input_filename"),
  make_option(c("-o","--output"), type="character", default="out",
              help="output filename prefix [default %default]",
              dest="output_filename"),
  make_option(c("-m", "--min-alignment-length"), type="numeric", default=10000,
              help="filter alignments with match block less than cutoff X bp [default %default]",
              dest="min_align"),
  make_option(c("-p","--plot-size"), type="numeric", default=15,
              help="plot size X by X inches [default %default]",
              dest="plot_size"),
  make_option(c("-r", "--reference-ids"), type="character", default=NULL,
              help="comma-separated list of reference IDs to keep [default %default]",
              dest="refIDs"),
  make_option(c("-q", "--query-ids"), type="character", default=NULL,
              help="comma-separated list of query IDs to keep [default %default]",
              dest="queryIDs"),
  make_option(c("-x", "--min-query-length"), type="numeric", default=1000000,
              help="filter alignments with query less than cutoff X bp [default %default]",
              dest="min_query_len"),
  make_option(c("-y", "--min-reference-length"), type="numeric", default=1000000,
              help="filter alignments with query less than cutoff X bp [default %default]",
              dest="min_ref_len")
)

options(error=traceback)
parser <- OptionParser(usage = "%prog -i alignments.coords -o out [options]",option_list=option_list)
opt = parse_args(parser)

alignments = read.table(opt$input_filename, stringsAsFactors = F, fill = T)
#alignments = read.table("Bdist_Bstac.filter.paf", stringsAsFactors = F, fill = T)[,1:12]
colnames(alignments)[1:12] = c("queryID","queryLen","queryStart","queryEnd","strand","refID","refLen","refStart","refEnd","numResidueMatches","lenAln","mapQ")

alignments = alignments[which(alignments$lenAln > opt$min_align),]
alignments = alignments[which(alignments$queryLen > opt$min_query_len),]
alignments = alignments[which(alignments$refLen > opt$min_ref_len),]
alignments$percentID = alignments$numResidueMatches / alignments$lenAln

queryStartTemp = alignments$queryStart
alignments$queryStart[which(alignments$strand == "-")] <-  alignments$queryEnd[which(alignments$strand == "-")]
alignments$queryEnd[which(alignments$strand == "-")] <- queryStartTemp[which(alignments$strand == "-")]
rm(queryStartTemp)

if(is.null(opt$queryIDs)){
  alignments <- alignments[order(alignments$queryID,alignments$queryStart),]
  alignments$queryID <- factor(alignments$queryID,levels = sort(unique(alignments$queryID)))
} else {
  queryIDsToKeepOrdered = unlist(strsplit(opt$queryIDs, ","))
  alignments = alignments[which(alignments$queryID %in% queryIDsToKeepOrdered),]
  alignments$queryID <- factor(alignments$queryID,levels = queryIDsToKeepOrdered)
}

if(!is.null(opt$refIDs)){
  refIDsToKeepOrdered = unlist(strsplit(opt$refIDs, ","))
  alignments = alignments[which(alignments$refID %in% refIDsToKeepOrdered),]
  alignments$refID <- factor(alignments$refID,levels = refIDsToKeepOrdered)
}

chromMax_query = tapply(alignments$queryLen, alignments$queryID, max)
if(length(unique(alignments$queryID)) > 1){
  alignments$queryStart2 = alignments$queryStart + sapply(as.character(alignments$queryID), function(x) ifelse(x == names((chromMax_query))[1], 0, cumsum(as.numeric(chromMax_query))[match(x, names(chromMax_query)) - 1]) )
  alignments$queryEnd2 = alignments$queryEnd + sapply(as.character(alignments$queryID), function(x) ifelse(x == names((chromMax_query))[1], 0, cumsum(as.numeric(chromMax_query))[match(x, names(chromMax_query)) - 1]) )
} else {
  alignments$queryStart2 = alignments$queryStart
  alignments$queryEnd2 = alignments$queryEnd
}

chromMax_ref = tapply(alignments$refLen, alignments$refID, max)
if(length(unique(alignments$refID)) > 1){
  alignments$refStart2 = alignments$refStart + sapply(as.character(alignments$refID), function(x) ifelse(x == names((chromMax_ref))[1], 0, cumsum(as.numeric(chromMax_ref))[match(x, names(chromMax_ref)) - 1]) )
  alignments$refEnd2 = alignments$refEnd + sapply(as.character(alignments$refID), function(x) ifelse(x == names((chromMax_ref))[1], 0, cumsum(as.numeric(chromMax_ref))[match(x, names(chromMax_ref)) - 1]) )
} else {
  alignments$refStart2 = alignments$refStart
  alignments$refEnd2 = alignments$refEnd
}

yTickMarks <- cumsum(chromMax_query)
xTickMarks <- cumsum(chromMax_ref)

gp <- ggplot(alignments) +
  #geom_point(mapping = aes(x = refStart2, y = queryStart2, color = percentID),size = 0.009)+ 
  #geom_point(mapping = aes(x = refEnd2, y = queryEnd2, color = percentID),size = 0.009)+
  geom_segment(
    aes(
      x = refStart2,
      xend = refEnd2,
      y = queryStart2,
      yend = queryEnd2,
      color = percentID,
      ),linewidth = 0.005
    )+
  scale_x_continuous(
    breaks = c(0,xTickMarks),
    labels = c("",names(xTickMarks))
    )+
  theme_bw()+
  theme(
    panel.grid.minor.y = element_blank(),
    panel.grid.minor.x = element_blank()
    )+
  scale_y_continuous(
    breaks = c(0,yTickMarks), 
    labels = c("",names(yTickMarks))
    )+
  scale_color_viridis_c() +
  xlab("Target") +
  ylab("Query")

ggsave(filename = paste0(opt$output_filename, ".pdf"),gp,width = opt$plot_size, height = opt$plot_size)
