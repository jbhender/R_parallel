## Parallel computing in R       ##
## CSAR Workshop, August 9, 2017 ##
## James Henderson, PhD          ##

setwd('~/R_parallel')
#### Example 0: computing a long vector of means ####

## load data ##
foo = load('./YaleTNBC.Rdata')
AA = grep('AA',colnames(YaleTNBC))
EA = grep('EA',colnames(YaleTNBC))

### Version 1 ###
t1 = system.time({
 fold_change1 = rep(NA,nrow(YaleTNBC))
 for(i in 1:nrow(YaleTNBC)){
   fold_chang1[i] = mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
 }
})

t2 = system.time({
  fold_change = sapply(1:nrow(YaleTNBC),function(i){
    mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
  })
})

t3 = system.time({
  fold_change = apply(YaleTNBC[,AA],1,mean) - apply(YaleTNBC[,EA],1,mean)
})


## Version 2 ##
library(parallel)
t4 = system.time({
  fold_change = mclapply(1:nrow(YaleTNBC),function(i){
  mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
})
})
class(fold_change4)
fold_change = unlist(fold_change)


# Check and increase number of cores used #
getOption("mc.cores", 2L)
detectCores()
help(mc.preschedule)

t5 = system.time({
  fold_change = mclapply(1:nrow(YaleTNBC),function(i){
    mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
  },mc.cores=4)
})

rbind(t1,t2,t3,t4,t5)

## An example of parallelism gone wrong ##
t6 = system.time({
  fold_change = mclapply(1:nrow(YaleTNBC),function(i){
    mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
  },mc.cores=2,mc.preschedule = FALSE)
})
t6
