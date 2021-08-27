library(pryr)

# Environments ------------------------------------------------------------
# Every environment has a parent environment. The parent is used to implement lexical
# scoping: if a name is not found in an environment, then R will look in its parent (
# and so on). Only *one* environment does not have a parent: the empty environment.

# Generally, an environment is similar to a list, with four exceptions:
# 1. Every object in an environment has a unique name
# 2. The objects of an environment are not ordered
# 3. An environment has a parent
# 4. Environments have reference semantics

# Specifically, an environment is made up of two components, the *frame*, which 
# contains the name-object bindings (and behaves much like a named list), and the
# parent environment. Note: parent.frame() does not give you the frame of the parent
# envr due to inconsistencies in naming conventions.

# There are four special environments:

# The globalenv(), or global environment, is the interactive workspace. This is the 
# environment in which one normally works in. The parent of the global environment
# is the last package that you attached with library() or require().

# The baseenv(), or base environment, is the environment of the base package. Its 
# parent is the empty environment.

# The emptyenv() is the ultimate ancestor of all environments, and the only 
# environment without a parent.

# environment() is the current environment.

# search() lists all parents of the global environment. This is called the search 
# path because objects in these environments can be found from the top-level 
# interactive workspace. It contains one environment for each attached package and 
# any other objects that you've attach()ed. It also contains a special environment
# called Autoloads which is used to save memory by only loading package objects (like 
# big datasets) when needed.

# You can access any environment on the search list using as.environment()
search()
as.environment("package:stats")

# To create a new environment manually, use new.env(). You can then list the bindings
# in the envr's frame with ls() and see its parent with parent.env():
e <- new.env()
parent.env(e)
ls(e)
# The easiest way to modify the bindings in an envr is to treat it like a list:
e$a <- 1
e$b <- 2

ls(e)
e$a

# By default, ls() only shows names that don't begin with . Use all.names = TRUE to
# show all bindings in an envr:
e$.a <- 2
ls(e, all.names = TRUE)

# Given a name, you can extract the value to which it is bound with $, [[, or get()

# $ and [[only in one environment and return NULL if there is no binding associated
# with the name.
# get() uses the regular scoping rules and throws an error if the binding is not 
# found.
e$c <- 3
e$c
e[["c"]]
get("c", envir = e)

# Deleting objects from environments works a little differently from lists. With a 
# list you can remove an entry by setting it to NULL. In environments, that will 
# create a new binding to NULL. Instead use rm() to remove the binding:
e <- new.env()
e$a <- 1
e$a <- NULL
ls(e)

rm("a", envir = e)
ls(e)

# You can determine if a binding exists in an environment with exists(). Like get(),
# its default behaviour is to follow the regular scoping rules and look in parent
# environments. If you don't want this behaviour, use inherits = FALSE.
x <- 10
exists("x", envir = e)
exists("x", envir = e, inherits = FALSE)

# NOTE: To compared envrs, you must use idenitical(), not!!! ==:
identical(globalenv(), environment())
globalenv() == environment()

## Recursing over environments ---------------------------------------------
# Environments in R form a tree, so it is often convenient to write a recursive 
# function. Given a name, the function where() finds the envr *where* the name is
# defined, using R's regular scoping rules:
x <- 5
where("x")
where("mean")
# The definition of where is straightforward. It has two arguments: the name to look
# for (as a string), and the envr in which to start the search.
where <- function(name, envr = parent.frame()) {
 if (identical(env, emptyenv())) {
  # Base case
  stop("Can't find", name, call. = FALSE)
 } else if (exists(name, envir = env, inherits = FALSE)) {
  # Success case
  env
 } else {
  # Recursive case
  where(name, parent.env(env))
 }
}

## Function environments ---------------------------------------------------
# Most new envr are created as a consequence of using functions, not by using 
# new.env(). There are four types of envrs associated with using functions.

### The enclosing environment -----------------------------------------------
# When a function is created, it gains a reference to the envr where it was made. 
# This is the enclosing envr and is used for lexical scoping. You can determine the
# enclosing envr of a function by calling environment() with a function as its first
# argument:
y <- 1
f <- function(x) {
 x + y
}
environment(f)

### Binding environments ----------------------------------------------------
# The binding envrs of a function are all the envrs which have a binding to it. 
# I.e., all the other objects associated with it. The binding envr determines how
# we find the function; in contrast, the enclosing envr determines how the function
# finds values.

# This distinction is NB for package namespaces. Package namespaces keep packages 
# independent. For example, if package A uses the base mean() function, what happens
# if package B creates its own mean() function? Namespaces ensure that package A 
# continues to use the base mean() function, and that package A is not affected by 
# package B (unless specified).

# Namespaces are implemented using envrs, taking advantage of the fact that functions
# don't have to live in their enclosing envrs.

# End file ----------------------------------------------------------------