# Subsetting --------------------------------------------------------------
# R's subsetting features are powerful and fast. Mastery of subsetting allows you to succinctly
# express complex operations. Subsetting is hard to learn because you need to learn a number of
# interrelated concepts:

# 1. The three subsetting operators;
# 2. The six types of subsetting;
# 3. Important differences in behaviour for different objects (e.g. vectors, lists, factors,
#    matrices, and data-frames); and
# 4. The use of subsetting in conjunction with assignment.

# Subsetting is a natural complememt to str(). str() shows you the structure of an object, and
# subsetting allows you to pull out the pieces that you are interested in.

## Subsetting for atomic vectors -------------------------------------------
# Let's explore different types of subsetting with a simple vector:
x <- c(2.1, 4.2, 3.3, 5.4)

# There are five things that you can use to subset a vector.

# 1. Positive Integers return elements at the specified positions:
x[c(3, 1)]
x[order(x)]
# Duplicated indices yield duplicated values,
x[c(1, 1)]
# Real numbers are silently truncated,
x[c(2.1, 2.9)]

# 2. Negative Integers, omit elements at the specified positions:
x[-c(3, 1)]
# but you can't mix positive and negative integers in a single subset:
x[c(-1, 2)]

# 3. Logical Integers, select elements where the corresponding logical value is TRUE. This is
#    probably the most useful type of subsetting because you write the expression that creates
#    the logical vector:
x[c(TRUE, TRUE, FALSE, FALSE)]
x[x > 3]
# if the logical vector is shorter than the vector being subsetted, it will be recycled to the
# same length. For example,
x[c(TRUE, FALSE)]
# is equivalent to
x[c(TRUE, FALSE, TRUE, FALSE)]

# A missing value in the index always yields a missing value in the output:
x[c(TRUE, TRUE, NA, FALSE)]

# If the vector is named, you can use:

# Character vectors, which return elements with matching names.
(y <- setNames(x, letters[1:4]))
y[c("d", "c", "a")]
# Like integer indices, you can repeat indices
y[c("a", "a", "a")]
# and when subsetting with [ names are always exactly matched exactly
z <- c(abc = 1, def = 2)
z[c("a", "d")]

## Subsetting for Lists ----------------------------------------------------
# Subsetting a list works the same way for subsetting an atomic vector. Using [] will always
# return a list; [[]] and $ let you pull out components of the list.

# You can subset higher-dimensional structures in three ways:
# 1. with multiple vectors;
# 2. with a single vector; and
# 3. with a matrix.

# The most common way of subsetting matrices (2d) and arrays (>2d) is a simple generalisation of 1d
# subsetting; you supply a 1d index for each dimension, separated by a comma. Blank subsetting is 
# now useful because it lets you keep all rows and columns
a <- matrix(1:9, nrow = 3)
colnames(a) <- c("A", "B", "C")
a[1:2, ]
a[c(TRUE, FALSE, TRUE), c("B", "A")]
a[0, -2]

# By default, [] will simplify the results to the lowest possible dimensionality. You can avoid
# this, but this will be taught in a later section.

# Because matrices and arrays are implemented as vectors with special attributes, you can subset
# them using a single vector. If you do it, they will behave like a vector. Arrays in R are stored
# in column-major order:
(vals <- outer(1:5, 1:5, FUN = "paste", sep = ","))
vals[c(4, 15)] # i.e., ith row x jth column, such as 4 x 1 and 5 x 3

# You can also subset higher-dimensional data structures with an integer matrix (or, if named, 
# a character matrix).  Each row in the matrix specifies the location of one value, where each 
# column corresponds to a dimension in the array being subsetted. This means that you use a 2 
# column matrix to subset a matrix, a 3 column matrix to subset a 3d array, and so on. The result
# is a vector of values:
vals <- outer(1:5, 1:5, FUN = "paste", sep = ",")
select <- matrix(ncol = 2, byrow = TRUE, c(
 1, 1,
 3, 1,
 2, 4
))
vals[select]

