# Functions ---------------------------------------------------------------
## Function components -----------------------------------------------------
# All R functions have three parts:

#  1. the body(), the code inside the function;
#  2. the formals(), the list of arguments which controls how you can call
#     the function
#  3. the environment(), the "map" of the location of the function's variables.

# When you print a function in R, it shows you these three important 
# components. If the environment isn't displayed, it means that the function
# was created in the global environment.

## Primitive functions -----------------------------------------------------
# The exception to the rule of three components is primitive functions. 
# Primitive functions, like sum(), call C code with .Primitive() and contain
# no R/S code. Therefore, their formals(), body(), and environment() are all
# NULL.
sum
formals(sum)
body(sum)

# Primitive functions are only found in base R, operate on a lower-level, and
# can therefore be more efficient as well as have different rules for 
# argument matching. Thus efficiency comes at a cost of behaving differently
# from all other functions in R. 

## Lexical scoping ---------------------------------------------------------
# Scoping is the set of rules that govern how R looks up the value of a 
# symbol. In the e.g. below, scoping is the set of rules R applies to go from
# the symbol x to its value 10:
x <- 10 
x

# Understanding scoping allows you to:
#  build tools by composing functions;
#  overrule the usual evaluation tools and do non-standard evaluation.

# R has two types of scoping: lexical scoping, implemented automatically at 
# the language level; and dynamic scoping, used in select functions to save 
# typing during interactive analysis. Dynamic scoping is described in later 
# chapters.

# Lexical scoping looks up symbol values based on how functions were nested 
# when they were created, not how they are nested when they are called. With
# lexical scoping, you don't need to know how the function is called to 
# figure out where the value of a variable will be looked up. You just need
# to look at the function's definition.

# The 'lexical' in lexical scoping doesn't correspond to the usual English 
# definition ("of relating to words or the vocabulary of a language as 
# distinguished from its grammar and construction") but comes from the computer
# science term "lexing", which is part of the process that converts code 
# represented as text to meaningful pieces that the programming language 
# understands.

# There are four basic principles behind R's implementation of lexical scoping:
#  name masking;
#  functions vs. variables;
#  a fresh start;
#  dynamic lookup

# Every operation is a function call --------------------------------------
# Remember in R:
#  Everything that exists is an object
#  Everything that happens is a function call

# Main takeaway: use ` ` to refer to an object, and "" or '' to refer to a string...

## Function arguments ------------------------------------------------------
# The formal arguments of a function are a property of the function, whereas the actual
# or calling arguments can vary each time you call a function.

### Calling functions -------------------------------------------------------
# Calling a function given a list of arguments: suppose you had a list of function
# arguments, such as...
args <- list(1:10, na.rm = TRUE)

# How could you then send that list to the mean() function? You need to do.call()
do.call(mean, args)
# ... this is equivalent to:
mean(1:10, na.rm = TRUE)

# What about default and missing arguments?
# Functions in R can have default values...
f <- function(a = 1 , b = 2) {
 c(a, b)
}
f()
# Since arguments in R are evaluated lazily, the default value can be defined in terms
# of other arguments:
g <- function(a = 1, b = a * 2) {
 c(a, b)
}
g()
g(10)
# Default arguments can even be defined in terms of variables created within a 
# function. This is frequently used in base R functions, but it is arguably bad
# practice as you will not understand what the defaults values will be unless you 
# read the source code, for example:
h <- function(a = 1, b = d) {
 d <- (a + 1) ^ 2
 c(a, b)
}
h()
h

# However, you can determine if an argument was supplied or not with the missing()
# function.
i <- function(a, b) {
 c(missing(a), missing(b))
}
i()
i(a = 1)
i(b = 2)
i(1, 2)
# Note: sometimes you may want to add a non-trivial default value, which might take 
# several lines of code to compute. Instead of inserting that code in the function
# definition, you could use missing() to conditionally compute it if needed. However,
# this makes it hard to know which arguments are required and which are optional 
# without carefully reading the documentation. Instead, it can also be useful to set
# the default value to NULL and use is.null() to check if the argument was supplied.