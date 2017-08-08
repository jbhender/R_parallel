## Parallel computing in R       ##
## CSAR Workshop, August 9, 2017 ##
## James Henderson, PhD          ##

setwd('~/R_parallel')
library(parallel)

#### Example 1: permutation tests for gene set analysis ####

## load data ##
foo = load('./YaleTNBC.Rdata')
AA = grep('AA',colnames(YaleTNBC))
EA = grep('EA',colnames(YaleTNBC))


#### Example 1a: computing gene scores ####

# a function to compute gene scores #
genescores = function(Mat,G1,G2){
  apply(Mat,1,function(x) t.test(x[G1],x[G2])$statistic)
}
t1.0 = system.time({
  gs = genescores(YaleTNBC,AA,EA)
})

## a parallel version of genescores ##
genescoresParallel = function(Mat,G1,G2,mc.cores=2,mc.preschedule=TRUE){
  mclapply(1:nrow(Mat),function(row) 
   t.test(Mat[row,G1],Mat[row,G2])$statistic,mc.cores=mc.cores,mc.preschedule = mc.preschedule
  )
}

t1.1 = system.time({
  gs = genescoresParallel(YaleTNBC,AA,EA)
})

t1.2 = system.time({
  gs = genescoresParallel(YaleTNBC,AA,EA,mc.cores=3)
})

rbind(t1.0,t1.1,t1.2)

#### Example 1b: computing set scores ####

# load gene sets #
bar = load('./c6.unsigned.Rdata')
class(c6.unsigned)

## get row index for genes in each set 
getInd = function(set,universe){
  x = match(set$names,universe)
  x[which(!is.na(x))]
}
c6.ind = mclapply(c6.unsigned,getInd,universe=rownames(YaleTNBC))

## compute set scores #
# Recall gs holds gene scores #
gs = unlist(gs)
setscore = function(setInd,gs){
  sum(gs[setInd])
}
setscore(c6.ind[[1]],gs)

t2.0 = system.time({
  scores_obs = lapply(c6.ind,setscore,gs=gs)
})

t2.1 = system.time({
  scores_obs = mclapply(c6.ind,setscore,gs=gs)
})

## Parallel not needed ##
rbind(t2.0,t2.1)

#### Example 1c: permutation tests ####
# Evaluate significance of each set by comparing
# to set scores after permutation of group labels

doPermute_seq = function(sets,sampleMatrix,G1size){
  G1 = sample(ncol(sampleMatrix),G1size,replace=F)
  G2 = {1:ncol(sampleMatrix)}[-G1]
  
  gs = genescores(sampleMatrix,G1,G2)
  sapply(sets,setscore,gs=gs)
}

# sequentially create permutations, compute genescores and set scores in parallel
doPermute_par = function(sets,sampleMatrix,G1size){
  G1 = sample(ncol(sampleMatrix),G1size,replace=F)
  G2 = {1:ncol(sampleMatrix)}[-G1]
  
  ## parallel computation of gene scores
  gs = genescoresParallel(sampleMatrix,G1,G2)

  ## parallel computaiton of set scores
  unlist(mclapply(sets,setscore,gs=gs))
}

t3.0 = system.time({
  doPermute_seq(c6.ind,YaleTNBC,length(AA))
})

t3.1 = system.time({
  doPermute_par(c6.ind,YaleTNBC,length(AA))
})

## Compare times for a single permutation ##
rbind(t3.0,t3.1)

## Example 1d: Run permutations in parallel ##
nPermute = 10

# All Sequential 
set.seed(89)
t4.0 = system.time({
  scores_perm_seq = mclapply(1:nPermute,function(i) 
    doPermute_seq(c6.ind,YaleTNBC,length(AA)))
})

# In parallel
set.seed(89)
t4.1 = system.time({
  scores_perm_par = mclapply(1:nPermute,function(i) 
    doPermute_par(c6.ind,YaleTNBC,length(AA)))
})

# In parallel with 4 cores specified
set.seed(89)
t4.2 = system.time({
  scores_perm_seq2 = mclapply(1:nPermute,function(i) 
    doPermute_seq(c6.ind,YaleTNBC,length(AA)),mc.cores=4)
})
length(scores_perm_par[[1]])
rbind(t4.0,t4.1,t4.2)

## Do all give the same results with the seed set?
all.equal(scores_perm_seq,scores_perm_par)

## exact repeat of before
set.seed(89)
t4.0_b = system.time({
  scores_perm_seq_b = mclapply(1:nPermute,function(i) 
    doPermute_seq(c6.ind,YaleTNBC,length(AA)))
})
all.equal(scores_perm_seq_b,scores_perm_seq)

## Care must be taken with random number generation when computing in parallel!
# see ?mcparallel

## Reproducible results 
# Check the random number stream #
RNGkind()
RNGkind("L'Ecuyer-CMRG")
RNGkind()

set.seed(89)
scores_perm_seq_a = mclapply(1:nPermute,function(i) 
    doPermute_seq(c6.ind,YaleTNBC,length(AA)))

set.seed(89)
scores_perm_seq_b = mclapply(1:nPermute,function(i) 
    doPermute_seq(c6.ind,YaleTNBC,length(AA)))

# The two results above are equal
all.equal(scores_perm_seq_a,scores_perm_seq_b)

# but not equal to the sequential version
set.seed(89)
scores_perm_seq_c = lapply(1:nPermute,function(i) 
  doPermute_seq(c6.ind,YaleTNBC,length(AA)))
all.equal(scores_perm_seq_a,scores_perm_seq_c)

