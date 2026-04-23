require(foreign)
require(poLCA)

setwd("/Users/melissadell/Dropbox (Melissa Dell)/VietnamWar/reprod/")

## Read in data
health <- read.csv("all_lca_health.csv", na.strings="")
educ <- read.csv("all_lca_educ.csv", na.strings="")
admin <- read.csv("all_lca_admin.csv", na.strings="")
soccap <- read.csv("all_lca_soccap.csv", na.strings="")
econ <- read.csv("all_lca_econ.csv", na.strings="")
sec <- read.csv("all_lca_sec.csv", na.strings="")

data <- list(health, educ, admin, soccap, econ, sec)

## formula - this is using a formula to combine the data so that it can be looped through to run the LCA
health.f <- as.formula(paste("cbind(",paste(names(health[1:(length(names(health))-2)]), collapse=", "), ") ~1", sep=""))
educ.f <- as.formula(paste("cbind(",paste(names(educ[1:(length(names(educ))-2)]), collapse=", "), ") ~1", sep=""))
admin.f <- as.formula(paste("cbind(",paste(names(admin[1:(length(names(admin))-2)]), collapse=", "), ") ~1", sep=""))
soccap.f <- as.formula(paste("cbind(",paste(names(soccap[1:(length(names(soccap))-2)]), collapse=", "), ") ~1", sep=""))
econ.f <- as.formula(paste("cbind(",paste(names(econ[1:(length(names(econ))-2)]), collapse=", "), ") ~1", sep=""))
sec.f <- as.formula(paste("cbind(",paste(names(sec[1:(length(names(sec))-2)]), collapse=", "), ") ~1", sep=""))

f <- list(health.f, educ.f, admin.f, soccap.f, econ.f, sec.f)

## Run LCA with 2 classes for each 

# simple wrapper: run poLCA once, then order categories in terms of resulting probabilities
LCA <- function(data, f, nclass){
  lca <- poLCA(f, data, nclass=nclass, verbose=FALSE, na.rm=FALSE)
  p <- poLCA.reorder(lca$probs.start, order(lca$P, decreasing=TRUE))
  lca <- poLCA(f, data, nclass=nclass, probs.start = p, nrep=5, na.rm=FALSE, maxiter=10000)
}

LCA.2 <- lapply(1:length(f), function(x) LCA(data[[x]], f[[x]], nclass=2))

## export results to dataframes
data.new <- lapply(1:length(f), function(x) {
  cbind(data[[x]], LCA.2[[x]]$posterior, LCA.2[[x]]$predclass)
})

# create a dataframe for each submodel
health.new <- data.new[[1]]
educ.new <- data.new[[2]]
admin.new <- data.new[[3]]
soccap.new <- data.new[[4]]
econ.new <- data.new[[5]]
sec.new <- data.new[[6]]

# add the column names to each dataframe 
names.new <- c("prob2_1", "prob2_2", "class_2")
names(health.new) <- c(names(health), paste("health", names.new, sep="_"))
names(educ.new) <- c(names(educ), paste("educ", names.new, sep="_"))
names(admin.new) <- c(names(admin), paste("admin", names.new, sep="_"))
names(soccap.new) <- c(names(soccap), paste("soccap", names.new, sep="_"))
names(econ.new) <- c(names(econ), paste("econ", names.new, sep="_"))
names(sec.new) <- c(names(sec), paste("sec", names.new, sep="_"))

## Write to .csv
write.csv(health.new, "health_lca_all.csv")
write.csv(educ.new, "educ_lca_all.csv")
write.csv(admin.new, "admin_lca_all.csv")
write.csv(soccap.new, "soccap_lca_all.csv")
write.csv(econ.new, "econ_lca_all.csv")
write.csv(sec.new, "sec_lca_all.csv")

