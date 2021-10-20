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



