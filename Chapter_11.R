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