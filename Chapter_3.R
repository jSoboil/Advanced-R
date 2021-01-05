# ===========================================================================================
# Subsetting --------------------------------------------------------------
# ===========================================================================================
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

# Subsetting for atomic vectors -------------------------------------------
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

# Subsetting for Lists ----------------------------------------------------
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

# Subsetting for data frames ----------------------------------------------
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

# ===========================================================================================
# Subsetting operators ----------------------------------------------------
# ===========================================================================================
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

# Simplifying vs. preserving subsetting -----------------------------------
# Simplifying subsets returns the simplest possible data structure that can represent the output.
# Preserving keeps the structure of the object, and is generally better for programming because the
# result will always be the same type.

# I am generally familiar with these behaviours and so will not go further.

# ===========================================================================================
# Applications ------------------------------------------------------------
# ===========================================================================================

# Lookup Tables (character subsetting) ------------------------------------
# Character matching provides a powerful way to make lookup tables. Say you want to convert 
# abbreviations:
x <- c("m", "f", "u", "f", "f", "m", "m")
lookup <- c(m = "Male", f = "Female", u = NA)
lookup[x]
unname(lookup[x])
# or with fewer output values...
c(m = "Known", f = "Known", u = "Unknown")[x]

# If you don't want names in the result, use unname() to remove them.

# Matching and Merging by hand --------------------------------------------
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

# Random samples/bootstrap -------------------------------------------------

















