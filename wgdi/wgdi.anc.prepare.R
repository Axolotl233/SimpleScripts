library(RColorBrewer)
color <-  brewer.pal(9,"Set1")
args <- commandArgs(trailingOnly = TRUE)

n <- gsub("\\.wgdi\\.lens","",args[1])
nn <- paste(c(n,".wgdi.anc.txt"),collapse = "")

d <- read.csv(args[1],sep = '\t',header = F)
d <- d[d$V3 > as.numeric(args[2]),]

color_u <- colorRampPalette(color)(nrow(d))
dd <- matrix(NA,nrow=nrow(d),ncol = 5)

for(i in 1:nrow(d)){
  dd[i,] = c(d[i,1],1,d[i,3],color_u[i],1)
}
dd <- as.data.frame(dd)
readr::write_delim(x = dd,file = nn,delim = '\t',col_names = F)