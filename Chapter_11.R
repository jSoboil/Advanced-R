# Functionals -------------------------------------------------------------
# Functionals take a function as an input and return a vector as an output. For 
# e.g.
randomise <- function(f) {
 f(runif(1e3))
}
randomise(mean)
randomise(mean)
randomise(sum)

# Three frequently used functionals are lapply, apply, and tapply. Functionals are
# a common alternative to for loops. Although for loops can be slow, it is mainly
# the fact that they can be inclear ito what they are iterating over, i.e. they 
# are not very expressive. Functionals are also useful for encapsulating common
# data manipulation tasks like split-apply-combine, for thinking 'functionally'
# and for working with mathematical functions.

# Functionals also reduce code bugs. Note that it is always important to first
# build the tools and functions for the problem. Once you have solved the problem,
# then one can focus on speed.

## My first functional: lapply() -------------------------------------------
# The simplest functional is lapply(). lapply() takes a function, applies it to
# each element in a list, and returns the results in the form of a list. Although
# lapply() is written in C for performance, we can create a simple R 
# implementation that does the same thing:
lapply2 <- function(x, f, ...) {
 out <- vector("list", length(x))
 for (i in seq_along(x)) {
  out[[i]] <- f(x[[i]], ...)
 }

  out

}
# From the above code, one can see that lapply() is a wrapper function for a 
# common loop pattern: create a container output, apply f() to each component of
# a list, and fill the container with the results. All other for loop functionals
# are variations of this theme: they simply use different types of input or 
# output.

### Looping patterns --------------------------------------------------------
# It's useful to remember that there are three basic ways to loop over a vector:
 # 1. loop over the elements: for (x in s)
 # 2. loop over the numeric indices: for (i in seq_along(xs))
 # 3. loop over the names: for (nm in names(xs))

# The first form is usually not a good choice for a for loop because it leads to
# inefficient ways of saving output. It's slow because each time you extend the
# vector, R has to copy in all of the existing elements. This is the easiest with
# the second form:
xs <- runif(1e3)
res <- numeric(length(xs))
for (i in seq_along(xs)) {
 res[i] <- sqrt(xs[i])
}

# Just as there three basic ways to use a for loop, there are three basic ways
# to use lapply():
lapply(xs, function(x) {})
lapply(seq_along(xs), function(i) {})
lapply(names(xs), function(nm) {})

### Exercises ---------------------------------------------------------------
# Use both for loops and lapply() to fit linear models to the mtcars using the
# formulas stored in this list:
formulas <- list(
 mpg ~ disp,
 mpg ~ I(1 / disp),
 mpg ~ disp + wt,
 mpg ~ I(1 / disp) + wt
)

# Create input list:
data_out <- as.list(numeric(length(formulas)))
# Loop over list:
for (i in seq_along(formulas)) {
 data_out[[i]] <- lm(formulas[[i]], data = mtcars)

 print(data_out) 
}
# lapply:
lapply(formulas, lm, data = mtcars)

## For loop functionals: friends of lapply() -------------------------------
# The key to using functionals in place of for loops is recognising that common
# looping patterns are already implemented in existing base functionals. Once
# you've mastered base functionals, the next step is to write your own: if you're
# duplicating the same looping patterns in many places, you should extract it
# out into its own.

### Vector output: sapply() and vapply() ------------------------------------
# sapply and vapply simplify their output to be an atomic vector. vapply() is 
# better suited for use within other functions, than sapply(). For example, 
# when given an empty list, sapply() returns another empty list instead of the
# more correct zero-length vector.
sapply(mtcars, is.numeric)
vapply(mtcars, is.numeric, logical(1))
sapply(list(), is.numeric)
vapply(list(), is.numeric, logical(1))
# ... so, if the function returns results of different types or lengths, sapply()
# will silently return a list, while vapply() will throw an error. Hence, sapply
# is dangerous when writing functions.

### Multiple inputs: map (and mapply) ---------------------------------------
# Briefly, Map is useful when you want to use a function with two inputs. For
# example, weighted mean(). Map() is equivalent to mapply() but with simplify = 
# FALSE; mapply can add more complication for little gain.

### Rolling computations ----------------------------------------------------
# You can create your own functionals too. For example, if you were interested 
# in smoothing your data using a rolling (or running) mean function:
roll_mean <- function(x, n) {
 out <- rep(NA, length(x))
 
 offset <- trunc(n/ 2)
 
 for (i in (offset + 1):(length(x) - n + offset - 1)) {
  out[i] <- mean(x[(i - offset):(i + offset - 1)])
 }
 
 out
}
# Create simulated data:
x <- seq(1, 3, length = 1e2) + runif(1e2)
plot(x)
lines(roll_mean(x, 5), col = "blue", lwd = 2)
lines(roll_mean(x, 10), col = "red", lwd = 2)

# In this case, if the noise was more variable (i.e. it has a longer tail), you
# might worry that the rolling mean was too sensitive to outliers. Instead, you
# might want to compute a rolling median:
x <- seq(1, 3, length = 1e2) + rt(1e2, df = 2) / 3
plot(x)
lines(roll_mean(x, 5), col = "red", lwd = 2)

