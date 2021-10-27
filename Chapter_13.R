# Non-standard Evaluation -------------------------------------------------
# Unlike most programming languages, where you can only access the arguments of a 
# function, in R you can access the code used to compute a function. This makes it
# possible to evaluate code in non-standard ways, using what is known as 
# non-standard evaluation (NSE). NSE is particularly useful for functions when 
# doing interactive data analysis because it can dramatically reduce the amount of
# typing.

## Capturing expressions ---------------------------------------------------
# substitute() makes non-standard evaluation possible. It looks at a function
# argument and instead of 'seeing' the value, it sees the code used to compute the
# value. For example:
f <- function(x) {
 substitute(x)
}
f(1:10)
x <- 10
f(x)
y <- 13
f(x + y^2)

# substitute() works because function arguments are represented by a special type
# of object called a *promise*. A promise captures the expression needed to 
# compute the value and the environment in which to compute it. substitute() is 
# often paired with deparse(), which takes the result of substitute(), an 
# expression, and turns it into a character vector.
g <- function(x) {
 deparse(substitute(x))
}
g(1:10)
g(x)
g(x + y^2)

## Non-standard evaluation in subset ---------------------------------------
# While printing out code supplied to an argument value can be useful, we can 
# actually do more with the unevaluated code. Take subset(), for example. It is
# a useful interactive shortcut for subsetting data frames: instead of repeating
# the name of the data frame many times, you can save some typing
sample_df <- data.frame(a = 1:5, b = 5:1, c = c(5, 3, 1, 4, 1))
subset(sample_df, a >= 4)
# ... which is equivalent to sample_df[sample_df$a >= 4, ]
subset(sample_df, b == c)
# ... which is equivalent to sample_df[sample_df$b == sample_df$c, ]

# subset() is special because it implements different scoping rules: the 
# expressions a >= 4 and b == c are evaluated within the specific data frame, 
# rather than in the current or global envr. This is the essence of NSE.

# So how does subset() work? We want x to be interpreted as sample_df$x, not 
# global_env()$x. To do this, we need eval(). This function takes an expression 
# and evaluates it in the specified envir.

# However, we first need to quote() function: it captures an unevaluated 
# expression like substitute(), but doesn't do any of the advanced transformations
# that can make substitute() confusing. quote() always returns its input as is:
quote(1:10)
quote(x)
quote(x + y^2)
# So, we need quote() to experiment with eval() because eval()'s first arg is an
# expression. If you only provide one arg, it will evaluate the expression in the
# current envir. This makes eval(quote()) exactly equivalent to x, regardless of
# what x is:
eval(quote(x <- 1))
eval(quote(x))
rm(y)
eval(quote(y))

# eval()'s second arg specifies the envr. in which the code is evaluated:
x <- 10
eval(quote(10))
e <- new.env()
e$x <- 20
eval(quote(x), e)

# But since lists and data frames bind names to values in a similiar way to 
# envrs., eval()'s second arg need not be limited to an envr.: it can also be
# a list or a data frame!
eval(quote(x), list(x = 30))
eval(quote(x), list(x = 40))

# So, this gives us one part of subset():
eval(quote(a >= 4), sample_df)
eval(quote(b == c), sample_df)

# However, a common mistake when using eval() is to forget to quote() the first 
# arg. For example, compare the results below:
a <- 10
eval(quote(a), sample_df)
eval(a, sample_df)
eval(quote(b), sample_df)
eval(b, sample_df)

# Moving on, we can use eval() and substitute() to write subset(). We first 
# capture the call representing the condition, then we evaluate it in the context
# of the data frame and finally, we use the result for subsetting:
subset_2 <- function(x, condition) {
 condition_call <- substitute(condition)
 r <- eval(condition_call, x)
 x[r, ]
}
subset_2(sample_df, a >= 4)

# End file ----------------------------------------------------------------