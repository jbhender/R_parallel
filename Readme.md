# Parallel Computing in R

This repository contains material for a workshop presented August 9, 2017.
The workshop is sponsored by Consulting for Statistics Computing and Analytics Research 
<a href='http://cscar.research.umich.edu/'>(CSCAR)<\a>
at the University of Michigan. 

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

Most modern computers, including laptops and desktops, come with multiple processors or cores -
the distinction is not important for our purposes but see 
<a href='http://dept.stat.lsa.umich.edu/~kshedden/Courses/Stat506/computer_architecture/'>here</a>
for some discussion. The basic idea of multicore computing is to allow a single program, in this 
case R, to run multiple threads simultaneously in order to reduce the 'walltime' required for 
completion. 

In R, this can be done using the __parallel__ package distributed in the base distribution since
version 2.14.0. We will

### Multicore servers at UM
Long running computations are also commonly run on specialized, multiuser servers. For instance,
here at UM researchers have access to the Statistics & Computation Service
<a href='http://www.itcs.umich.edu/scs/'>(SCS)</a> run by ITS. You can access these servers using
`ssh` from a terminal applicaton.

### Do you need to parallelize? 
When thinking of parallelizing some portion of a program it is important to remember that 
parallelism is not magic. There is some computational overhead involved in splitting the task, 
initializing child processes, comunicating data, and coallating results.  

## Parallel computing with doParallel and foreach

## Random numbers and parallel computing

Many statistical and machine learning applications rely on pseudo-random numbers for thinks like  
sampling from distributions and stochastic optimization. When child processes are spawned to compute


For more details, see the doRNG <a href='https://cran.r-project.org/web/packages/doRNG/vignettes/doRNG.pdf'>vignette</a>.

