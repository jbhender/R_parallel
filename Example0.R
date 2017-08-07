## Parallel computing in R       ##
## CSAR Workshop, August 9, 2017 ##
## James Henderson, PhD          ##

setwd('~/R_parallel')
#### Example 0: computing a long vector of means ####

## load data ##
foo = load('./YaleTNBC.Rdata')
AA = grep('AA',colnames(YaleTNBC))
EA = grep('EA',colnames(YaleTNBC))

### Version 1 - for loop ###
t1 = system.time({
 fold_change1 = rep(NA,nrow(YaleTNBC))
 for(i in 1:nrow(YaleTNBC)){
   fold_change1[i] = mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
 }
})

### Version 2 - an apply function ###
t2 = system.time({
  fold_change2 = sapply(1:nrow(YaleTNBC),function(i){
    mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
  })
})

fc2 = function(i) mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
t2a = system.time({
 fold_change2a = sapply(1:nrow(YaleTNBC),fc2)
})

## version 3 - a different apply approach ##
t3 = system.time({
  fold_change3 = apply(YaleTNBC[,AA],1,mean) - apply(YaleTNBC[,EA],1,mean)
})


## Version 4 - parallel approaches ##
library(parallel)
t4 = system.time({
  fold_change4 = mclapply(1:nrow(YaleTNBC),function(i){
  mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
})
})
class(fold_change4)
fold_change4 = unlist(fold_change4)


# Check and increase number of cores used #
getOption("mc.cores", 2L)
detectCores()
#help(mc.preschedule)

## Version 5 - More cores ##
t5 = system.time({
  fold_change = mclapply(1:nrow(YaleTNBC),function(i){
    mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
  },mc.cores=4)
})

print(rbind(t1,t2,t3,t4,t5))

## An example of parallelism gone wrong ##
t6 = system.time({
  fold_change = mclapply(1:nrow(YaleTNBC),function(i){
    mean(YaleTNBC[i,AA]) - mean(YaleTNBC[i,EA])
  },mc.cores=2,mc.preschedule = FALSE)
})
t6
