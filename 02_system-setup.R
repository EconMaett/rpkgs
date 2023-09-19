# Chapter 02 - System setup ----

# Make sure you have at least R version 4.3.1
.rs.rVersionString()
# "4.3.1"

# Then run `install.packages(c("devtools", "rogygen2", "testthat", "knitr"))`
install.packages(c("devtools", "roxygen2", "testthat", "knitr"))

# Make sure you have a recent version of RStudio installed.


## 2.2 devtools, usethis, and you ----

# The "devtools" package is a "meta-package" encompassing and exposing
# functionality maintained in several smaller packages.

# The "devtools" package might provide a wrapper function in order to
# set user-friendly defaults, introduce helpful interactive behavior,
# or combine functionality from multiple sub-packages.

# - If you are using functions interactively to develop a package,
# you should attach devtools with `library(devtools)` and call the functions
# without qualifications.

# - If you are using such functions within the package code itself, you should not
#   depend on devtools, but instead access the functions via their primary package.
#   For example, use `sessioninfo::session_info()` instead of `devtools::session_info()`.
devtools::session_info()
sessioninfo::session_info()


### 2.2.1 Personal startup configuration ----

# We strongly recommend attaching devtools in your `.Rprofile` startup file:
usethis::edit_r_profile()

if (interactive()) {
  suppressMessages(require(devtools))
}


# Note: In general it is a bad idea to attach packages to .Rprofile, 
# but since devtools is only used for package development, its 
# functions are unlikely to appear in your reproducible analyses.


# The "usethis" package consults certain options when, for example,
# creating R packages *de novo*.

# This allows you to specify personal defaults for yourself as a package
# maintainer or for your preferred license.

# Here is an example of a code snippet that could go in your `.Rprofile`:
usethis::edit_r_profile()

options(
  "Authors@R" = utils::person(
    given = "Matthias", family = "Spichiger", middle = "Pascal", 
    email = "matthias.spichiger@bluewin.ch", 
    role = c("aut", "cre"), 
    comment = c(ORCID = "0000-0003-0368-5175")
    ), 
  License = "MIT + file LICENSE"
)


# The following code shows how to install the development versions of
# devtools and usethis.
# At times, this book may describe new features that are in the development
# versions of devtools and related packages, but that haven't been released yet.

devtools::install_github(repo = "r-lib/devtools")
devtools::install_github(repo = "r-lib/usethis")

# Alternatively, you may use:
pak::pak(pkg = "r-lib/devtools")
pak::pak(pkg = "r-lib/usethis")


## 2.3 R build toolchain ----

# To be fully capable of building R packages from source, you need
# a compiler and some command line tools.

# This is necessary when you want to build packages containing C or C++ code.

# The RStudio IDE will alert you and provide support should this be necessary.


### 2.3.1 Windows ----

# On Windows the collection of tools needed to build packages from source
# is called "Rtools".
# Note that "Rtools" is NOT an R package.
# Instead, you need to download it from CRAN.


## 2.4 Verify system prep ----
# You can request a "(package) development situation report"
# with `devtools::dev_siterep()`:
devtools::dev_sitrep()

# If this reveals that certain tools or packages are missing or out-of-date,
# you are encouraged to update them.

# Note that it reveals that you have downloaded Rtools version 4.3.

# At the time of writing, devtools exposes functionality from the packages
# - remotes
# - pkgbuild
# - plkgload
# - rcmdcheck
# - revdepcheck
# - sessioninfo
# - usethis
# - thesthat
# - roxygen2

# END