# Vectorising -------------------------------------------------------------
# Vectorising is about taking a 'whole object' approach to solving problems, by
# thinking in terms of vectors - not scalars! There are two key attributes to a 
# vectorised function:

# 1) It makes many problems simpler. Instead of having to think about the 
# components of a vector, you only think about the entire vectors.
# 2) The loops in a vectorised function are written in C instead of R. Loops in
# C are *much* faster because they have much less overhead code.

# Vectorised functions that apply to many common performance bottlenecks include:

# rowSums(), colSums(), rowMeans(), and colMeans(). These vectorised matrix 
# functions will always be faster than using apply(). You can sometimes use these
# functions to build other vectorised functions.

rowAny <- function(x) rowSums(x) > 0
rowAll <- function(x) rowSums(x) == ncol(x)

# Vectorised subsetting can also lead to big improvements in speed. For example,
# when needing to replace multiple values in a single step. If x is vector, 
# matrix, or data frame then x[is.na(x)] <- 0 will replace missing values with 0
# more efficiently than for (i in length(x)) if (x[i] == 0) x[i] <- 0, for 
# example.
x <- sample(c(1:10, 11), size = 10000, replace = T)
for (i in 1:length(x)) {
 if (x[i] == 11) {
 x[i] <- 0
}
}
# versus
x[x == 11] <- 0
x

# Matrix algebra is a general example of vectorisation!!

# End file ----------------------------------------------------------------