# Chapter 01 - The whole game ----

# The first chapter runs through the development of a small toy package.
# It suggests a workflow and introduces the conveniences of the "devtools"
# package and the RStudio IDE.


## 1.1. Load "devtools" and friends ----

# the "devtools" package, which also loads the usethis package, will
# ensure that a new clean project is opened for your new package.

library(devtools)
# Load package: usethis

# Check the version of the "devtools" package.
packageVersion("devtools")
# 2.4.6


## 1.2 Toy package: regexcite ----

# To walk you through the process, we use functions from the "devtools"
# package to build a small toy package from scratch, with features commonly
# seen in released packages:
# - Functions to address a specific need, in this case helpers for regular expressions
# - Version control and an open development process
#   - This is optional in your work but recommended.
# - Access to established workflows for installation, getting help, and quality checks.
#   - Documentation for individual functions via "roxygen2"
#   - Unit testing with "testthat"
#   - Documentation for the whole package via an executable "README.Rmd".

# We call the package "regexcite" and it contains some functions that help you
# working with regular expressions.

# These functions are very simple and meant as an example only.

# If you want acutal helpers for regular expressions, use the following packages:
# - "stringr" (which uses "stringi")
# - "stringi"
# - "rex"
# - "rematch2"


## 1.3 Preview the finished product ----

# The "regexcite" package is tracked during its development with the "Git"
# version control system.

# By inspecting the commit history and the diffs, you can see what
# changes at each step of the process laid out below.


## 1.4 `create_package()` ----

# Call `create_package()` to initialize a new package in a directory on your
# computer.
# The function will create that directory if it does not exist et.

# The new directory should not be nested inside other RStudio Projects,
# R packages, or Git repos.

# Nor should it be in your R package library, which holds packages that
# have already been built and installed.

