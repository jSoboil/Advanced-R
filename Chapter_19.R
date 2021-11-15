# High performance functions with Rcpp ------------------------------------
# This chapter covers writing and calling C++ code in R for improved computing
# performance

## Getting started with C++ ------------------------------------------------
# The cppFunction() allows you to write C++ functions in R:
library(Rcpp)
cppFunction('int add(int x, int y, int z) {
 int sum = x + y + z;
 return sum;
}')
# add works like a regular R function:
add
add(x = 100, y = 22, z = 1)
# When this code is run, Rcpp will compile the C++ code and construct an R 
# function that connects to the compiled C++ function.

### No inputs, scalr output -------------------------------------------------
# Let's start with a very simple function. It has no arguments, and always 
# returns the integer 1. In R:
one <- function() 1L
# The equivalent function in C++ is:
# int one() {
#  return 1;
# }
# ... which can be compiled and used in R with cppFunction as:
cppFunction('int one() {
            return 1;
}')

# The above illustrates a number of important differences between R and C++:

# 1. The syntax to create a function looks like the syntax to call a function;
# you don't use assignment to create a function like you do in R!

# 2. You must declare the type of output the function returns. The above function
# returns an int (a scalar integer). The classes for the most common types of R
# vectors are: NumericVector, IntegerVector, CharacterVector, and LogicalVector.

# 3. Scalars and Vectors are different. The scalar equivalents of numeric, 
# integer, character, and logical vectors are: double, int, String, and bool.

# 4. You must use an explicit return statement to return a value from a function.

# 5. Every statement is terminated by a ;. 

### Scalar input,  scalar output --------------------------------------------
# The next example function implements a scalar version of the sign() function
# which returns 1 if the input is positive, and -1 if it's negative. In R, this
# looks like:
signR <- function(x) {
 if (x > 0) {
  1
 } else if (x == 0) {
  0
 } else {
  -1
 }
}
# ... and in C++:
cppFunction('int signC(int x) {
  if (x > 0) {
   return 1;
  } else if (x == 0) {
   return 0;
  } else {
   return -1;
   }
}')
signC(-1)

# Note how in the C++ version:
# 1. We declare the type of each input in the same way we declare the type of 
# output. While this makes the code a little more verbose, it also makes it very
# obvious what type of input the function needs.

# 2. That the if syntax is identical. C++ also has a while statement that works 
# the same way as R's does. As in R, you can also use break to exit the loop; but
# to skip one iteration you need to use continue, NOT next.

### Vector input,  scalar output --------------------------------------------
# One big difference between R and C++ is the cost of loops - it is much lower in
# C++. For example, we could implement the sum function in R using a loop. In R:
sumR <- function(x) {
 total <- 0
 for (i in seq_along(x)) {
  total <- total + x[i]
 }
 
 total
}
# In C++, there is very little overhead with loops:
cppFunction('double sumC(NumericVector x) {
            int n = x.size();
            double total = 0;
            for (int i = 0; i < n; ++i) {
            total += x[i];
            }
         return total;
}')

# Again, the C++ version is similar, but:

# 1. To find the length of the vector, we use the .size() method, which returns 
# an integer. C++ methods are called with . (i.e., a full stop).

# 2. The for statement has a different syntax: for(init, check; increment). This
# loop is initialised by creating a new variable called i with value 0. Before 
# each iteration we check that i < n, and terminate the loop if it's not. After
# each iteration, we increment the value i by one, using the special prefix 
# operator ++ which increases the value i by 1.

# 3. In C++, vector indices start at 0. Note: this is a **very** common source of
# bugs when converting R functions to C++.

# 4. Use = for assignment, not <-.

# 5. C++ provides operators that modify in-place: total += x[i] is equivalent to
# total = total + x[i]. Similar in place operators are -=, *=, and /=

# Overall, this is a very good example of where C++ is much more efficient than
# R. As shown below, the sumC() function is competitive with the built-in (and 
# highly optimised) sum(), while sumR() is several orders of magnitude slower!
x <- runif(1e3)
microbenchmark::microbenchmark(
 sum(x),
 sumC(x),
 sumR(x)
)

### Vector input,  vector output --------------------------------------------
# Next we'll create a function that computes the Euclidean distance between a
# value and a vector of values:
pdistR <- function(x, ys) {
 sqrt((x - ys) ^ 2)
}
# ... it's not obvious that we want x to be a scalar from the function 
# definition. That would need to be made clear in the documentation. However,
# that's not a problem in the C++ version because we have to be explicit about
# these types:
cppFunction('NumericVector pdistC(double x, NumericVector ys) {
            int n = ys.size();
            NumericVector out(n);
            
            for (int i = 0; i < n; ++i) {
             out[i] = sqrt(pow(ys[i] - x, 2.0));
           }
          return out; 
}')
# The above function only introduces a few new concepts:

