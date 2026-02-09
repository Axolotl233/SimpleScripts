suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(optparse))

option_list <- list(
  make_option(c("-i","--input"), type="character", default=NULL,
              help="input file [default %default]",
              dest="input"),
  make_option(c("-s","--stat"), type="character", default="Median",
              help="statistical variable used [default %default]",
              dest="stat"),
  make_option(c("-x", "--low_depth"), type="numeric", default=50,
              help="low depth threshold, Q1 [default %default]",
              dest="low"),
  make_option(c("-y", "--high_depth"), type="numeric", default=100,
              help="high depth threshold, Q3 [default %default]",
              dest="high"),
  make_option(c("-m", "--ylim"), type="numeric", default=150,
              help="y-axis limtation depth threshold, Q4 [default %default]",
              dest="max"),
  make_option(c("-p", "--bin_index"), type="numeric", default=25,
              help="bin size for plot size [default %default, 100k]",
              dest="bin"),
  make_option(c("-c", "--cov"), action="store_true", default=FALSE,
              help="coverage plot [default %default]",
              dest="cov")
)
parser <- OptionParser(usage = "%prog -i alignments.coords -s [Median|Average] -l low -h high -m ylim [options]",option_list=option_list)
opt = parse_args(parser)

file_used = opt$input
stat_type = opt$stat
stat_thres = opt$max
stat_min = opt$low
stat_max = opt$high
plot_index =opt$bin
cov_plot = opt$cov

color = c("#9CCFA7","#6BAED6","#B39DD8","#F2B38F")
depth_level <- c("Q1","Q2","Q3","Q4")

d <- read_table(file_used,col_names = F,show_col_types = F)
if(stat_type == "Median"){
  d <- d[,c(1,2,3,5,6,7)]
}else if(stat_type == "Average"){
  d <- d[,c(1,2,3,4,6,7)]
}

colnames(d) <- c("Chr","Start","End","Stat","Coverage","Coverage_fix")

d <- d %>% mutate(
  Stat_class = case_when(
    Stat > stat_thres  ~ depth_level[4],
    Stat > stat_max & Stat <= stat_thres  ~ depth_level[3],
    Stat < stat_min ~ depth_level[1],
    TRUE ~ depth_level[2]
    )
) %>% mutate(
  Stat_new = case_when(
    Stat > stat_thres ~ stat_thres,
    TRUE ~ Stat
  )
)

Stat_class_all <- unique(d$Stat_class)
for(i in 1:length(color)){
  if(!depth_level[i] %in% Stat_class_all){
    color[i] <- NA
  }
}

d$Pos <- 1:nrow(d)
plot_w = nrow(d)/plot_index
plot_n <- paste(file_used,"pdf",sep = ".")
color <- color[!is.na(color)]

d$Medium <- (d$Start+d$End)/2
x_pos <- round(quantile(1:nrow(d),seq(0.1,0.9,0.1)),0)
x_inter <- paste(round((d$Medium[x_pos])/1000000,2), "Mb",sep = " ")

x_min <- min(d$Start) - 1
if(x_min == 0){
  x_min = paste(round(x_min,2),"Mb",sep = " ")
}else{
  x_min = paste(round(x_min/1000000,2),"Mb",sep = " ")
}
x_max <- max(d$End) + 1
x_max = paste(round(x_max/1000000,2),"Mb",sep = " ")
if(cov_plot){
  tmp_beta = (stat_thres * 0.5)/100
  d$Cov = -d$Coverage * tmp_beta
  p <- ggplot(d) +
    geom_bar(aes(x = Pos, y = Stat_new, fill = Stat_class),stat = "identity")+
    geom_line(aes(x = Pos, y = Cov),linewidth = 0.05)+
    theme_classic()+
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title.x = element_blank(),
      legend.title = element_blank()
    )+
    scale_fill_manual(values = color)+
    scale_x_continuous(breaks = c(1,x_pos,nrow(d)),labels = c(x_min,x_inter,x_max))+
    scale_y_continuous(breaks = c(0,stat_min,stat_max,stat_thres),limits = c(min(d$Cov),stat_thres),
                       sec.axis = sec_axis(~ (.), breaks = c(min(d$Cov),as.numeric(quantile(c(min(d$Cov),0),c(0.25,0.5,0.75))),0),
                                           name = "Coverage",labels = c(100,75,50,25,0)),
                       )+
    labs(y = paste(stat_type,"depth",sep = " "), title = paste(unique(d$Chr),collapse = "|"))
  ggsave(plot_n,p,width = plot_w,height = 6)
}else{
  p <- ggplot(d) +
    geom_bar(aes(x = Pos, y = Stat_new, fill = Stat_class),stat = "identity")+
    theme_classic()+
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title.x = element_blank(),
      legend.title = element_blank()
    )+
    scale_fill_manual(values = color)+
    scale_x_continuous(breaks = c(1,x_pos,nrow(d)),labels = c(x_min,x_inter,x_max))+
    scale_y_continuous(breaks = c(0,stat_min,stat_max,stat_thres),limits = c(0,stat_thres))+
    labs(y = paste(stat_type,"depth",sep = " "), title = paste(unique(d$Chr),collapse = "|"))
  ggsave(plot_n,p,width = plot_w,height = 4)
}