usethis::create_package(path = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/regexcite")

# In the new instance of RStudio, there is now a "Build" tab in the same pane
# as "Environment" and "History".

# You will need to call `library(devtools)` again in the new instance
# of RStudio because `usethis::create_package()` has opened a fresh R session.


# In the "Files" pane of the new instance, you see the following
# new files in the directory of your new R package:
# - file .Rbuildignore
# - file .gitignore
# - file DESCRIPTION
# - file NAMESPACE
# - directory R/
# - file regexcite.Rproj

# In the "Files" pane, go to "More (gear symbol)" -> "Show Hidden Files"
# to toggle the visibility of hidden files ("dotfiles").

# Some dotfiles are always visible, but it is worthwhile activating this feature.

# - `.Rbuildignore` lists files that we need to have around but that should
#   not be included when you build the R package from source.
#   If you are not in RStudio, `usethis::create_package()` may not create this file
#   (nor `.gitignore`) at first, since there is no RStudio-related machinery that needs to be ignored.

# - `.Rproj.user`, if you have it, is a directory used internally by RStudio.

# - `.gitignore` anticipates Git usage and tells Git to ignore some standard,
#   behind-the-scenes files created by R and RStudio.

# - `DESCRIPTION` provides metadata about your package.

# - `NAMESPACE` declares the functions your package exports for external
#   use and the external functions your package imports from other packages.

# - The `R/` directory is the "business end" of your package. It will contain
#   the `.R` files with function definitions.

# - `regexcite.Rproj` is the file that makes the new directory and RStudio project.


## 1.5 `use_git()` ----

# Make the new RStudio project also a Git repository by calling
# `usethis::use_git()`.

# After you committed the files and restarted your R session,
# A new `.git` directory was created.


## 1.6 Write the first function ----

# The base R `strsplit()` function splits a single string into many parts:
(x <- "alfa,bravo,charlie,delta")
base::strsplit(x, split = ",")

# Take a close look at the return value:
str(base::strsplit(x, split = ","))

# The return value is a list with one element;
# a character vector of size 4.

# It may be more convenient for the output to be a simple
# character vector.

# There are several ways to receive an output in the desired form:
unlist(strsplit(x, split = ","))

strsplit(x, split = ",")[[1]]

# The second solution is safer and we want to use it in a
# custom-function caled `strsplit1()`:
strsplit1 <- function(x, split) {
  strsplit(x, split = split)[[1]]
}


## 1.7 `use_r()` ----

# We should save the new `strsplit1()` function in a `.R` file
# in the `R/` sub-directory of your new package.

# We will save the `strsplit1()` function in the  file `R/strsplit1.R`.

# The helper `usethis::use_r()` creates and opens a script in the
# `R/` sub-directory.

# Call `usethis::use_r(name = "strsplit1")` in the new RStudio instance.

# Put only the function definition into the new file.


## 1.8 `load_all()` ----

# In a regular R script, you would call `source("R/strsplit1.R)`,
# but for package development, you want to call `devtools::load_all()`.

# Note that while the new function is available in the console,
# it does not exist in the global environment.
exists("strsplit1", where = globalenv(), inherits = FALSE)
# Shoudl return FALSE in the new RStudio instance.

# `devtools::load_all()` simulates the process of building, installing,
# and attaching the "regexcite" package.

# `devtools::load_all()` simulates what would happen if we called
# `library(regexcite)`.

# You can use the shortcut Ctrl + Shift + L to call `devtools::load_all()`.


### 1.8.1 **Commit** `strsplit1()` ----

# Commit the new file `R/strsplit1.R`


## 1.9 `check()` ----

# We have informal, empirical evidence that `strsplit1()` works.

# Even after such a small addition, it is a good idea to establish
# a check for the new function.

# `R CMD check`, executed in the shell, is the gold standard for
# checking that an R package is in full working order.

# `devtools::check()` is a convenient way to run `R CMD check` without
# leaving your R session.


# *It is essential to actually read the output of the check!*
# There was one note saying that we have a non-standard license specification
# and that we should use `use_mit_license()` or `use_gpl3_license()`.

# Use the shortcut Ctrl + Shift + E to run `devtools::check()`.
# This will run in the "Build" Tab and not in the Console.


## 1.10 Edit `DESCRIPTION` ----

# The `DESCRIPTION` file provides metadata about your package.
# It is currently populated with boilerplate content that needs to
# be replaced.

# To add your own metadata, make these edits:
# - Make yourself the author. If you don't have an ORCID, omit the
#   `comment = ...` portion.
# - Write some descriptive text in the `Title` and `Description` fields.

# Note: My ORCID is: https://orcid.org/0000-0003-0368-5175

# In RStudio, use Ctrl + `.` and start typing
# "DESCRIPTION" to activate a helper that makes it easy
# to open a file for editing.

# In addition to a file name, your hint can be a function name.


### 1.11 `use_mit_license()` ----

# Replace the placeholder in the `License` field of the `DESCRIPTION` field
# by running `usethis::use_mit_license()` in the new instance of RStudio.

# This configures the `License` field correctly for the MIT license,
# which promises to name the copyright holders and year in a `LICENSE` file.

# Open the newly created `LICENSE` file.

# `usethis::use-mit_license()` also puts a copy of the full license
# in `LICENSE.md` and adds this file to `.Rbuildignore`.

# It is considered best practice to include a full license
# in your package's source on GitHub, but CRAN disallows the inclusion of this file
# in aa package tarball.


## 1.2 `document()` ----

# We write a specially formatted comment right above `strsplit1()`, in
# its source file, and then let a package called "roxygen2" handle the
# createion of `man/strsplit1.Rd`.

# If you use RStudio, open `R/strsplit1.R` in the source editor and put
# the cursor somewhere in the `strsplit1()` function definition.

# Then click "Code" -> "Insert roxygen skeleton".

# A special roxygen comment, `#'` appears.

# Then write an appropriate documentation.

# Next you need to trigger the conversion of the new roxygen comment into
# `man/strsplit1.Rd` by calling `devtools::document()` in your new RStudio instance.

# You can also use the shortcut Ctrl + Shift + D to run `devtools::document()`
# in the "Build" pane of RStudio.

# You should now be able to preview the new help file by calling
# `?strsplit1

# You will see the message "Rendering development documentation for 'strsplit1'",
# as a reminder that you are previewing draft documentation.

# This means the documentation is present in your package's source, but
# it is not yet present in an installed package,
# since we have not yet installed the package "regexcite".

# Only once the package has been formally bult and installed will all
# help files exhibit proper links and a package index.


### 1.12.1 `NAMESPACE` changes ----

# The call to `devtools::document()` updates the `NAMESPACE` file,
# based on `@export` tags found in the roxygen comments.

# Open the `NAMESPACE` file to see `export(strsplit1)`.

# The export directive in `NAMESPACE` is what makes `strsplit1()` available
# to the user after attaching "regexcite" via `library(regexcite)`.


## 1.13 `check()` again ----

# Call `devtools::check()` again or use Ctrl + Shift + E.
# Since we have included `usethis::use_mit_license()`, we get 0 errors,
# 0 warnings, and 0 notes.


## 1.14 `install()` ----

# Now that we have a minimum viable product, we can install the "regexcite"
# package into your library with `devtools::install()`.

# You can also use the shortcut Ctrl + Shift + B.

# After the installation is complete, we can attach and use the
# "regexcite" package like any other package.

# You should now restart your R session and ensure you have
# a clean workspace.

# Then you may call `library(regexcite)` and check if you can use the
# function `regexcite::strsplit1("alfa,bravo,charlie,delta", split = ",")`
# in your new instance of RStudio.


## 1.15 `use_testthat()` ----

# We should express our concrete expectations about a correct result
# from `strsplit1()` in a unit test.

# We declare our intent to write unit tests and to use the "testthat"
# package with `usethis::use_testthat()`.

# This initializes the unit testing machine for our package and adds
# `Suggests: testthat` to `DESCRIPTION`, creates the directory
# `tests/testthat/`, and adds the script `tests/testthat.R`.

# The helper `usethis::use_test()` opens and creates test files.

# You can provide the file's base name or the relevant source file in RStudio.

# Call `usethis::use_test(name = "strsplit1")` to create the file
# `tests/testthat/test-strsplit1.R` and opens it.

# Delete the content of this file and replace it with the appropriate
# unit test.

# Calling the command
test_that(desc = "strsplit1() splits a string", code = {
  expect_equal(object = strsplit1("a,b,c", split = ","), expected = c("a", "b", "c"))
})
# Should return "Test passed" (an perhaps a rainbow).

# Going forward, your tests will be run *en masse* via `devtools::test()`
# or Ctrl + Shift + T.

# Your tests are also run whenever you `devtools::check()` your package
# or use Ctrl + Shift + E.

# In this way, you basically augment the standard checks with some
# checks of your own, that are specific to your package.

# You may use the "covr" package to track what proportion of your
# package's source code is exercises by the tests.


## 1.15 `use_package()` ----

# You will inevitably want to use a function from another package in your
# own package.

# You need package-specific methods to declare the other packages needed,
# i.e. your dependencies.

# If you plan to submit a package to CRAN, this even applies to functions
# in packages that are always available such as `stats::median()`,
# `utils::head()`.

# A common dilemma when using R's regular expression functions is the
# uncertainty of requesting `perl = TRUE` or `perl = FALSE`.

# There are other arguments that alter how patterns are matched,
# such as `fixed`, `ignore.case`, and `invert`.

# The "stringr" package "provides a cohesive set of functions designed to
# make workign with strings as easy as possible".

# It uses ICU regular expressions and a single interface in every function
# for controlling matching behaviors such as case sensitivity.

# Let's imagine you decide you would rather build
# "regexcite" based on "stringr" and "stringi" than base R's regular
# expression functions.

# Then you have to declare your general intent to use some functions
# from the "stringr" namespace with `usethis::use_package(package = "stringr")`.


# This adds the "stringr" package to the `Imports` field of `DESCRIPTION`.

# Let us revisit `strsplit1()` to amek it more like a "stringr" function.
str_split_one <- function(string, pattern, n = Inf) {
  stopifnot(is.character(string), length(string) <= 1)
  if (length(string) == 1) {
    stringr::str_split(string = string, pattern = pattern, n = n)
  } else {
    character()
  }
}

# Notice that we:
# - Rename the function to `str_split_one()` to signal that it is a wrapper around
#   `stringr::str_split()`.

# - Adopt the argument names from `stringr::str_split()` `string` and `pattern` (and `n`) instead
#   of `x` and `split`.

# - Introduce a bit of argument checking and edge case handling.

# - We use the `package::function()` when calling `stringr::str_split()`.


# Next, we should call `usethis::rename_files(old = "strsplit1", new = "str_split_one")`
# This also renames the associated test files.

# Note that you still have to change the roxygen2 description
# and the testthat test-files!

# Finally, it is time to call `devtools::document()` again.
# You will get a warning "Objects listed as exports, but not
# 3 present in namespace: strsplit1".

# This always happens when you remove something from the namespace.

# Restart R and call `devtools::load_all()` and check if you can use
# the function `str_split_one()`.


## 1.17 `use_github()` ----

# Use the command `usethis::use_github()` to connect your new package
# to your GitHub account.


## 1.18 `use_readme_rmd()` ----

# Call `usethis::use_readme_rmd()` to create a `README.md` file
# on GitHub.

# It is the package's home page and welcome mat until you give it a
# real website or submit it to CRAN.

# In addition ot creating `README.Rmd`, this adds some lines to `.Rbuildignore`,
# and creates a Git pre-commit hook to help you keep `README.Rmd` and
# `README.md` in sync.

# `README.Rmd` already has sections that prompt to you.
# - Describe the purpose of the package.
# - Provide installation instructions. If a GitHub remote is detected when you call
#   `usethis::use_readme_rmd()`, this section is pre-filled with instructions on
#   how to install from GitHub.
# - Show a bit of usage.

# Populate this skeleton by copying from `DESCRIPTION` and from your unit tests.

# After these changes, call `devtools::check()`, and if you get zero errors, warnings,
# and notes, call `devtools::install()`.

# Make sure to commit your changes!

# END
