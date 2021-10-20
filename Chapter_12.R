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

### Memoisation -------------------------------------------------------------