# To change roll_mean to roll_median, all you need to do is replace mean with 
# median inside loop. Instead of copy/paste, we could extract the idea of 
# computing a rolling summary into its own function:
roll_apply <- function(x, n, f, ...) {
 # Create out vector
 out <- rep(NA, length(x))
 # Offset
 offset <- trunc(n / 2)
 # Loop over data:
 for (i in (offset + 1):(length(x) - n + offset + 1)) {
  out[i] <- f(x[(i - offset):(i + offset)], ...)
 }
 # Print:
 out
}
plot(x)
lines(roll_apply(x, 5, median), col = "red", lwd = 2)

### Parallelosation ---------------------------------------------------------
# Since we can compute each element in any order, it is easy to dispatch the 
# tasks to different cores, and compute them in parallel. This is what
# parallel::mcapply and parallel:map do.
library(parallel)
unlist(mclapply(1:10, sqrt, mc.cores = 4))

# Important note: in this case, mclapply is actually *slower* than lapply. This
# is because the cost of individual computations is low, and additional work is
# needed to send the computation to different cores and collect results.

# If we use a different example, however, by taking bootstrap replicates of a
# linear model, the advantages are clear:
boot_df <- function(x) {
 x[sample(nrow(x), replace = TRUE), ]

 }

r_sqrd <- function(mod) {
 summary(mod)$r.square
 
}

boot_lm <- function(i) {
 r_sqrd(lm(mpg ~ wt + disp, data = boot_df(mtcars)))

 }

# Without parallelisation:
system.time(lapply(1:500, boot_lm))
# With parallelosation:
system.time(mclapply(1:500, boot_lm, mc.cores = 2))

# Note: increasing the number of cores will not always lead to linear gains,
# switching from lapply or Map to its parallel forms can dramatically improve
# computational performance!

## Exercises 11.2.5 ----------------------------------------------------------
# 1.
## a)
df_1 <- data.frame(
 x = sample(x = 1:10, size = 100, replace = TRUE),
 y = rt(n = 100, df = 2),
 z = rbeta(n = 100, shape1 = 0.5, shape2 = 0.5)
 )
vapply(df_1, sd, FUN.VALUE = numeric(1))

## b)
if (vapply(mtcars, is.numeric, FUN.VALUE = logical(1))) {
 vapply(mtcars, sd, FUN.VALUE = numeric(1))
 }
# Exercises are interesting but relatively easy - moving on...

## Manipulating matrices and data frames -----------------------------------
# This section will cover three categories of data structure functionals:

# apply(), sweep(), outer(), and how they work with matrices
# tapply() summarises a vector by groups defined by another vector
# the plyr::package, which generalises tapply() to make it easy to work with 
# data frames, lists, or arrays as inputs, and data frames, lists, or arrays as
# outputs.

### Matrix and array operations ---------------------------------------------
# First off, apply() is a variant of sapply() that works with matrices and 
# arrays. It can be thought of as an operation that summarises a matrix or array
# by collapsing each row or column to a single number. It has four arguments:

# x, the matrix or array to summarise
# MARGIN, an integer vector giving the dimensions to summarise over: 1 = rows, 2
#  = columns, etc.
# FUN, a summary function
# ..., other arguments passed to FUN

# A typical example of apply() looks like this:
a <- matrix(1:20, nrow = 5)
apply(X = a, MARGIN = 1, FUN = mean)
apply(X = a, MARGIN = 2, FUN = mean)

# There are a few caveats to apply(). It doesn't simplify argument, so you can 
# never be completely sure what type of output you'll get. This means that 
# apply() is *not* safe to use inside a function unless you carefully check the
# inputs. apply() is also not idempotent in the sense that if the summary 
# function is the identity operator, the output is not always the same as the 
# input:
a_1 <- apply(a, 1, identity)
identical(a, a_1)
# But if you transpose rows to columns:
identical(a, t(a_1))
# But again...
a_2 <- apply(a, 2, identity)
identical(a, a_2)

# Tip: you can put n-dimensional arrays back in the right order using aperm(), 
# or use plyr::aaply(), which is idempotent.

# Another functional is sweep(), which allows you to "sweep" out the values of
# a summary statistic. It is often used with apply() to standardise arrays. The
# following example scales the rows of a matrix so that values lie between 0
# and 1:
x <- matrix(rnorm(
 n = 20, mean = 0, sd = 1), nrow = 4)
x_1 <- sweep(x = x, MARGIN = 1, apply(X = x, MARGIN = 1, min), FUN = `-`)
x_2 <- sweep(x = x_1, MARGIN = 1, apply(X = x_1, MARGIN = 1, max), FUN = `/`)

# The final matrix functional is outer(). It is a little different in that it 
# takes multiple vector inputs and creates and creates a matrix or array output
# where the input function is run over every combination of the inputs, for 
# example...
# Create a times table:
outer(X = 1:3, Y = 1:10, "*")

## Group apply -------------------------------------------------------------
# You can think about tapply() as a generalisation to apply() that allows for
# "ragged" arrays, arrays where each row can have a different number of columns.
# This is often needed when you're trying to summarise a data set. E.g., imagine
# you collected pulse rate data from a trial, and you want to comapre the two
# groups:
pulse <- round(
 rnorm(n = 22, mean = 70, sd = 10/3)) + rep(c(0, 5), c(10, 12))
group <- rep(c("A", "B"), c(10, 12))
# Use tapply():
tapply(pulse, group, length)
tapply(pulse, group, mean)

# tapply() by creating a "ragged" data structure from a set of inputs, and then
# applying the function to the x_i of j.

# Note: you can use split(group, pulse) to create a list too!

## Manipulating lists ------------------------------------------------------






