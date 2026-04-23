library(ggplot2)

data=read.csv("/Users/melissadell/Dropbox (Melissa Dell)/VietnamWar/reprod/vndba_rf.csv")

data$Quarter <- factor(data$period, levels = c(as.character(seq(1, 23, by=1))))
OutVec=c("en_init")
pdf(file ="/Users/melissadell/Dropbox (Melissa Dell)/VietnamWar/reprod/vndba_rf.pdf", width=14*.5, height=8*.5)

#time FE
for (V in OutVec){
  subdata=subset(data, depvar==V)
  
  ggstandard = ggplot(data=subdata, aes(x =Quarter, y = coeff, ymin = cn5, ymax=cp5))
  
  print(ggstandard
        + geom_linerange(size = .65)
        + geom_linerange(aes(x =Quarter, y = coeff, ymin = cn5, ymax=cp5), size = 1.35)   
        + geom_point(aes(x = period, y = coeff), size = 3.5) 
        + geom_hline(y = 0)
        + scale_x_discrete(breaks=c(1, 4, 8, 12, 16, 20),labels=c(1964, 1965, 1966, 1967, 1968, 1969))
        + scale_y_continuous(name="VC Initiated Attacks")
        + theme_bw()
  )
}
dev.off()
