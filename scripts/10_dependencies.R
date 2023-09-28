# Chapter 10 - Dependencies: Mindset and Background ---


# You need to declare a dependency on another package by listing
# it in the `DESCRIPTION` file in the `Imports` or `Suggests` fields
# with `usethis::use_package(package, type)`.


## 10.1 When should you take a dependency? ----

# A key issue with dependencies is that they may change over time,
# which is why you will sometimes see economists publishing code
# written almost entirely in base R.

# Ofc., there are means to make code reproducible when dependencies
# are present, e.g. by using R Studio's dependency manager that lets you
# fix package versions.

# Too many dependencies also increase the time and disk space needed
# when users install your package.

# Nonetheless, a 'dependency zero' mindset seems like bad advice.


### 10.1.1 Dependencies are not equal ----

# Note that some dependencies come with R itself, such as 
# the "base", "utils", and "stats" packages.

# - Some 'recommended' packages come with R too, like the
#   "Matrix" and "survival" packages.

#   These packages are very low cost to depend on, as they are
#   already installed on the user's system and always change
#   together with new R versions.


# - The highest cost dependencies are non-CRAN repositories, since they
#   require the user to configure additional repositories before installation.


# - There are also upstream dependencies, i.e. recursive dependencies. The 
#   "rlang" package is intentionally managed as a low-level package that has
#   no upstream dependencies apart from R itself.


# - Already fulfilled dependencies. When your package depends on "dplyr",
#   you can use "tibble" without changing the dependency footprint, since
#   "dplyr" already depends on "tibble".

# - Very popular packages like "ggplot2" will likely already be installed
#   on a user's machine.


# - Time to compile: C or C++ takes time to compile which increases the burden of installing.
#   For example, "glue" takes about 5 seconds to compile, while "readr" takes about 100 seconds.

# - Binary package size: Users need to first download binary packages, which
#   is burdensome for users with slow internet connections.
#   The smallest CRAN packages are around 1 Kb in size, while machine learning libraries
#   such as "h2o" are 170 Mb, and some Bioconductor binaries are over 4 Gb.

# - System requirements: Some packages require additional system dependencies.
#   The "rjags" package requires an installation of the "JAGS" library.
#   The "rJava" package requires a Java SDK.


### 10.1.2 Prefer a holistic, balanced, and quantitative approach ----

# - base r has implementations for non-standard evaluation.
#   However, "tidyverse" packages now all depend on the "tidyselect"
#   and "rlang" packages.
#   Users benefit form improved consistency.

# The experimental "itdepends" package is a useful source of 
# concrete ideas and code for analyzing how heavy a dependency is.

# The "pak" package provides functions for dependency analysis:
pak::pkg_deps_tree(pkg = "tibble")

pak::pkg_deps_explain(pkg = "tibble", deps = "rlang")


### 10.1.3 Dependency thoughts specific to the tidyverse ----

# Your own package should NEVER depend on the "tidyverse" package
# or on the "devtools" package.

# Instead, identify the underlying packages and include those.

# We can check that the number of dependencies for "devtools" and "tidyverse"
# is exceptionally high:
n_hard_deps <- function(pkg) {
  deps <- tools::package_dependencies(packages = pkg, recursive = TRUE)
  sapply(X = deps, FUN = length)
}

n_hard_deps(pkg = c("tidyverse", "devtools"))
# tidyverse: 114
# devtools: 101

# Other packages are specifically conceived as low-level packages
# that implement features that should work and feel the same across the
# whole ecosystem. 
# These include:

# - "rlang" to support tidy evaluation and to throw errors
# - "cli" and "glue" to create a rich user interface and errors
# - "withr" to manage state responsibly.
# - "lifecycle" to manage the life cycle of functions and arguments.
n_hard_deps(pkg = c("rlang", "cli", "glue", "withr", "lifecycle"))
# rlang: 1
# cli: 1
# glue: 1
# withr: 3
# lifecycle: 5

# These are basically free dependencies and can be added to the `DESCRIPTION`
# file in one go with `usethis::use_tidy_dependencies()`.
tools::package_dependencies(packages = c("rlang", "cli", "glue", "withr", "lifecycle"))


# `R CMD check` will issue a `NOTE` if there are 20 or more "non-default"
# packages in the `Imports` field of your `DESCRIPTION` file.


### 10.1.4 Whether to Import or Suggest ----

# - `Imports`: The packages listed here *must* be present for your package to work.
#   Whenever your package is installed, those packages will be installed too.
#   `devtools::load_all()` checks that all packages in `Imports` are installed.

# - `Suggests`: These packages are not required for your package to work.
#   You may use the suggested packages for example datasets, to run tests,
#   to build vignettes etc.


## 10.2 Namespace ----

# The `::` operator can be used to specify from which package a function 
# comes from.

# Both the "here" and the "lubridate" package provide a `here()` function.
library(lubridate)
library(here)

here() # here::here()

