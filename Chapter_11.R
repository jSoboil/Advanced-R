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

### Parallelisation ---------------------------------------------------------
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
# Another way of thinking about functionals is as a set of general tools for 
# altering, subsetting, and collapsing lists. Every functional programming 
# language has three tools for this: Map(), Reduce(), and Filter(). We've seen
# Map(). Reduce() extends two-argument functions, and Filter(), a member of an
# important class of functionals that work with predicates (functions that retun
# binary logic).

### Reduce() ----------------------------------------------------------------
# Reduce() reduces a single vector x to a single value i by recursively calling
# a function f, two arguments at a time. It combines the first two elements with
# f, then combines the result of that call with the third element, and so on.
# Calling Reduce(f, 1:3) is equivalent to f(f(1, 2), 3). Reduce is also known as
# fold because it folds together adjacent elements in the list.

# The following two examples show what Reduce() does with an infix and prefix
# function:
Reduce(f =`+`, x = 1:3) # -> ((1+2) + 3)
Reduce(f = sum, x = 1:3) # -> sum(sum(1, 2), 3)

### Predicate functionals ---------------------------------------------------
# A predicate functional returns a single binary logic, for example is.character, 
# all, or is.NULL. There are three useful predicate functionals in base R:
# Filter(), Find(), and Position()

# Note: is.na returns a logical vector the same length as the input, rather than
# a single binary logic statement. Hence, it is not a 'true' predicate 
# functional.

# Exercise: use Filter() and vapply() to create a function that applies a 
# summary statistic to every numeric column in a data frame
df <- data.frame(x = rnorm(n = 10, mean = 0, sd = 10/3), 
                 y = letters[1:10])
# Done:
vapply(Filter(is.numeric, df),  mean, FUN.VALUE = 1)

### Mathematical functionals ------------------------------------------------
# Functionals are very common in mathematics. The limit, maximum, the roots, and
# the definite integral are all functionals: given a function, return a single 
# number (or vector of numbers). At first, these functionals don't seem to fit 
# in with the theme of elimnating loops, but if you dig deeper you'll find out
# that they are implemented using an algorithm that involves interation. 
# Examples are:
# intergrate() finds the AUC defined by some function f()
# uniroot() finds the root of some function f()
# optimise() finds the location of highest (or lowest) value of some function
# of f()

# Below explores how these functions operate using a simple function, sin():
integrate(f = sin, lower = 0, upper = pi)
str(uniroot(f = sin, interval = pi * c(1 / 2, 3 / 2)))
str(optimise(f = sin, interval = c(0, 2 * pi)))
str(optimise(f = sin, interval = c(0, 2 * pi), maximum = TRUE))

# In statistics, optimisation is often used for maximum likelihood estimation 
# (MLE). In MLE, we have two sets of parameters: the data, which is fixed for a
# given problem, and the parameters, which vary as we try to find the most 
# likely parameter value for the data. These two sets of parameters make the 
# problem well-suited for closures. Combining closures with optimisation give 
# rise to the following approach to solving MLE problems.

# The following shows how we might find the MLE estimate for /delta, if our data
# come from a dpois. First we create a function factory that, given a dataset,
# returns a function that computes the negative likelihood (NLL) for parameter
# \lambda. In R, it's common to work with the negative since optimise defaults
# to finding the min.
poisson_NLL <- function(x) {
 n <- length(x)
 sum_x <- sum(x)
 function(lambda) {
  n * lambda - sum_x * log(lambda) # + terms not involving lambda
 }
}
# Now optimise allows us to compute the most likely values:
x_1 <- c(41, 30, 31, 38, 29, 24, 30, 29, 31, 38)
x_2 <- c(6, 4, 7, 3, 3, 7, 5, 2, 2, 7, 5, 4, 12, 6, 9)
NLL_1 <- poisson_NLL(x_1)
NLL_2 <- poisson_NLL(x_2)
optimise(NLL_1, interval = c(0, 100))$minimum # so, for parameter interval 0-100
optimise(NLL_2, interval = c(0, 100))$minimum # so, for parameter interval 0-100

## Exercises 11.5.1 --------------------------------------------------------
# Implement arg_max. It should take a function and a vector of inputs, and 
# return the elements of the input where the function returns the highest value.
# For example, arg_max(-10:5, function(x) x ^ 2) should return -10

# arg_max function:
arg_max <- function(f, x) {
 round(x = optimise(f, interval = x, maximum = TRUE)$maximum, digits = 0)
}
# Create some function
some_func <- function(x) {
 x ^ 2
}
# Test:
arg_max(f = some_func, x = c(-10:5))
# arg_min function:
arg_min <- function(f, x) {
 round(x = optimise(f, interval = x)$minimum, digits = 0)
}
# Test:
arg_min(f = some_func, x = c(1:5))

## Loops that should be left as is -----------------------------------------
# Some loops have no natural functional equivalent. There are three common cases:
#  modifying in place
#  recursive functions
#  while loops

# It's possible to torture these problems to use a functional, but it's not a
# good idea. It will lead to code that is harder to understand, eliminating the
# main reason for using functionals in the first case.

### Modifying in place ------------------------------------------------------
# If you need to modify a part of an existing data frame, it is often better to
# to use a for loop. For example, the following code performs a variable-by-
# variable transformation by matching the names of a list of functions to the
# names of the variables in the data frame:
trans <- list(
 disp = function(x) x * 0.0163871,
 am = function(x) factor(x, levels = c("auto", "manual"))
)
for (var in names(trans)) {
 mtcars[[var]] <- trans[[var]](mtcars[[var]])
}

