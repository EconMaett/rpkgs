# 04 - Fundamental development workflows ----

## 4.1 Create a package ----

### 4.1.1 Survey the existing landscape ----

# There are active R communities that successfully self-organised to promote
# greater consistency across packages with different maintainers.

# - The "hardhat" package provides scaffolding for creating a modeling package
#   that plays well with the "tidymodels" ecosystem.

# - The "r-spatial.org" community promotes consistency across packages for spatial
#   data analysis.


### 4.1.2 Name your package ----

#### 4.1.2.1 Formal requirements ----

# There are three formal requirements for the name of your package:

# 1. The name can only consist of letters, numbers, and periods, i.e., `.`.

# 2. It must start with a LETTER.

# 3. It cannot end with a period.

# This means you can't use hyphens (`-`) or underscores (`_`) in your package
# name.

# We recommend against using periods in package names because they are associated
# with file extensions and S3 methods.


#### 4.1.2.2 Things to consider ----

# - Pick a name that makes it easy to find the package on Google.

# - Don't pick a name that is already in use on CRAN, Bioconductor or GitHub.

# - Avoid mixing upper- and lowercase letters.

# - Use names that are pronounceable.

# - Find a word that evokes the problem and modify it so that it is unique.

# For example; "luridate" makes working with dates and times easier, "rvest" harvests web content,
# "r2d3" helps working with 3D visualizations, "forcats" is an anagram of factors.

# - Use abbreviations.

# For example, "Rcpp" stands for R + C++, "brms" stands for Bayesian Regression Models
# using Stan, "callr" calls R form R.


#### 4.1.2.3 Use the "available" package ----

# The function `available::available()` helps you evaluate a potential package name:
available::available(name = "doofus")

# - The availability was checked on CRAN, Bioconductor, and GitHub.
# - Abbreviations, Wikipedia, and Wiktionary were checked.
# - Attempts to report whether the name has positive or negative sentiment.

# `pak::pkg_name_check()` works similarly:
pak::pkg_name_check(name = "doofus")
# It does not open the web pages in the browser but instead reports them 
# in the console output.


### 4.1.3 Package creation ----

# Once you have come up with an available name, you create the new package
# with `usethis::create_package()` or you click on "File" -> "New Project"
# -> "New Directory" -> "R Package" in RStudio.
# This ultimately calls `usethis::create_package()` as well.

# This produces the smalles possible *working* package:

# 1. An `R/` directory

# 2. A basic `DESCRIPTION` file

# 3. A basic `NAMESPACE` file

# It may include an RStudio project file `pkgname.Rproj` and a `.Rbuildignore`
# and `.gitignore` file.

# WARNING: Do NOT use `utils::package.skeleton()` to create a package.
# This function creates a package that immediately throws errors with 
# `R CMD build`.
# It anticipates a different development process.
# Use `usethis::create_package()` instead.


### 4.1.4 Where should you `usethis::create_package()`? ----

# You need to decide where your package lives in its **source** form
# when calling `usethis::create_package(path = "path/to/package/pkgname")`.

# Installed packages live in a library.

# Many developers let their packages live inside directories called
# `~/rrr/`, `~/documents/tidyverse`, `~r/packages`, or `~/pkg/`.

# Some people use multiple directories.


## 4.2 RStudio Projects ----

# "devtools" works hand-in-hand with RStudio.


### 4.2.1 Benefits of RStudio Projects ----

# - Projects are "launch-able", since they fire up a fresh instance of RStudio
#   in a Project, with the file browser and working directory set exactly to
#   where you need it to work.

# - Each Project is isolated; code in one project does not affect any other project.

# - You get control navigation tools like `F2` to jump to a function definition
#   and `Ctrl + .` to look up functions or files by name.

# - You get keyboard shortcuts and a clickable interface.


# Press Alt + Shift + K to see the keyboard shortcuts help page.

# Press Ctrl + Shift + P to see the RStudio Command Palette.


### 4.2.2 How to get an RStudio project ----

# - In RStudio, do "File" -> "New Project" -> "Existing Directory"
# - Call `usethis::create_package()` with he path to the pre-existing R source package.
# - Call `usethis::use_rstudio()` with the active usethis project set to an existing R package.


### 4.2.3 What makes an RStudio Project? ----

# A directory that is an RStudio Project will contain an `.Rproj` file.

# This is a text file that you don't need to modify by hand but instead,
# use "Tools" -> "Project Options" or "Project Options" in the "Projects" menu
# in the top-right corner of RStudio.


### 4.2.4 How to launch an RStudio Project ----

# Double-click on the `.Rproj` file in Windows Explorer ot launch the 
# project in RStudio.

# You can also open a project from within RStudio via "File" -> "Open Project
# (in New Session)".

# Developers working in macOS use productivity or launcher apps such as
# "Alfred".


## 4.2.5 RStudio Project vs. active "usethis" project ----

# Most "usethis" functions don't take a path: they operate on the files
# in the "active usethis project".

# The "usethis" package assumes that these coincide:

# - The current RStudio Project
# - The active usethis project
# - The current working directory for the R process

# Call `usethis::proj_sitrep()` to get a situation report:
usethis::proj_sitrep()


## 4.3 Working directory and file path discipline ----

# We *strongly recommend* that you keep the top-level of your source package
# as the working directory of your R process.

# Path helpers like `testthat::test_path()`, `fs::path_package()`, and the
# "rprojroot" package are useful for building resilient paths.


## 4.4 Test drive with `devtools::load_all()` ----
devtools::load_all()

# With devtools attached and the working directory set to the top-level
# of your source package, `load_all()` allows you to run everything in your package.


### 4.4.1 Benefits of `devtools::load_all()` ----

# `devtools::load_all()` allows you to iterate quickly, encouraging exploration
# and incremental progress.

# You get to develop interactively under a namespace regime that accurately
# mimics how things are when someone else uses your installed package.

# - You can call your own internal functions directly, using `:::`.
# - You do not have to define functions in the global workspace.
# - You can call functions from other packages that have been imported into your
#   `NAMESPACE` without having to attach these dependencies via `library()`.


### 4.4.2 Other ways to call `devtools::load_all()` ----

# - Use the keyboard shortcut Ctrl + Shift + L
# - In the "Build" pane in RStudio, go to "More..."
# - In the "Build" tab in RStudio, go to "Load all".

# `devtools::load_all()` is a wrapper around `pkgload::load_all()`.


## 4.5 `devtools::check()` and `R CMD check` ----

# Base R provides command line tools like `R CMD check`, the official
# method for checking that an R package is valid.

# It is essential to pass `R CMD check` if you plan to submit your package to
# CRAN.

# `devtools::check()` calls `R CMD check` from the R console.

# You can use the shortcut Ctrl + Shift + E instead.


### 4.5.1 Workflow ----

# When you call `devtools::check()` or use Ctrl + Shift + E:
# - The documentation is updated via `devtools::document()`
# - The package gets bundled.
# - The `NOT_CRAN` environment variable is set to `"true"`.
#   This allows you to selectively skip tests on CRAN.
?testthat::skip_on_cran

# `R CMD check` returns three types of messages:

# - `ERROR`s are severe problems that you should fix regardless of whether or not
#   you plan to submit to CRNA.

# - `WARNING`s are problems that must be fixed before submitting to CRAN.

# - `NOTE`s are mild problems or observations. If it is not possible to eliminate
#   a `NOTE` you need to describe why it is OK in your submission comments.


### 4.5.2 Background on `R CMD check` ----

# In the terminal, you can run `R CMD check`.
# You can see the documentation via `R CMD check --help`.

# END