## Subsetting for data frames ----------------------------------------------
# Data frames possess the characteristics of both lists and matrices: if you subset with a single
# vector, they behave like lists; if you subset with two vectors, they behave like matrices.
df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])

df[df$x == 2, ]
df[c(1, 3), ]

# There are also two ways to select columns from a data frame:
# 1. Like a list
df[c("x", "z")]
# 2. Like a matrix
df[, c("x", "z")]

# There's an important difference if you select a single column: matrix subsetting simplifies by 
# default, list subsetting does not.
str(df["x"])
str(df[, "x"])

# Subsetting operators ----------------------------------------------------
# There are two subsetting operators: [[ and $. [[ is similar to [, though it only returns a single
# value and allows you to pull pieces out a list. $ is a useful shorthand for [[ combined with 
# character subsetting.

# You need [[ when working with lists. This is because when [ is applied to a list it always 
# returns a list: it never gives you the contents.
a <- list(a = 1, b = 2)
a[[1]]
a[["a"]]

# If you do supply a vector it indexes recursively:
b <- list(a = list(b = list(c = list(d = 1))))
b[[c("a", "b", "c", "d")]]
# ... which is the same as 
b[["a"]][["b"]][["c"]][["d"]]

# Because data frames are lists of columns, you can use [[ to extract a column from dataframes.

## Simplifying vs. preserving subsetting -----------------------------------
# Simplifying subsets returns the simplest possible data structure that can represent the output.
# Preserving keeps the structure of the object, and is generally better for programming because the
# result will always be the same type.

# I am generally familiar with these behaviours and so will not go further.

## Applications ------------------------------------------------------------
### Lookup Tables (character subsetting) ------------------------------------
# Character matching provides a powerful way to make lookup tables. Say you want to convert 
# abbreviations:
x <- c("m", "f", "u", "f", "f", "m", "m")
lookup <- c(m = "Male", f = "Female", u = NA)
lookup[x]
unname(lookup[x])
# or with fewer output values...
c(m = "Known", f = "Known", u = "Unknown")[x]

# If you don't want names in the result, use unname() to remove them.

## Matching and Merging by hand --------------------------------------------
# You may have a more complicated lookup table which has multiple columns of info. Suppose we have 
# a vector of integer grades, and a table that describes their properties.
grades <- c(1, 2, 2, 3, 1)
info <- data.frame(
 grade = 3:1,
 desc = c("Excellent", "Good", "Poor"),
 fail = c(FALSE, FALSE, TRUE)
)

# Say we want to duplicate the info table so that we have a row for each value in grades. We can do
# this in two ways, either using match() and integer subsetting, or rownames() and character 
# subsetting:
grades
# Using match:
id <- match(grades, info$grade)
info[id, ]
# Using rownames:
rownames(info) <- info$grade
info[as.character(grades), ]

# If you have multiple columns to match on,  you'll need to first collapse them to a single column.

## Random samples/bootstrap -------------------------------------------------
# You can use integer indices to perform random sampling or bootstrapping of a vector or dataframe.
# sample() generates a vector of indices, then subsetting to access the values:
df <- data.frame(x = rep(1:3, each = 2), y = 6:1, z = letters[1:6]) 

# Random reorder:
df[sample(nrow(df)), ]
# Select 3 random rows:
df[sample(nrow(df), size = 3), ]
# Select 6 bootstrap replicates:
df[sample(nrow(df), size = 6, replace = TRUE), ]

## Ordering (integer subsetting) -------------------------------------------
# order() takes a vector as an input and returns an integer vector describing how the subsetted 
# vector should be ordered:
x <- c("b", "c", "a")
order(x)
x[order(x)]

# To break ties, you supply additional variables to order(), and you can change from ascending to 
# descending order using the argument decreasing = TRUE. By default, any NAs will be put at the end 
# of the vector; you can remove them with na.last = NA or put at the front with na.last = FALSE.