# We wouldn't normally use lapply() to replace this loop directly, but it is 
# *possible*. Just replace the loop with lapply() by using <<-:
lapply(names(trans), function(var) {
 mtcars[[var]] <<- trans[[var]](mtcars[[var]])
})
# The point is is that it is much less readable.

### Recursive relationships -------------------------------------------------
# It's hard to convert a for loop into a functional when the relationship 
# between elements is not independent, or is defined recursively. For example,
# exponential smoothing works by taking a weighted average of the current and
# previous data points. The exps() function below implements exponential 
# smoothing with a for loop.
exps <- function(x, alpha) {
 s <- numeric(length(x) + 1)
 for (i in seq_along(s)) {
  if (i == 1) {
   s[i] <- x[i]
   } else {
    s[i] <- alpha * x[i - 1] + (1 - alpha) * s[i - 1]
   }
  }
 s
 }
x <- runif(6)
exps(x, 0.5)

# We cannot eliminate the above loop since none of the functionals we've
# encountered allow the output at position i to depend on both the input and 
# output at position i - 1. It is possible to solve, but challenging, more time
# consuming, and harder to read as code.
 
### While loops -------------------------------------------------------------
# Note that you can write every for loop and as a while loop but you cannot do
# the reverse. For example, we could turn this for loop:
for (i in 1:10) {
 print(i)
}
# ... into this while loop:
i <- 1
while (i <= 10) {
 print(i)
 i <- i + 1
}
# But, not every while loop can be turned into a for loop because many while 
# loops don't know in advance how many times they will be run:
i <- 0
while (TRUE) {
 if (runif(1) > 0.9) {
  break
  i <- i + 1
 }
}

# This is a common problem when writing simulations!

# However, in this case we can remove the loop by recognising a special feature
# of this problem. This is a Bernoulli trial with p = 0.1 of failure. This is a
# geometric random variable, so you can replace the code with i <- geom(1, 0.1).
# Reformulating the problem in this way is often hard to do in general, but you
# will benefit greatly if you can do it for your problem.

## A family of functions ---------------------------------------------------
# This section uses a case study to demonstrate how to use functionals to take
# a simple building block and make it powerful and general. Let's start with a 
# simple idea: adding two numbers together. We can then use functionals to 
# extend it to summing multiple numbers, computing parrallel and cumulative sums,
# and summing across array dimensions.

# We can start by defining a very simple adding function, one which takes two
# scalar arguments:
add <- function(x, y) {
 stopifnot(length(x) == 1, length(y) == 1, 
           is.numeric(x), is.numeric(y))
 x + y
}
# We can also add an na.rm argument. A helper function will make the function 
# easier to work with: if x is missing it should return y and vice versa, and if
# both x and y are missing then the function should return another argument to
# the function - identity.
rm_na <- function(x, y, identity) {
 if (is.na(x) && is.na(y)) {
  identity
 } else if (is.na(x)) {
  y
 } else {
  x
 }
}
# This allows you to write a version of add() that can deal with missing values 
# if needed:
add <- function(x, y, na.rm = FALSE) {
 if (na.rm && (is.na(x) || is.na(y))) {
  rm_na(x, y, 0)
 } else {
  x + y
 }
}
add(10, NA)
add(10, NA, na.rm = TRUE)
add(NA, NA)
add(NA, NA, na.rm = TRUE)
# Note: remember adding is associative, hence NA + NA = 0
 
# Now that we have the basic workings, we can extend the function to deal with
# more complicated inputs. One obvious generalisation is to add more than two
# numbers. We can do this by iteratively adding numbers: if the input is 
# c(1, 2, 3) we compute add(add(1, 2), 3). This is a simple application of
# Reduce():
r_add <- function(xs, na.rm = TRUE) {
 Reduce(function(x, y) add(x, y, na.rm = na.rm), xs)
}
r_add(c(1, 4, 10)) 
# This looks good, but we need to test a few special cases:
r_add(NA, na.rm = TRUE)
r_add(numeric())
# Both outputs are incorrect. In the first case, we get a missing value even 
# though we've explicitly asked the function to ignore them. In the second, we
# get a NULL instead of a length on numeric vector.

# These problems are related. If we give Reduce() a length one vector, it doesn't
# have anything to reduce, so it just returns the input. If we give it an input
# of length zero, it always returns the NULL. The easiest way to fix this 
# problem is to use the init argument of Reduce(). This is added at the start of
# every input vector:
r_add <- function(xs, na.rm = TRUE) {
 Reduce(function(x, y) add(x, y, na.rm = na.rm), xs, init = 0)
}
r_add(c(1, 4, 10))
r_add(NA, na.rm = TRUE)
r_add(numeric())
# Note: r_add() is equivalent to sum()

# It could also be helpful to have a vectorised version of add() so that we can
# perform the addition of two vectors of numbers in element-wise fashion. We 
# could use Map() or vapply() to implement this, but neither is perfect. Map()
# returns a list, instead of a numeric vector, so we need to use 
# simplify2array(). vapply() returns a vector but it requires us to use a loop 
# over a set of indices.
v_add1 <- function(x, y, na.rm = FALSE) {
 stopifnot(length(x) == length(y), is.numeric(x), is.numeric(y))
 if (length(y) == 0) {
  return(numeric())
 }
 simplify2array(
  Map(function(x, y) add(x, y, na.rm = na.rm), x, y)
 )
}



















