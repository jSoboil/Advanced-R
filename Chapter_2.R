# This chapter summarises the most important data structures in base R. Base R data structures
# can be summarised by dimensionality and homonogeneity.

#     Homogenous;    Hetrogenous
# 1d Atomic Vector; List
# 2d Matrix;        Data frame
# nd Array;         

# Note that R has no 0-dimensional, or scalar data structure types.Individual numbers or 
# strings, which are technically 'scalars', are treated as vectors of length one.

# Given an object, the best way to understand what data structures it’s composed of is to use
# str(). 

# Vectors -----------------------------------------------------------------
# The basic data structure in R is the vector. Vectors come in two flavours: atomic vectors 
# and lists. They have three common properties:

# Type, typeof(), what it is.
# Length, length(), how many elements it contains.
# Attributes, attributes(), additional arbitrary metadata.

# They differ in the types of their elements: all elements of an atomic vector must be the same
# type, whereas the elements of a list can have different types.

# NB: is.vector() does not test if an object is a vector. Instead it returns TRUE only if the 
# object is a vector with no attributes apart from names. Use is.atomic(x) || is.list(x) to 
# test if an object is actually a vector.

## Atomic Vectors ----------------------------------------------------------
# There are four common types of atomic vectors: logical, integer, double (often called 
# numeric), and character.

# Atomic vectors are usually created with c(), short for concatenate/combine:
dbl_var <- c(1, 2, 3)
dbl_var
# With the L suffix, you get an integer rather than a double:
int_var <- c(1L, 6L, 10L)
int_var
# Use TRUE and FALSE (or T and F) to create logical vectors 
log_var <- c(TRUE, FALSE, T, F)
chr_var <- c("these are", "some strings")
log_var
chr_var
# Atomic vectors are always flat, even if you nest c()’s:
c(1, c(2, c(3, 4)))
c(1, 2, 3, 4)

# Missing values are specified with NA, which is a logical vector of length 1. NA will always 
# be coerced to the correct type if used inside c(), or you can create NAs of a specific type 
# with NA_real_ (a double vector), NA_integer_ and NA_character_.

# Types and sets ----------------------------------------------------------
# Given a vector, you can determine its type with typeof(), or check if it’s a specific type
# with an “is” function: is.character(), is.double(), is.integer(), is.logical(), or, more
# generally, is.atomic().
typeof(int_var)
is.integer(int_var)
is.atomic(int_var)
typeof(dbl_var)
is.double(dbl_var)
is.atomic(dbl_var)

# NB: is.numeric() is a general test for the “numberliness” of a vector and returns TRUE for
# both integer and double vectors. It is not a specific test for double vectors, which are 
# often called numeric.
is.numeric(int_var)
is.numeric(dbl_var)

# Coercion ----------------------------------------------------------------
# All elements of an atomic vector must be the same type, so when you attempt to combine 
# different types they will be coerced to the most flexible type. Types from least to most 
# flexible are: logical, 
#                       integer, 
#                               double, 
#                                      and character.

# For example, combining a character and an integer yields a character:
str(c("a", 1))

# When a logical vector is coerced to an integer or double, TRUE becomes 1 and FALSE becomes 0.
# This is very useful in conjunction with sum() and mean():
x <- c(FALSE, TRUE, FALSE)
as.numeric(x)
# Total no. of TRUEs:
sum(x)
# Proportion that are TRUE:
mean(x)

# It is important to be aware that coercion often happens automatically. Most mathematical 
# functions (+, log, abs, etc.) will coerce to a double or integer, and most logical 
# operations (&, |, any, etc) will coerce to a logical. You will usually get a warning
# message if the coercion might lose information. If confusion is likely, explicitly coerce 
# with as.character(), as.double(), as.integer(), or as.logical().

# Lists -------------------------------------------------------------------
# Lists are different from atomic vectors because their elements can be of any type, including
# lists. You construct lists by using list() instead of c():
x <- list(1:3, "a", c(TRUE, FALSE< TRUE), c(2.3, 5.9))
str(x)
# Lists are sometimes called recursive vectors, because a list can contain other lists. This 
# makes them fundamentally different from atomic vectors.
x <- list(list(list(list())))
str(x)
is.recursive(x)

