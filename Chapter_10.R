# Functional Programming --------------------------------------------------
# At its heart, R is a functional programming language. 

## Motivation --------------------------------------------------------------
# Imagine you've loaded a data file that uses -99 to represent missing values. You 
# want to replace all the -99s with NAs.

# Generate sample data set:
set.seed(1014)
df_1 <- data.frame(
 replicate(
  6, sample(c(1:10, -99), 6, replace = TRUE)
  )
 )
names(df_1) <- letters[1:6]
df_1

fix_NA <- function(x) {
 x[x == -99] <- NA
 x
}
# Now you can use lapply, which takes three inputs: x, a list, a function, and ... or 
# other arguments to pass to f(). 
df_1[] <- lapply(df_1, fix_NA)
df_1

# The key idea to note is function composition. Take two simple functions, one which
# does something to every column and one which fixes missing values, and combine them
# to fix missing values in every column of the dataset.

# But what if different columns used different codes for missing values? You might
# be tempted to copy-paste. However, you could use closures, which are functions that
# make and return functions. Closures allow use to make functions based on a template:
NA_fixer <- function(na_value_1, na_value_2) {
 function(x) {
  x[x == na_value_1 | x == na_value_2] <- NA
  x
 }
}

set.seed(1014)
df_2 <- data.frame(
 replicate(
  6, sample(c(1:10, -99), 6, replace = TRUE)
  ),
  replicate(
  6, sample(c(1:10, -999), 6, replace = TRUE)
  )
 )
names(df_2) <- letters[1:12]

df_2[] <- lapply(df, NA_fixer(na_value_1 = -99, na_value_2 = -999))
df
# Note that adding a double logical like above is not always the best solution.

# Now consider a related problem. Once you've cleaned up your data, you might want to
# compute the same set of numerical summaries for each variable. You could 
# individually code summary statistics. But you are better off identifying and 
# removing duplicate items.

# You could write a summary function:
summary <- function(x) {
 c(mean(x), median(x), sd(x), mad(x), IQR(x))
}
lapply(df_1, summary)

# It's a great start, but there's still some duplication. x and na.rm are explicitly
# and implicitly repeated. To remove this source of duplication, you can take
# advantage of another function programming technique: storing functions in lists:
summary <- function(x) {
 funs <- c(mean, median, sd, mad, IQR)
 lapply(funs, function(f) f(x, na.rm = TRUE))
}
summary(df_1)

# Before learning about these techniques in more detail, is important to understand
# the simplest FP tool, the anonymous function.

## Anonymous functions -----------------------------------------------------