library(here)
library(lubridate)
# Now, lubridate::here() should be the suggested function.

# The order by which you attached the libraries matters.

# To be consistent, always use `package::function()`.
# This eliminates any ambiguity.

# Consider the function `stats::sd()`
stats::sd

# `stats::sd()` uses the function `stats::var()`.

# If we overwrite the function `var()`, it will not break `stats::sd()`:
var <- function(x) -5

var(1:10) # -6

stats::var(1:10) # 9.1666

stats::sd(1:10) # 3.02765

# This is because `stats::sd()` will first look inside the "stats" package
# for an object called "var", hence it will find `stats::var()` first.

# Our custom "var" is defined in the global environment.


### 10.2.2 The `NAMESPACE` file ---

# The `NAMESPACE` file always starts with 
# `# Generated by roxygen2: do not edit by hand`

# Each subsequent line contains a **directive**:
# - `export()`: export a function (including S3 and S4 generics)
# - `S3method()`: export an S3 method
# - `importFrom()`: import an object from another namespace, including S4 generics
# - `import()`: import all objects form another package's namespace.
# - `useDynLib()`: registers routines form a DLL (used in packages with compiled code)

# Directives that rarely come up are:
# - `exportPattern()`: Exports all functions matching a pattern.
# - `exportClasses()`, `exportMethods()`, `importClassesFrom()`, `importMethodsFrom()`:
# export and import S4 classes an methods.


# The "roxygen2" package will generate the `NAMESPACE` file for you
# as long as you include the appropriate roxygen comments above
# each function definition inside of `pkg/R/*.R`.

# So far, we have only used the `#' @export` roxygen tag.
# roxygen2 will figure out which directive to use, based on whether the
# object is a function, S3 method, S4 method, or S4 class.

# roxygen2 will sort first by the directive type and then alphabetically.


## 10.3 Search path ----


### 10.3.1 Function lookup for user code ----

# The first place R looks for an object is the global environment:
ls(envir = globalenv())
# character(0)

# If R does not find the object in the global environment, it will look
# in the search path, the list of all the packages you have attached.
base::search()
# ".GlobalEnv"
# "package:graphics"
# "package:grDevices"
# "Autoloads"
# "package:methods"
# "package:stats"
# "package:utils"
# "package:base"

# This has a specific form:
# 1. The global environment ".GlobalEnv" or `base::globalenv()`
# 2. The packages that have been attached with `library()`, from most recent to least recent.
# 3. The `Autoloads` special environment used to delay bindings to save memory
#   by only loading package objects (like large data sets) when needed.
# 4. The "base" environment, the package environment of the "base" package.


### 10.3.2 Function lookup inside a package ----

# Every function inside a package is associated with two environments:
# - The package environment (appears in the `search()` path)
# - The **namespace** environment

# - The package environment is the external interface of the package.
#   It is how you find a function in a package that was installed when you
#   write `package::function()`.
#   Its parent environment is determined by the `search()` path.
#   The package environment only exposes **exported** objects.

# - The namespace environment is the internal interface of the package,
#   and it includes both exported and non-exported objects.
#   This ensures that every function finds every other function in the package.
#   From outside, access non-exported functions like `package:::function()`.

# Note that every binding in the package environment also exists in the
# namespace environment, but NOT *vice versa*.

# - The package environment controls how *users* find the function.
# - The namespace environment controls how the function finds its variables.


# Every namespace environment has the same set of ancestors:

# - Each namespace has an **imports** environment that contains bindings to
#   functions used by the package but defined in another package.
#   It is controlled by the `NAMESPACE` where directives such as
#   `importFrom()` and `imports()` populate the imports environment.

# - The **namespace** environment is the parent of the imports environment,
#   containing the same bindings as the base environment.

# - The global environment is the parent of the base namespace.


## 10.4 Attaching versus loading ----

# If a package is installed:

# - **Loading*3 will load code, data, and any DDLs; register S3 and S4 methods,
#   and run the `.onLoad()` function.
#   After loading, the package is available in memory, but since it is not in
#   the search path, you can0t access its components unless you use `::` (which will load the package).

# - **Attaching** puts the package in the `search()` path. You need to first 
#   *load* a package before you can *attach* it with `library()` or `require()`.
#   This will also run the `.onAttach()` function.


# Four functions make a package available:

loadNamespace("x") # Tries to load the package and throws an error if the package is not installed.
requireNamespace("x", quietly = TRUE) # Tries to load the package and returns `FALSE` if it is not found.
library(x) # Tries to attach the package and throws an error if it is not found
require(x, quietly = TRUE) # Tries to attach the package and returns `FALSE` if it is not found.


# The `library(x)` function is the most useful.
# NEVER use `library()` in package code below `pkg/R/` or `pkg/tests/`.

# Instead, use `requireNamespace("x", quietly = TRUE)` inside of a package if you
# want to specify different behavior depending on whether or not a certain
# package is installed.
# Note that this will also load the package.

# END
