## Parallel computing in R       ##
## CSAR Workshop, August 9, 2017 ##
## James Henderson, PhD          ##

setwd('~/R_parallel')
#### Example 2: permutation tests for gene set analysis using foreach ####

##### !! This code is all taken from example 1 !! #####
## load data ##
foo = load('./YaleTNBC.Rdata')
AA = grep('AA',colnames(YaleTNBC))
EA = grep('EA',colnames(YaleTNBC))

# load gene sets #
bar = load('./c6.unsigned.Rdata')

# get row index for genes in each set  #
getInd = function(set,universe){
  x = match(set$names,universe)
  x[which(!is.na(x))]
}
c6.ind = mclapply(c6.unsigned,getInd,universe=rownames(YaleTNBC))

# a function to compute gene scores #
genescores = function(Mat,G1,G2){
  apply(Mat,1,function(x) t.test(x[G1],x[G2])$statistic)
}

# a parallel version of genescores #
genescoresParallel = function(Mat,G1,G2,
                              mc.cores=2,mc.preschedule=TRUE){
  mclapply(1:nrow(Mat),function(row) t.test(Mat[row,G1],Mat[row,G2])$statistic,mc.cores=mc.cores,mc.preschedule = mc.preschedule)
}

## compute set scores #
setscore = function(setInd,gs){
  sum(gs[setInd])
}

# Evaluate significance of each set by comparing
# to set scores after permutation of group labels
doPermute_seq = function(sets,sampleMatrix,G1size){
  G1 = sample(ncol(sampleMatrix),G1size,replace=F)
  G2 = {1:ncol(sampleMatrix)}[-G1]
  
  gs = genescores(sampleMatrix,G1,G2)
  sapply(sets,setscore,gs=gs)
}

doPermute_par = function(sets,sampleMatrix,G1size){
  G1 = sample(ncol(sampleMatrix),G1size,replace=F)
  G2 = {1:ncol(sampleMatrix)}[-G1]
  
  genescoresParallel(sampleMatrix,G1,G2)
  unlist(mclapply(sets,setscore,gs=gs))
}

# Compute observed set scores
gs = genescores(YaleTNBC,AA,EA)
scores_obs = sapply(c6.ind,setscore,gs=gs)

##### !! End code taken from example 1 !! #####

## Example 2: run permutations in parallel using foreach ##
nPermute = 10

# load doParallel library also loads foreach #
library(doParallel)

# set up a cluster
nCores = 2
cl = makeCluster(2)
registerDoParallel(cl)

# compute in parallel, return as list #
tm1 = system.time({
  scores_perm_1 = foreach(n=1:nPermute) %dopar% {
    doPermute_seq(c6.ind,YaleTNBC,length(AA))
  }
})
tm1

class(score_perm_1)
length(scores_perm_1[[1]])

# compute in parallel return as set by permuation matrix
tm2 = system.time({
  scores_perm_2 = foreach(n=1:nPermute,.combine='cbind') %dopar% {
    doPermute_seq(c6.ind,YaleTNBC,length(AA))
  }
})
tm2

class(scores_perm_2)
dim(scores_perm_2)

# histogram of p-values #
hist(apply(abs(scores_perm_2) > abs(scores_obs),1,mean),main='p-values')
