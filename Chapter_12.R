# Function Operators ------------------------------------------------------
# FOs are functions that take one or more functions an input and return a 
# function as output. Basically, FOs extract common patterns of anonymous 
# function use. The following shows a simple FO, chatty(). It wraps a function,
# making a new function that prints out its first argument:
chatty <- function(f) {
 function(x, ...) { 
  res <- f(x, ...)
  cat("Processing", x, "\n", sep = "")
  res
  }
}
f <- function(x) x ^ 2
s <- c(3, 2, 1)
chatty(f)(1)
vapply(s, chatty(f), numeric(1))

# There are four types of FOs: behavioural, input, output, and combining.

## Behavioural FOs --------------------------------------------------------
# Behavioural FOs leave the inputs and outputs of a function unchanged, but add 
# extra behaviour. In this section, we look at functions which implement three 
# useful behaviours:

# Add a delay to avoid swamping a server with requests
# Print to console every n invocations to check on a long running process
# Cache previous computations to improve performance

# To motivate creating these behaviours, imagine we want to DL a long vector of
# URLs. That's simple with lapply() and download_file():
download_file <- function(url, ...) {
 download.file(url, basename(), ...)
}
lapply(urls, download_file)

# However, there are a number of useful behaviours we might want to add to this 
# function. E.g., if the list is long, we might want to print . every ten URLs
# so that we know that the function is still working. Or, if we're DLing files 
# over the internet, we might want to add a small delay between each request to
# avoid hammering the server. Implementing these behaviours in a for loop is 
# rather complicated. We can no longer use lapply() because we need an external
# counter.
i <- 1
for (url in urls) {
 i <- i + 1
 if (i %% 10 == 0) {
  cat(".")
  Sys.sleep(1)
  download_file(url)
 }
}
# Understanding this code can be relatively hard, and can be simplified using FOs
# which encapsulate these behaviours, allowing you to write code like this:
lapply(urls, dot_every(10, delay_by(1, download_file())))

# Implementing delay_by is relatively straightfoward, and follows the same basic
# template that we'll see for the majority of FOs:
delay_by <- function(delay, f) {
 function(...) {
  Sys.sleep(delay)
  f(...)
 }
}
system.time(runif(1000000))
system.time(delay_by(0.1, runif)(1000000))

# dot_every() is a bit more complicated because it needs to manage a counter:
dot_every <- function(n, f) {
 i <- 1
 function(...) {
  if (i %% 10 == 0) cat(".")
  i <<- i + 1
  f(...)
  }
 }
x <- lapply(1:100, runif)
x <- lapply(1:100, dot_every(10, runif))
# Notice that the function is the last argument in each FO. 


### Capturing function invocations ------------------------------------------
# One challenge with functionals is that it can be hard to see what's going on
# inside of them. Fortunately, we can use FOs to peer behind the curtain with 
# tee().

# tee() has three arguments, all functions: f, the function to modify; on_input(),
# a function that's called with the inputs to f; and on_output, a function that's
# called with the output from f.
ignore <- function(...) NULL
tee <- function(f, on_input = ignore, on_output = ignore) {
 function (...) {
  on_input(...)
  on_output(...)
  output <- f(...)
  on_output(output)
  output
 }
}

# We can use tee() to look inside the uniroot() functional and see how it 
# iterates its way to a solution. The following example finds where x and cos(x)
# intercept:
g <- function(x) cos(x) - x
zero <- uniroot(g, c(-5, 5))
show_x <- function(x, ...) cat(sprintf("%+.08f", x), "\n")
# The location where the function is evaluatgited:
uniroot(tee(g, on_input = show_x), c(-5, 5))
# The value of the function:
uniroot(tee(g, on_output = show_x), c(-5, 5))

# cat() allows us to see what's happening as the function runs, but it doesn't
# give use a way to work with the values after the function has completed. To do
# that we could capture the sequence of call by creating a function - remember()
# - that records every argument called and retrieves them when coerced into a 
# list.
remember <- function() {
 memory <- list()
 f <- function (...) {
  # This is inefficient!
  memory <<- append(memory, list(...))
  invisible()
 }
 
 structure(f, class = "remember")
}
as.list.remember <- function(x, ...) {
 environment(x)$memory
}
print.remember <- function(x, ...) {
 cat("Remembering...\n")
 str(as.list(x))
}

# Now we can draw a picture showing how uniroot zeroes in on the final answer:
locs <- remember()
vals <- remember()
zero <- uniroot(tee(g, locs, vals), c(-5, 5))
x <- unlist(as.list(locs))
error <- unlist(as.list(vals))
plot(x, type = "b"); abline(h = 0.739, col = "grey50")
plot(error, type = "b"); abline(h = 0, col = "grey50")

# End file ----------------------------------------------------------------