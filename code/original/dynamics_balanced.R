library(ggplot2)

data=read.csv("/Users/melissadell/Dropbox (Melissa Dell)/VietnamWar/reprod/bombing_balanced_dynamics.csv")

period.n = as.numeric(as.character(data$period))
data$annotation = ifelse(period.n <= 0,
                         'Pre-period',
                         'Post-period')
data$Period <- factor(data$annotation, levels = c("Pre-period", "Post-period"))

data$Quarter <- factor(data$period, levels = c(as.character(seq(-2,0, by=1)),  as.character(seq(1,8, by=1))))
OutVec=c("fr_strikes_mean")

pdf(file ="/Users/melissadell/Dropbox (Melissa Dell)/VietnamWar/reprod/dynamics_balance_fs.pdf", width=14*.5, height=8*.5)

for (V in OutVec){
  subdata=subset(data, depvar==V)
  subdata=subset(subdata, period>=-2 & period<=8)
  
  ggstandard = ggplot(data=subdata, aes(x =Quarter, y = coeff, ymin = cn5, ymax=cp5))
  
  print(ggstandard
        + geom_linerange(aes(color=Period), size = .65)
        + geom_point(aes(x = Quarter, y = coeff, color=Period), size = 3.5) 
        + geom_hline(y = 0)
        + scale_x_discrete(breaks=c(-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8),labels=c(-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8))
        + scale_y_continuous(name="")
        + scale_colour_manual(values=c("#000000", "#0D4F8B"))
        + ggtitle("")
        + theme_bw()
        
  )
}
dev.off()
