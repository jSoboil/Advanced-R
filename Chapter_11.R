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
 mpg ~ I(1 / disp)+ wt
)


















