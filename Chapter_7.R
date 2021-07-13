library(pryr)

# OO field guide ----------------------------------------------------------
# This chapter is about understanding the three different OO systems used in the R language.

# First is the concept of class. A class defines the behaviour of objects by describing their
# attributes and their relationship to other class. Class is also used when selecting methods,
# functions that behave differently depending on the class of their input. Classes are 
# usually organised in a hierarchy: if a method does not exist for a child, then the parent's
# method is used instead; i.e., the child inherits behaviour from the parent.

## Base types --------------------------------------------------------------
# Underlying every R object is a C structure (or struct) that describes how that object is
# stored in memory. The struct includes the contents of the object, the info needed for 
# memory management, and, most importantly, a *type*. This is the *base type* of an R object.
# You can determine an object's base type with typeof():
f <- function() {
 typeof(f)
}
typeof(f)
is.function(f)
# or for example...
typeof(sum)
is.primitive(sum)

# S3 ----------------------------------------------------------------------
# S3 is R's first and simplest OO system. It is only the OO system used in the base and stats
# packages, and it is the most commonly used system in the CRAN packages. 

### Recognising objects,  generic functions,  and method --------------------
# Most objects encountered in R are S3 objects. However, there is no simple way to test if
# an object is an S3 object in base R. The closest you can get is is.object(x) & !isS4(x), 
# i.e., it's an object but not S4. An easier way is to use pryr:otype():
df <- data.frame(x = 1:10, y = letters[1:10], stringsAsFactors = TRUE)
otype(df) # a dataframe is an S3 class
otype(df$x) # a numeric vector isn't
otype(df$y) # A factor is (note: you now have to specify stringsAsFactors == TRUE)

# In S3, methods belong to functions, called *generic functions*, or generics for short. S3
# methods do not belong to objects or classes. Though different from most other programming
# languages, it is still a legitimate OO style.

# To determine if a function is an S3 generic, you can inspect its source code for a call to
# useMethod(): a function that figures out the correct method to call, the process of method
# dispatch. pryr also provides ftype() which describes the object system, if any, is 
# associated with a function:
mean
pryr::ftype(mean)

# Some S3 generics don't call useMethod() because they are implemented in C. Instead, they 
# call C functions DispatchGroup or DispatchOrEval(). Functions which do method dispatch 
# using C based functions are called *internal generics* and are documented in
# "?internal generic". 

### Defining classes and creating objects -----------------------------------
# S3 is an informal and ad hoc system. It has no formal definition of a class. To make an 
# object an instance of a class, you just take an existing base object and set the class 
# attribute. You can do that during creation with structure(), or after the fact by setting
# class <- ().
# For example, create and assign class in one step:
foo <- structure(list(), class = "foo")
# or create and then set class...
foo <- list()
class(foo) <- "foo"
foo

# You can determine the class of any object using class(x), and see if an object inherits 
# from a specific class using inherits(x, "classname)
class(foo)
inherits(foo, "foo")

# The class of an object can be an S3 vector, which describes behaviour from most to least
# specific. For example, the class of the glm() object is c("glm", "lm") indicating that
# generalised linear models inherit behaviour from linear models. Class names are usually
# lower case, and you should avoid .. Otherwise, opinion is mixed whether to use underscores
# (my_class) or CamelCase(MyClass) for multi-word class names.

# Most S3 classes provide a construction function:
foo <- function(x) {
 if (!is.numeric(x)) {
  stop("X must be a numeric")
  structure(list(x), class == "foo")
 }
}

# You should use it if its available (like factor() and data.frame()). This ensures that 
# you're creating the class with the correct components. Constructor functions usually have
# the same name as the class.

# Apart from the developer supplied constructor functions, S3 has no checks for correctness.
# This means that you can change the class of existing objects:
# Create a linear model:
l_mod <- lm(log(mpg) ~ log(disp), data = mtcars)
class(l_mod)
l_mod
# Now turn it into a dataframe:
class(l_mod) <- "data.frame"
l_mod
# But the data is still there...
l_mod$coefficients
# Although you can change the class of these types of object, you shouldn't. R does not 
# protect you from yourself!

### Creating new methods and generics ---------------------------------------
# To add a new generic, create a function that calls useMethod(). useMethod() takes two
# arguments: the name of the generic function, and the argument to use for method dispatch.
# If you omit on the second argument it will dispatch on the first argument of the function.
# There's no need to pass any of the arguments of the generic useMethod() and you shouldn't
# do so. useMethod() uses built in scripting to find them out itself.
f <- function(x) {
 UseMethod("f")
}
# A generic isn't useful without some methods. To add a method, you just create a regular
# function with the correct (generic.class) name:
f.a <- function(x) {
 "Class a"
}
a <- structure(list(), class = "a")
f(a)