# 1. We create a new numeric vector of length n with a constructor: 
# NumericVector out(n). Another useful way of making a vector is to copy an 
# existing one: NumericVector zs = clone(ys).

# 2. C++ uses pow(), not ^, for exponentiation.

### Matrix input,  vector output --------------------------------------------
# Each vector type in C++ also has a matrix equivalent: NumericMatrix, 
# IntegerMatrix, CharacterMatrix, and LogicalMatrix. Using them is 
# straightfoward. For example, we could create a function that reproduces
# rowSums():
cppFunction('NumericVector rowSumsC(NumericMatrix x) {
             int nrow = x.nrow(), ncol = x.ncol();
             NumericVector out(nrow);
            
             for (int i = 0; i < nrow; i++) {
              double total = 0;
             for (int j = 0; j < ncol; j++) {
              total += x(i, j);
             }
           out[i] = total;
           }
          return out;
    }')
set.seed(1014)
x <- matrix(sample(100), 10)
rowSumsC(x)

# ... the main differences are that:

# 1. In C++, you subset a matricx with (), not [].

# 2. You use .nrow() and .ncol() methods to get the dim of the matrix.

### Using source C++ --------------------------------------------------------
# Despite the ease use of the cppFunction(), for most real-world problems it is
# easier to use stand-alone C++ files and then source them into R using 
# sourceCpp(). This let's you take advantage of the text editor support for C++
# files (e.g. syntax highlighting) and it also makes it easier to identify the
# line numbers in compilation errors.

# Stand-alone C++ files should have the .cpp extension and need to start with:
# <Rcpp.h>
# using namespace Rcpp;

# Also, for each function you want to make available in R, you need to prefix it
# with:
# // [[Rcpp::export]]

# Note: the space is mandatory!

# You can also embed R code in special C++ comment blocks, which is convenient
# when you want to run some test code:
# /*** R
# This is R code
# */

# Then, to compile the C++ code, use sourceCpp("path/to/file/file.cpp").
sourceCpp("C++/Example_1.cpp")

### Exercises ---------------------------------------------------------------
# Exercise 1:
## f1 = mean()
## f2 = cumsum()
## f3 = any()
## f4 = Position()
## f5 = pmin()

# Exercise 2: convert the following functions into C++
# all()
sourceCpp("C++/allC_func.cpp")
x_true <- rep(x = TRUE, length = 100)
## C++ version:
allC(x_true)
x_false <- c(x_true[-1], FALSE)
allC(x_false)
## R version:
all(x_true)

# Get sample data:
x <- sample(1:100, size = 100, replace = TRUE)
# cumprod()
sourceCpp("C++/cumprod_func.cpp")
## C++ version:
cumprodC(x = x)
## R version:
cumprod(x)

# cummin()
sourceCpp("C++/cummin_func.cpp")
## C++ version:
cumminC(x)
## R version:
cummin(x = x)

# cummax()
sourceCpp("C++/cummax_func.cpp")
## C++ version:
cummaxC(x)
## R version:
cummax(x)

# Exercise 3: convert diff() into C++ (start by assuming lag 1, and then 
# generalise by assuming lag n)
## C++ diff() version with lag 1:
sourceCpp("C++/diff_lagOne_func.cpp")
## C++ version:
diffC(x)
## R version:
diff(x)

## C++ diff() version with lag n:
sourceCpp("C++/diff_lagN_func.cpp")
## C++ version:
diffC(x = x, lag = 2)
## R version:
diff(x = x, lag = 2)

# Exercise 4: convert range() to C++:
sourceCpp("C++/range_func.cpp")
## C++ version:
rangeC(x)
## R version:
range(x)

# Exercise 5: convert var() to C++:
sourceCpp("C++/var_func.cpp")
## C++ version:
varC(x)
## R version:
var(x)

## Attributes and other classes --------------------------------------------
# All R objects have attributes, which can be queried and modified with .attr().
# Rcpp also provides .names() as an alias for the name attribute. The C++ source 
# code below illustrates these methods. Note the use of ::create(), a *class*
# method. This allows you to create an R vector from C++ scalar values:
sourceCpp("C++/create_func_example.cpp")
attribs()

# Note that for S4 objects, .slot() plays a similar role to .attr().

