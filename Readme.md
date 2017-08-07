# Parallel Computing in R

This repository contains material for a workshop presented August 9, 2017.

## Overview 
In this workshop my goal is to provide a gentle introduction to parallel computing in R.

The workshop is split into two main parts:

 + Multicore computing on a single machine using __mclapply__ from the *parallel* package.

 + Parallel computing on one or more machines using the __%dopar%__ operator from the *doParallel* package.

In addition we will discuss:

 + Options for splitting computations across multiple processes and how to choose among
these by considering both the sturcture of the tasks to be performed and the parallel architecture available. 

 + How to obtain valid and reproducible random numbers in parallel computing.  

As a word of cauation, this workshop is built around my own experience as a statistician and comes with no
guarantee of general applicability.

## Multicore computing using the parallel package

## Parallel computing with doParallel and foreach

## Random numbers and parallel computing

For more details, see the doRNG <a href='https://cran.r-project.org/web/packages/doRNG/vignettes/doRNG.pdf'>vignette</a>.

