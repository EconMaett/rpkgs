# Chapter 08 - Other components

# Besides functions and data, there are other package components
# that may be required (like `DESCRIPTION`), or recommended (like tests
# and documentation).

# This chapter quickly introduces some package parts that are not always needed.


# 8.1 Other directories ----

# Some top-level directories that may be included in an R source package are:

# - `pkg/src/`: source and header files for C and C++ code.
#   The tidyverse uses the "cpp11" package to connect C++ to R.
#   Most other packages use "Rcpp".

# - `pkg/inst/`: for arbitrary additional files, like `CITATION`,
#   or R Markdown templates generated with `usethis::use_rmarkdown_template()`,
#   or RStudio add-ins.

# - `pkg/demo/`: package demos are a legacy feature that has been replaced
#   by vignettes and `README.Rmd` files.

# - `pkg/exec/`: For executable scripts. Files in this directory are automatically
#   flagged as executable. 

# - `pkg/po/`: translation for messages. Use the "potools" package for this purpose.


## 8.2 Installed files ----

# Once a package is installed, the content of the `pkg/inst/` directory
# is copied to the top-level directory.

# `pkg/inst/` is the opposite of `.Rbuildignore`.

# Do not create a sub-directory inside of `pkg/inst/` that will collide
# with a directory in the top-level after the package is installed.
# This means avoiding directories with a special significance such as:
# `data`, `help`, `html`, `libs`, `man`, `Meta`, `R`, `src`, `tests`, `tools`, `vignettes`

# Common files inside of `pkg/inst/` are:
# - `inst/CITATION`: How to cite this package.
# -`inst/extdata`: Additional external data for examples and vignettes.


### 8.2.1 Package citation ----

# The `pkg/inst/CITATION` file lets you call the appropriate citation with
# `utils::citation()`
citation() # cites R
citation(package = "tidyverse")
# Call `usethis::use_citation()` to initiate the `pkg/inst/CITATION` file and
# read up on 
?bibentry


## 8.3 Configuration tools ----

# If the package contains a configuration script such as
# - `configure` on Unix
# - `configure.win` on Windows
# it is executed as the first step by `R CMD INSTALL`.
# This is the case for packages that have a `pkg/src/` sub-directory
# containing C or C++ code and the `configure` / `configure.win`
# script is used to compile this code.

# If this script needs auxiliary files, they are located in the 
# `pkg/tools/` directory.

# Other packages use the `pkg/tools/` directory for periodic maintenance tasks
# for which it is helpful to record instructions, like when the package
# embeds external resources like code or data:
# - Source code and header for embedded third-party C/C++ libraries
# - Web toolkits
# - R code that is inlined as opposed to imported
# - web API specifications
# - Color palettes, styles, and themes

# END