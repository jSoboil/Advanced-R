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