# For > 2 dimensions, order() and integer subsetting makes it easy to order either the rows or 
# columns of an object:

# Randomly reorder dataframe...
df_2 <- df[sample(nrow(df)), 3:1]
df_2
df[order(df_2$x), ]
df_2[, order(names(df_2))]

# Note that more concise yet less flexible functions are available for sorting vectors, such as 
# sort(), and for dataframes plyr::arrange().

## Expanding aggregated counts (integer subsetting) ------------------------
# Sometimes you get a dataframe where identical rows have been collapsed into one and a count column
# has been added. rep() and integer subsetting make ti easy to uncollapse the data by subsetting 
# with a repeated row index:
df <- data.frame(x = c(2, 4, 1), y = c(9, 11, 6), n = c(3, 5, 1))
rep(1:nrow(df), df$n)
df[rep(1:nrow(df), df$n), ]

## Removing columns from data frames (character subsetting) ----------------
# There are two ways to remove columsn from a dataframe. You can set individual columns to NULL.
df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df$z <- NULL

# Or you can subset to return only the columns you want
df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df[c("x", "y")]

# If you know the columns you dont want, use set operations to work out which columns to keep
df[setdiff(x = names(df), y = "z")]

## Selecting rows based on a condition (logical subsetting) ----------------
# Because it allows you to easily combine conditions from multiple columns, logical subsetting is 
# probably the most commonly used technique for extracting rows out of a dataframe.
mtcars[mtcars$gear == 5, ]
mtcars[mtcars$gear == 5 & mtcars$cyl == 4, ]

# Remember to use vector boolean operators & and |, not the short-circuiting scalar operators && 
# and || which are more useful inside if statements. 

# subset() is a specialised shorthand function for subsetting dataframes, and saves some typing 
# because you don't need to repeat the name of the dataframe:
subset(x = mtcars, subset = gear == 5 & cyl == 4)

# Boolean algebra vs logical sets (logical and integer subsetting) --------
# Using set operations are often more useful when:

#  - you want to find the first or last TRUE;
#  - you have very few TRUEs and very many FALSEs; a set representation may be faster and require 
#    less storage.

# which() allows you to convert a boolean algebra representation to an integer representation. 
# There's no reverse option in base R, but we can easily create one:
x <- sample(10) < 4
which(x)

unwhich <- function(x, n) {
 out <- rep_len(FALSE, n)
 out[x] <- TRUE
 out
}
unwhich(which(x), 10)

# Let's create two logical vectors and their integer equivalents and then explore the relationship 
# between boolean and set operations:
(x_1 <- 1:10 %% 2 == 0)
(x_2 <- which(x_1))
(y_1 <- 1:10 %% 5 == 0)
(y_2 <- which(y_1))

# X & Y <-> intersect(x, y)
x_1 & y_1
intersect(x_2, y_2)

# X | Y <-> union(x, y)
x_1 | y_1
union(x_2, y_2)

# X & !Y <-> setdiff(x, y)
x_1 & !y_1
setdiff(x_2, y_2)

# xor(X, Y) <-> setdiff(union(x, y), intersect(x, y))
xor(x_1, y_1)
setdiff(union(x_2, y_2), intersect(x_2, y_2))

# When first learning subsetting, a common mistake is to use x[which(y)] instead of simply x[y]. 
# Here the which() achieves nothing: it switches from logical to integer subsetting but the result
# will be exactly the same. Also beware that x[-which(y)] is *not* equivalent to x[!y]: if y is all
# FALSE, which(y) will be integer(0) and -integer(0) is still integer(0)! So, you'll get no values,
# instead of all values. In general, avoid switching from logical to integer subsetting  - unless 
# you want, for example. the first or last TRUE value.

# I do not complete the exercise for this chapter as I am relatively well versed in this type of 
# stuff.

# End file ----------------------------------------------------------------