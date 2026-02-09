suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(patchwork))

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
              help="bin size for plot size [default %default]",
              dest="bin"),
  make_option(c("-c", "--cov"), action="store_true", default=FALSE,
              help="coverage plot [default %default]",
              dest="cov"),
  make_option(c("-t", "--cov_thres"), type="numeric", default=-1,
              help="coverage threshold [default %default]",
              dest="covmin")
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
cov_thres = opt$covmin

color = c("#9CCFA7","#6BAED6","#B39DD8","#F2B38F")
depth_level <- c("Q1","Q2","Q3","Q4")

d <- read_table(file_used,col_names = F,show_col_types = F)
if(stat_type == "Median"){
  d <- d[,c(1,2,3,5,6,7)]
}else if(stat_type == "Average"){
  d <- d[,c(1,2,3,4,6,7)]
}

colnames(d) <- c("Chr","Start","End","Stat","Coverage","Coverage_fix")
d_Chr = unique(d$Chr)
plot_l <- list()
for (j in 1:length(d_Chr)) {
  dd <- d %>% filter(Chr == d_Chr[j])
  
  dd[dd$Coverage < cov_thres,4] <- 0
  dd_mean = mean(dd$Stat)
  dd_median = median(dd$Stat)

  dd_mean_r = mean(dd[dd$Coverage >= cov_thres,]$Stat)
  dd_median_r = median(dd[dd$Coverage >= cov_thres,]$Stat)

  dd <- dd %>% mutate(
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
  color_tmp <- color
  Stat_class_all <- unique(dd$Stat_class)
  for(i in 1:length(color_tmp)){
    if(!depth_level[i] %in% Stat_class_all){
      color_tmp[i] <- NA
    }
  }
  color_tmp <- color_tmp[!is.na(color_tmp)]
  dd$Pos <- 1:nrow(dd)
  dd$Medium <- (dd$Start+dd$End)/2
  x_pos <- round(quantile(1:nrow(dd),seq(0.1,0.9,0.1)),0)
  x_inter <- paste(round((dd$Medium[x_pos])/1000000,2), "Mb",sep = " ")
  
  x_min <- min(dd$Start) - 1
  if(x_min == 0){
    x_min = paste(round(x_min,2),"Mb",sep = " ")
  }else{
    x_min = paste(round(x_min/1000000,2),"Mb",sep = " ")
  }
  x_max <- max(dd$End) + 1
  x_max = paste(round(x_max/1000000,2),"Mb",sep = " ")

  if(stat_type == "Median"){
    p_lab = paste(d_Chr[j]," ",stat_type,": ",round(dd_median_r,2),sep = "");
  }else if(stat_type == "Average"){
    p_lab = paste(d_Chr[j]," ",stat_type,": ",round(dd_mean_r,2),sep = "");
  }
   
  if(cov_plot){
    tmp_beta = (stat_thres * 0.5)/100
    dd$Cov = -dd$Coverage * tmp_beta
    p <- ggplot(dd) +
      geom_bar(aes(x = Pos, y = Stat_new, fill = Stat_class),stat = "identity")+
      geom_line(aes(x = Pos, y = Cov),linewidth = 0.5)+
      theme_classic()+
      theme(
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.title.x = element_blank(),
        legend.position = "none",
        legend.title = element_blank(),
      )+
      scale_fill_manual(values = color_tmp)+
      scale_x_continuous(breaks = c(1,x_pos,nrow(dd)),labels = c(x_min,x_inter,x_max))+
      scale_y_continuous(breaks = c(0,stat_min,stat_max,stat_thres),limits = c(min(dd$Cov),stat_thres),
                         sec.axis = sec_axis(~ (.), breaks = c(min(dd$Cov),as.numeric(quantile(c(min(dd$Cov),0),c(0.25,0.5,0.75))),0),
                                             name = "Coverage",labels = c(100,75,50,25,0)),
      )+
      labs(y = paste(stat_type,"depth",sep = " "), title = p_lab)
  }else{
    p <- ggplot(dd) +
      geom_bar(aes(x = Pos, y = Stat_new, fill = Stat_class),stat = "identity")+
      theme_classic()+
      theme(
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.title.x = element_blank(),
        legend.position = "none",
        legend.title = element_blank()
      )+
      scale_fill_manual(values = color_tmp)+
      scale_x_continuous(breaks = c(1,x_pos,nrow(dd)),labels = c(x_min,x_inter,x_max))+
      scale_y_continuous(breaks = c(0,stat_min,stat_max,stat_thres),limits = c(0,stat_thres))+
      labs(y = paste(stat_type,"depth",sep = " "), title = p_lab)
  }
  plot_l[[j]] <- p
}
p_f <- NULL
for(n in 1:length(plot_l)){
  if(n == 1){
    p_f = plot_l[[n]]
  }else{
    p_f = p_f/plot_l[[n]]
  }
}
plot_w = nrow(d)/plot_index
plot_w = plot_w/length(d_Chr)
if(cov_plot){
  plot_h = length(d_Chr)*3
}else{
  plot_h = length(d_Chr)*2
}
plot_n <- paste(file_used,"pdf",sep = ".")
ggsave(plot_n,p_f,width = plot_w,height = plot_h, limitsize = FALSE)