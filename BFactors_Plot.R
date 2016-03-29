rm(list=ls(all=TRUE))
dir<-"/home/juan/BEC"
setwd(dir)

bfactors.data <- read.table(file = "Calfa_BFactors_Parsed.tsv", header = TRUE, sep = "\t")
bfactors.data<-bfactors.data[4:96,]
bfactors.data
bfactors.data$atoms<-scale(bfactors.data$atoms)
## "scale" function standardizes/normalizes a dataset,
## without having to calculate mean and standard 
## deviation previously

bfactors.withligand.data <- read.table(file = "Calfa_BFactors_withLigand_3so9_Parsed.tsv", header = TRUE, sep = "\t")
bfactors.withligand.data<-bfactors.withligand.data[4:96,]
bfactors.withligand.data
bfactors.withligand.data$atoms<-scale(bfactors.withligand.data$atoms)


color1<-rgb(1,0,0,alpha=0.6)
color2<-rgb(0,0,1,alpha=0.6) 

plot(bfactors.data$bfactor,bfactors.data$atoms, type = "h", col=color1 , lwd=10,xlim = c(0,100), ylim = c(-3,3),xlab = "",ylab="",main="B factor comparison between 1hhp and 3so9")
legend(80,2,c("1hhp","3so9"),lty=c(1,1),lwd=c(2.5,2.5),col=c("red","blue"))
par(new=TRUE)
plot(bfactors.withligand.data$bfactor,bfactors.withligand.data$atoms, type = "h", col = color2, lwd=10, xlim=c(0,100),ylim=c(-3,3),xlab="Atoms (C alpha)",ylab="B Factors (Standardized)")