# c() will combine several lists into one. If given a combination of atomic vectors and lists, 
# c() will coerce the vectors to list before combining them. Compare the results of list() 
# and c():
x <- list(list(1, 2), c(3, 4))
y <- c(list(1, 2), c(3, 4))
str(x)
str(y)

# You can test for a list with is.list() and coerce to a list with as.list(). You can turn a 
# list into an atomic vector with unlist(). If the elements of a list have different types, 
# unlist() uses the same coercion rules as c().

# Lists are used to build up many of the more complicated data structures in R. For example, 
# both data frames and linear models objects (as produced by lm()) are lists:
is.list(mtcars)
mod <- lm(mpg ~ wt, data = mtcars)
is.list(mod)

# Attributes --------------------------------------------------------------
# All objects can have arbitrary additional attributes, used to store meta-data about the 
# object. Attributes can be thought of as a named list (with unique names). Attributes can be 
# accessed individually with attr() or all at once (as a list) with attributes().
y <- 1:10
attr(y, "my_attribute") <- "This is a vector"
attr(y, "my_attribute")
# Hence when you call the structure of the object:
str(attributes(y))

# The structure() function returns a new object with modified attributes:
structure(1:10, my_attribute = "This is a vector")

# By default, most attributes are lost when modifying a vector:
attributes(y[1])
attributes(sum(y))

# However, the only attributes not lost are the three most important:

# 1. Names, a character vector giving each element a name;
# 2. Dimensions, used to turn vectors into matrices and arrays;
# 3. Class,used to implement the S3 object system.

# Each of these attributes has a specific accessor function to get and set values. When 
# working with these attributes, use names(x), class(x), and dim(x), NOT attr(x, "names"), 
# attr(x, "class"), and attr(x, "dim").

# Names -------------------------------------------------------------------
# You can name a vector in three ways:

# 1. When creating it
(x <- c(a = 1, b = 2, c = 3))
# 2. By modifying an existing vector in place
x <- 1:3; names(x) <- c("a", "b", "c")
# 3. By creating a modified copy of a vector
(x <- setNames(1:3, c("a", "b", "c")))

# Names don’t have to be unique. However, character subsetting is the most important reason 
# to use names and it is most useful when the names are unique.

# Not all elements of a vector need to have a name. If some names are missing, names() will 
# return an empty string for those elements. If all names are missing, names() will return 
# NULL.

y <- c(a = 1, 2, 3)
names(y)

z <- c(1, 2, 3)
names(z)

# You can create a new vector without names using unname(x), or remove names in place with 
# names(x) <- NULL.

# Factors -----------------------------------------------------------------
# One important use of attributes is to define factors. A factor is a vector that can contain
# only predefined values, and is used to store categorical data. Factors are built on top of
# integer vectors using two attributes: the class(), “factor”, which makes them behave 
# differently from regular integer vectors, and the levels(), which defines the set of 
# allowed values.
x <- factor(c("a", "b", "b", "a"))
class(x)
levels(x)

# You can't use values that are not in the levels
x[2] <- "c"

# and NB: you can't combine factors
c(factor("a"), factor("b"))

# Factors are useful when you know the possible values a variable may take, even if you don’t
# see all values in a given dataset. Using a factor instead of a character vector makes it 
# obvious when some groups contain no observations:
sex_char <- c("m", "m", "m")
sex_factor <- factor(sex_char, levels = c("m", "f"))

table(sex_char)
table(sex_factor)

# Sometimes when a data frame is read directly from a file, a column you’d thought would 
# produce a numeric vector instead produces a factor. This is caused by a non-numeric value 
# in the column, often a missing value encoded in a special way like . or -. To remedy the 
# situation, coerce the vector from a factor to a character vector, and then from a character
# to a double vector. (Be sure to check for missing values after this process.) Of course, a 
# much better plan is to discover what caused the problem in the first place and fix that; 
# using the na.strings argument to read.csv() is often a good place to start.

# Unfortunately, most data loading functions in R automatically convert character vectors to 
# factors. 

# Behaviour changed since R4.02/03, I think??

# But: instead, use the argument stringsAsFactors = FALSE to suppress this behaviour, and then
# manually convert character vectors to factors using your knowledge of the data. A global 
# option, options(stringsAsFactors = FALSE), is available to control this behaviour, but I 
# don’t recommend using it. Changing a global option may have unexpected consequences when 
# combined with other code (either from packages, or code that you’re source()ing), and 
# global options make code harder to understand because they increase the number of lines you
# need to read to understand how a single line of code will behave.