# Adding a method to an existing generic works in the same way:
mean.a <- function(x) {
 "a"
}
mean(a)
# As is shown above, this means that there's no check to make sure that the method returns
# the class compatible with the generic. It is therefore up to you to ensure that your 
# method does not violate the expectations of existing/base code

## Method dispatch ---------------------------------------------------------
# Avoid multiple inheritance and dispatch!!

# Reference classes -------------------------------------------------------
# Reference classes are the newest OO system in R. They are fundamentally different to S3 
# and S4 classes because:

# RC methods belong to objects, not functions  
# RC objects are mutable: the usual R copy-on-modify semantics do not apply

# These properties make RC objects behave more like objects do in most other programming
# languages, e.g. Python, Ruby, Java, and C#. RCs are implemented in R code: they are a
# special S4 class that wraps around an environment.

## Defining classes and creating objects -----------------------------------
# RC objects are best used for describing stateful objects, objects that change over time.
# Creating an RC object is similar to creating an S4 object, but with setRefClass() instead
# of setClass(). The first and only required argument is an alphanumeric name. While you
# can use new() to create new RC objects, it's a good style to use the object returned by
# setRefClass() to generate new objects. For example:
account <- setRefClass("account")
account$new()

# setRefClass() also accepts a list of name-class pairs that define class fields (equivalent
# to S4 slots). Additional named arguments passed to new() will set initial values of the 
# fields. You can get and set field values with $:
account <- setRefClass("account", 
                       fields = list(balance = "numeric"))
a <- account$new(balance = 100)
a$balance
a$balance <- 200
a$balance

# Instead of supplying a class name for the field, you can provide a single argument 
# function which will act as an accessor method. This enables you to add custom behaviour 
# when getting or setting a field. 

# Note that RC objects are mutable, i.e., they have reference semantics, and are not 
# copyied-on-modify:
b <- a
b$balance
a$balance <- 0
b$balance

# For this reason, RC objects come with a copy() method that allow you to make a copy of 
# the object:
c <- a$copy()
c$balance
a$balance <- 100
c$balance

# An object is not very useful without some behaviour defined by *methods*. RC methods are
# associated with a class and can modify its fields in place. As shown below, note that you
# access the value of fields with their name, and modify them with <<-:
account <- setRefClass("account",
 fields = list(balance = "numeric"),
 methods = list(
  withdraw = function(x) {
   balance <<- balance - x
  },
  deposit = function(x) {
   balance <<- balance + x
  }
 )
)
# You can then call an RC method the same way as you access a field:
a <- account$new(balance = 100)
a$deposit(100)
a$balance

# The final important argument to setRefClass() is *contains*. This is the name of the 
# parent RC to inherit behaviour from. The following example creates a new type of bank
# account that returns an error preventing the balance from going below 0:
no_overdraft <- setRefClass("no_overdraft", 
                            contains = "account", 
                            methods = list(
                             withdraw = function(x){
                              if (balance < x) {
                               stop("Not enough money")
                              } else {
                               balance <<- balance - x
                               }
                              }
                             )
                            )
my_account <- no_overdraft$new(balance = 100)
my_account$deposit(50)
my_account$balance
my_account$withdraw(200)

# All RCs eventually inherit from envRefClass. It provides useful methods like copy(), 
# callSuper() (to call parent field), field() (to get the value of a field given its name),
# export() (equivalent to as()), and show() (overidden to control printing).

## Recognising objects and methods -----------------------------------------
# You can recognise RC objects and methods because they are S4 objects, e.g. isS4() that
# inherit from "refClass" (is(x, "refClass")). pryr::otype() will return "RC". RC methods
# are also S4 objects, with class refMethodDef.

## Method dispatch ---------------------------------------------------------
# Method dispatch is simple in RC because methods are associated with classes, not 
# functions. When you call x$f(), R will look for a method f in the class of x, then in it's
# parent, then it's parent's parent, and so on. As noted above, from within a method you 
# can call the parent method directly with callSuper()

# Picking a system --------------------------------------------------------
# Simple objects = S3
# Interrelated, complex objects = S4
# If mutable states are required = RCs

# End file ----------------------------------------------------------------