### Lists and data frames ---------------------------------------------------
# Rcpp also provides class List and DataFrame, but they are more useful for 
# output than input. This is because lists and data frames can contain arbitrary
# classes but C++ needs to know their classes in advance. If the list has known
# structure (e.g., it's an S3 object), you can extract the components and 
# manually convert them to their C++ equivalents with as as(). For example, the
# object created by lm(), the function that fits a linear model, is a list whose
# components are always of the same type. The following code illustrates how you
# might extract the mean percentage error (mpr()) from a linear model. This isn't
# a good example, since it is easily implemented in R without much computing 
# cost, but it shows how to work with an important S3 object. In the source code,
# note the use of .inherits() and stop() to check that the object is a linear 
# model.
sourceCpp("C++/mpe_func.cpp")
mod <- lm(mpg ~ wt, data = mtcars)
round(mpe(mod), digits = 4)

## Missing Values ----------------------------------------------------------
# If you're working with missing values, it is important to know two things:

# 1. how R's missing values behave in C++'s Scalars (e.g. double)
# 2. how to get and set missing values in vectors (e.g. NumericVector)

### Scalars -----------------------------------------------------------------
# The following source code explores what happens when you take one of R's 
# missing values, coerce it into a scalar, and then coerce it back to an R
# vector.
sourceCpp("C++/scalar_ex.cpp")
str(scalar_missings())
# ... with the exception of the bool, things look okay. However, it is not as 
# straightforward as it seems, as shown in the section below.

#### Integers ----------------------------------------------------------------
# With integers, missing values are stored as the smallest integer. But, since 
# C++ doesn't know that the smallest integer has this special behaviour, if you
# do anything to it you're likely to get an incorrect value. For example:
evalCpp('NA_INTEGER + 1')

# Hence, if you want to work with missing values in integers, either use a length
# one IntegerVector or be **very** careful with your code.

#### Doubles -----------------------------------------------------------------
# With doubles, one may be able to get away with missing values and working with
# NaNs. This is because R's NA is a special type of IEEE 754 floating point 
# number NaN. So, any logical expression that involves a NaN (or in C++, NAN)
# always evaluates as FALSE:
evalCpp("NAN == 1")
evalCpp("NAN < 1")
evalCpp("NAN > 1")
evalCpp("NAN == NAN")

# However, it is important to be careful when combining this with boolean values:
evalCpp("NAN & TRUE")
evalCpp("NAN || TRUE")

# But in numeric contexts, NaNs will propagate NAs:
evalCpp("NAN + 1")
evalCpp("NAN - 1")
evalCpp("NAN * 1")
evalCpp("NAN / 1")

#### Strings -----------------------------------------------------------------
# String is a scalar string class introduced by Rcpp, so it knows how to deal 
# with missing values.

#### Boolean -----------------------------------------------------------------
# While C++'s bool has two possible values (true, false), a logical vector in R
# has three (TRUE, FALSE, and NA). If you coerce a length 1 logical vector, make
# sure it doesn't contain missing values otherwise they will be converted to 
# TRUE!

#### Vectors -----------------------------------------------------------------
# With vectors, one has to use a missing value specific to the type of vector, 
# NA_REAL, NA_INTEGER, NA_LOGICAL, NA_STRING.

# To check if a value in a vector is missing, use the class method ::is_na():
sourceCpp("C++/is_na_ex.cpp")
is_naC(c(NA, 5.4, 3.2, NA))

# Another alternative is the sugar function is_na(), which takes a vector and 
# returns a logical vector.

## Exercises ---------------------------------------------------------------
# 1. Rewrite any one of the previous functions to deal with missing values. If 
# na.rm is true, ignore the missing values. If na.rm is false, return a missing
# value if the input contains any missing values.
sourceCpp("C++/na_rangefunc.cpp")
## Sample data:
x <- sample(c(1:100, NA), size = 1000, replace = TRUE)
## Test:
### Ignore NAs:
na_rangeC(x = x)
### Test for NAs:
na_rangeC(x = x, na_rm = TRUE)

# 2. Rewrite cumsum() and diff() so they can handle missing values.
## diff():
sourceCpp("C++/na_diff_func.cpp")
### Sample data:
x <- sample(c(1:50, NA), size = 200, replace = TRUE)
### Test;
diffC(x = x, lag = 1, na_rm = TRUE)
diff(x)

## cumsum():
sourceCpp("C++/na_cumsum.cpp")
### Test:
cumsumC(x = x, na_rm = TRUE)
cumsum(x)

## Rcpp Sugar --------------------------------------------------------------
# Rcpp provides a lot of syntactic 'sugar' to ensure that C++ functions work 
# very similarly to their R equivalents. In fact, Rcpp sugar makes it possible 
# to write efficient C++ code that looks almost identical to its R equivalent.
# If there is a sugar version of the function, you should use it. Sugar 
# functions can be roughly broken down into:

# arithmetic and logical operators
# logical summary functions
# vector views
# other useful functions

# End file ----------------------------------------------------------------