# While factors look (and often behave) like character vectors, they are actually integers. Be
# careful when treating them like strings. Some string methods (like gsub() and grepl()) will
# coerce factors to strings, while others (like nchar()) will throw an error, and still others
# (like c()) will use the underlying integer values. For this reason, it’s usually best to 
# explicitly convert factors to character vectors if you need string-like behaviour. In early
# versions of R, there was a memory advantage to using factors instead of character vectors, 
# but this is no longer the case.

# Data frames -------------------------------------------------------------
# A data frame is the most common way of storing data in R, and if used systematically makes 
# data analysis easier.

# Under the hood, a data frame is a list of equal-length vectors. This makes it a 
# 2-dimensional structure, so it shares properties of both the matrix and the list. This 
# means that a data frame has names(), colnames(), and rownames(), although names() and
# colnames() are the same thing. The length() of a data frame is the length of the underlying
# list and so is the same as ncol(); nrow() gives the number of rows. 

# You can subset a data frame like a 1d structure (where it behaves like a list), or a 2d 
# structure (where it behaves like a matrix).

# You create a data frame using data.frame(), which takes named vectors as input:
df <- data.frame(x = 1:3, y = c("a", "b", "c"))
str(df)

# Beware data.frame()’s default behaviour which turns strings into factors. Use 
# stringAsFactors = FALSE to suppress this behaviour. NOTE, the ‘factory-fresh’ default has 
# been TRUE previously but has been changed to FALSE for R 4.0.0.

# Testing and coercion ----------------------------------------------------
# Because a data.frame is an S3 class, its type reflects the underlying vector used to build
# it: the list. To check if an object is a data frame, use class() or test explicitly with
# is.data.frame():
typeof(df)
class(df)
is.data.frame(df)

# You can coerce an object to a data frame with as.data.frame():

# A vector will create a one-column data frame;
# a list will create one column for each element, it’s an error if they’re not all the same
# length;
# and a matrix will create a data frame with the same number of columns and rows.

## Combining data frames ---------------------------------------------------
# You can combine data frames using cbind() and rbind():

cbind(df, data.frame(z = 1:3))
rbind(df, data.frame(x = 10, y = "z"))

# When combining column-wise, the number of rows must match, but row names are ignored. When
# combining row-wise, both the number and names of columns must match - similar behaviours of
# a matrix. Use dplyr::rbind.fill() to combine data frames that don’t have the same columns.

# It’s a common mistake to try and create a data frame by cbind()ing vectors together. This
# doesn’t work because cbind() will create a matrix unless one of the arguments is already a
# data frame. Instead use data.frame() directly. For example,

# this is bad:
bad <- data.frame(cbind(a = 1:2, b = c("a", "b")), stringsAsFactors = TRUE)
str(bad)
# this is good:
good <- data.frame(a = 1:2, b = c("a", "b"), stringsAsFactors = FALSE)
str(good)

# The conversion rules for cbind() are complicated and best avoided by ensuring all inputs 
# are of the same type.

## Special columns ---------------------------------------------------------
# Since a data frame is a list of vectors, it is possible for a data frame to have a column 
# that is a list:
df <- data.frame(x = 1:3)
df$y <- list(1:2, 1:3, 1:4)
df

# HOWEVER, when a list is given to data.frame(), it tries to put each item of the list into 
# its own column, so this fails:
data.frame(x = 1:3, y = list(1:2, 1:3, 1:4))

# A workaround is to use I(), which causes data.frame() to treat the list as one unit:
dfl <- data.frame(x = 1:3, y = I(list(1:2, 1:3, 1:4)))
str(dfl)
dfl[2, "y"]
# I() adds the AsIs class to its input, but this can usually be safely ignored.

# Similarly, it’s also possible to have a column of a data frame that’s a matrix or array, 
# as long as the number of rows matches the data frame:
dfm <- data.frame(x = 1:3, y = I(matrix(1:9, nrow = 3)))
str(dfm)
dfm[2, "y"]

# Use list and array columns with caution: many functions that work with data frames ASSUME 
# that ALL COLUMNS ARE ATOMIC VECTORS.

# I do not do the exercises from this section as it deals with very basic stuff.

# End file ----------------------------------------------------------------