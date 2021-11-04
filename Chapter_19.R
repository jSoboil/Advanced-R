# High performance functions with Rcpp ------------------------------------

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
