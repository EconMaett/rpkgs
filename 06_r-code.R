# Chapter 06 - R code ----

# All R code inside a package goes in the `pkg/R/` directory.

# Organizing functions into files, maintaining a consistent style,
# and recognizing the stricter requirements for functions in a package
# is the theme of this chapter.

# Repeatedly use the three functions `devtools::load_all()`,
# `devtools::test()` and `devtools::check()` after restarting your R session.


## 6. 1 Organize functions into files ----

# The Tidyverse Style Guide offers general advice about file names and
# advice to files inside of a package.


# A file name should be meaningful and convey which function(s) is/are defined
# within the file.

# It is bad practice to put all functions into one file or to put each function
# into its own separate file.

# The exception to this rule is if a function is large or has lots of documentation.
# In that case, give this function its own file, named after the function.

# In the wild you'll often see `pkg/R/utils.R`, a file that stores small
# helper functions.

# If it is hard to predict in which file a function lives, this means it's high
# time to give each function its separate file.

# - In RStudio, you can press Ctrl + . to open the "Got to File/Function" tool.

# - When your cursor rests on a function name or with a function name
#   selected, press F2.
#   This works for functions defined in your package or in another package.

# - Press Ctrl + F9 to return to where you were before.
library(tidyverse)

purrr::map()
purrr::map


## 6.2 Fast feedback via `devtools::load_all()` ----

# Iteratively restart your R session and call `devtools::load_all()`
# during package development.


## 6.4 Code style ----

# Follow the tidyverse style guide (https:://style.tidyverse.org)
# and use the "styler" package (https://styler.r-lib.org) to enforce
# the tidyverse style guide by default.

# There are multiple ways to apply the "styler" package:
# - `styler::style_pkg()` restylers an entire R package.
# - `styler::style_dir()` restyles all files in a directory.
# - `usethis::use_tidy_style()` is a wrapper that applies one of the above functions
#   depending on whether the current project is an R project or not.
usethis::use_tidy_style()

# - `styler::style_file()` restyles a single file.
# - `styler::style_text()` restyles a character vector.

# When styler is installed, the RStudio "Addins" menu will additionally offer:
# - the active selection
# - the active file
# - the active package

# If you do not use version control such as Git or SVN, applying
# `styler::style_pkg()` is very dangerous.

# The tidyverse packages use a GitHub Action that restyles a package when triggered
# by a special `/style` commend on a pull request.
# This allows maintainers to focus on reviewing the substance of the pull request,
# without having to care about whitespace or indentation.


## 6.3 Understand when code is executed ----

# When you write R scripts, R code is run when you execute it, 
# and the `source()` command will load a bunch of functions and data
# into your global environment.

# In a package, code is run when the package is being built.
# Package code should mostly create functions.

# Consider the assignment `x <- Sys.time()`.
# In a script, `x` returns the time the script was `source()`d.
# In the top-level of a package, `x` returns when the binary was built.

# Remember: Any R code outside of a function is suspicious and should be reviewed.


### 6.4.1 Example: A path returned by `system.file()` ----

# The "shinyboostrap2" package used to contain the following code in `R/`:
dataTableDependency <- list(
  htmlDependency(
    "datatables", "1.10.2",
    c(file = system.file("www/datatables", package = "shinybootstrap2")),
    script = "js/jquery.dataTables.min.js"
  ),
  htmlDependency(
    "datatables-bootstrap", "1.10.2",
    c(file = system.file("www/datatables", package = "shinybootstrap2")),
    stylesheet = c("css/dataTables.bootstrap.css", "css/dataTables.extra.css"),
    script = "js/dataTables.bootstrap.js"
  )
)

# `dataTableDependency` was a `list()` object defined in top-level package code
# and its value was constructed form paths obtained with `system.file()`.

# This works fine when the package is built and tested on the same machine.

# If the package is built on one machine and used on another, as is the case
# with CRAN binaries, this fails.
# The dependency points to the wrong directory on the wrong host.

# One has to make sure that `system.file()` is called from a function,
# at run time.


### 6.4.2 Example: Available colors ----

# The "crayon" package contains the function `crayon::show_ansi_colors()`
# to display an ANSI color table on your screen.

# It used to look like this:
library(crayon)

show_ansi_colors <- function(colors = num_colors()) {
  if (colors < 8) {
    cat("Colors are not supported")
  } else if (colors < 256) {
    cat(ansi_colors_8, sep = "")
    invisible(ansi_colors_8)
  } else {
    cat(ansi_colors_256, sep = "")
    invisible(ansi_colors_256)
  }
}

ansi_colors_8 # code to generate a vector covering basic terminal colors
  
ansi_colors_256 # code to generate a vector covering 256 colors

# Where `ansi_colors_8` and `ansi_colors_256` were character vectors exploring
# certain sets of colors, styled via ANSI escapes.

# But those objects were formed and cached when the binary package was built.

# Since that often happens on a headless server, this might happen
# when terminal colors might not be available.

# Users of the installed package could still call
crayon::num_colors() # 256
# but they could not print the colors in the console output.
crayon::show_ansi_colors() 
# The solution was to compute the display objects with a function at run time:
show_ansi_colors <- function(colors = num_colors()) {
  if (colors < 8) {
    cat("Colors are not supported")
  } else if (colors < 256) {
    cat(ansi_colors_8(), sep = "")
    invisible(ansi_colors_8())
  } else {
    cat(ansi_colors_256(), sep = "")
    invisible(ansi_colors_256())
  }
}

ansi_colors_8 <- function() {
  # code to generate a vector covering basic terminal colors
}

ansi_colors_256 <- function() {
  # code to generate a vector covering 256 colors
}

# Exactly the same code is used, the only difference is that it was pushed
# inside the body of a function.


### 6.4.3 Example: Aliasing a function ----

# Imagine you want the function `foo()` in your package to be an alias
# for the function `blah` form another package called `pkgB`.

# You might be tempted to write
# `foo <- pkgB::blah`

# But this will cause `foo()` to reflect the definition of `pkgB::blah()`
# at the version present on the machine wehre the bianry package was built,
# often CRAN, at that moment in time.

# If a bug is discovered in `pkgB::blah()` and fiexed, your own package
# will still use the older version, until the package is rebuilt by CRAN
# and your users upgrade your package.

# The solution is to write:
# `foo <- function(...) pkgB::blah(...)`

# Now, when the user calls `foo()`, he calls `pkgB::blah()` and the new
# version of `pkgb::blah()` is installed on his or her machine.


## 6.5 Respect the R landscape ----

# You have changed the R landscape if you have loaded a package with
# `library()`, or changed a global option with `options()`,
# or modified the working directory with `setwd()`.

# If the behavior of other functions differ before and after running
# your function, you have modified the landscape.

# - Do NOT use `library()` or `require()` in your package.
#   These modify the search path, affecting what functions are available
#   from the global environment.
#   Instead, use the `DESCRIPTION` file to specify package requirements
#   with `usethis::use_package()`.

# - NEVER use `source()` to load code from a file in your package.
#   `source()` modifies the current environment, inserting the results of
#   executing the code.
#   All files inside of `R/` will be available as long as you exported them
#   with the roxygen tag `#' @export`

# A list of functions that you avoid in your package:
# - `options()`
# - `par()`
# - `setwd()`
# - `Sys.setenv()`
# - `Sys.setlocale()`
# - `set.seed()`

# If you have to use them, clean up afterwards.
# Use the "withr" package for that purpose.

# You should also not rely on the user to have the same 
# time zone, or language settings as you do!

x <- c("bernard", "bérénice", "béatrice", "boris")
withr::with_locale(new = c(LC_COLLATE = "fr_FR"), code = sort(x))
# "béatrice" "bérénice" "bernard"  "boris"

x <- c("a", "A", "B", "b", "A", "b")
withr::with_locale(new = c(LC_COLLATE = "en_CA"), code = sort(x))
# "a" "A" "A" "b" "b" "B"

withr::with_locale(new = c(LC_COLLATE = "C"), code = sort(x))
# "A" "A" "B" "a" "b" "b"


### 6.5.1 Manage state with "withr" ----

# If you need to modify the R landscape inside of a function,
# use the `base::on.exit()` function to reverse this change *on exit*.

# Use `base::on.exit()` to register code to run later, that restores the landscape
# to its original state.

# Note that `base::on.exit()` will also run if we exit the function due
# to an error.

# Mange state with the "withr" package, that provides `withr::defer()` 
# as a replacement for `base::on.exit()`.

# withr's default stack-like behavior (LIFO = last in, first out),
# and its `envir` argument are very useful.

# The general pattern is:
# 1. capture the original state
# 2. schedule its eventual restoration "on exit"
# 3. make the state change with `options()`, `par()`, etc.
# 4. Return the old value when you provide a new value
f <- function(x, y, z) {
  # ... # with option "as found"
  old <- options(width = 20) # width option is 20
  withr::defer(expr = options(old)) # width option is 20
  # .... # width option is 20
} # original width option restored


# Some state changes, such as modifying session options, arise so frequently
# that "withr" offers ready-made helpers:
# - `withr::with_options()`, `withr::local_options()`: Set an R option with `option()`
# - `withr::width_dir()`, `withr::local_dir()`: Change the working directory with `setwd()`
# - `withr::with_par()`, `withr::local_par()`: Set a graphics parameter with `par()`

# - `withr::with_*()` functions execute small code snippets with a temporarily moddified state.
#   They are inspired by `base::with(data, expr)`.
f <- function(x, sig_digits) {
  # imagine lots of code here
  withr::with_options(
    new = list(digits = sig_digits), 
    code = print(x)
    )
  # ... and a lot more code here
}

# - `withr::local_*()` functions modify a state from now until the function exits:
g <- function(x, sig_digits) {
  withr::local_options(.new = list(digits = sig_digits))
  print(x)
  # imagine lots of code here
}

# "withr" can schedule deferred actions from the global environment.
# The cleanup actions can be executed with `withr::deferred_run()`
# or cleared without execution with `withr::deferred_clear()`.


### 6.5.2 Restore state with `base::on.exit()` ----

f <- function(x, y, z) {
  # ...
  old <- options(mfrow = c(2, 2), pty = "s")
  on.exit(options(old), add = TRUE)
}

# Other state changes are not available with such setters and must be implemented
# manually:
g <- function(a, b, c) {
  # ...
  scratch_file <- tempfile()
  on.exit(expr = unlink(scratch_file), add = TRUE)
  file.create(scratch_file)
  # ...
}

# We specify `base::on.exit(..., add = TRUE)` to *add* to the list of
# deferred cleanup tasks rather than to replace this list entirely.

# This behavior is the default value of the "after" argument in
# `withr::defer()`.


### 6.4.3 Isolate side effects ----

# Try to isolate side effects in functions that **only** produce output.

# Separate data preparation and plotting in two functions.


### 6.5.4 When you do need side-effects ----

# If your package talks to an external system - you might need to do some
# initial setup when the package loads - you do need side effects.

# Teh special functions `.onLoad()` and `.onAttach()` are called when the package
# is loaded and attached.

# Always use `.onLoad()` unless explicitly directed otherwise.

# - To set custom options for your package with `options()`.
#   To avoid conflicts with other packages, ensure that you prefix option names
#   with the name of your package.
#   Do not override options the user has already set.
#   "dplyr"'s `.onLoad()` function sets an option that controls progress reporting:
.onLoad <- function(libname, pkgname) {
  op <- options()
  op.dplyr <- list(
    dplyr.show_progress = TRUE
  )
  toset <- !(names(op.dplyr) %in% names(op))
  if (any(toset)) options(op.dplyr[toset])
  
  invisible()
}

# This allwos functions in "dplyr" to use `getOption("dplyr.show_progress")`
# to tetermine whether to show progress bars, relying on the fact that a 
# sensible default value has already been set.


# - To display an informative message when the package is attached.
#   This makes usage conditions clear and displays package capabilities
#   based on current system conditions.
#   Strtup messages are one place where you should use `.onAttach()` instead
#   of `.onLoad()`. Always use `packageStartupMessage()` instead of `message()`
#   to allow `suppressPackageStartupMessages()` to selectively suppress package
#   startup messges.
.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to my package")
}

# The arguments `libname` and `pkgname` within `.onLoad()` and `.onAttach()`
# are rarely used anymore.
# They give the path where the package is installed (the "library")
# and the name of the package.

# If you use `.onLoad()`, use `.onUnload()` to clean up any side effects.

# By convention, `.onLoad()` and friends are saved in a file called
# `pkg/R/zzz.R`.

# Do NOT use `.First.lib()` and `.Last.lib()`, the old versions of
# `.onLoad()` and `.onUnload()`.


# `withr::with_preserve_seed()` leaves the user's random seed as it was found.


## 6.6 Constant health checks ---

# A typical sequence of calls during package development:
# 1. Edit files in `pkg/R/`
# 2. Call `devtools::document()` to change help files and `NAMESPACE`
# 3. Call `devtools::load_all()` to load the changed functions
# 4. Run exampels interactively
# 5. Call `devtools::test()` or `devtools::test_active_file()`
# 6. Call `devtools::check()`


# If you plant ot submit your package to CRAN, use only ASCII characters
# in your `.R` files.
# These incldue digits 0 to 9, and lowercase (uppercase) letters a-z (A-Z),
# and common punctuation.

# If you need Greek or accented letters or symbols, use Unicode characters
# specified with the special Unicaode escape format `"\u1234"`.
# Find the correct code point with `stringi::str_escape_uniqode()`:
x <- "This is a bullet •"
y <- "This is a bullet \u2022"
identical(x = x, y = y)
# TRUE

cat(stringi::stri_escape_unicode(x))
# This is a bullet \u2022

# Very often, "curly" or smart quotes sneak into copied and pasted code.
# The function `tools::showNonASCII()` and `tools::showNonASCIIfile(file)`
# help you fidn the offending files and lines.
tools::showNonASCIIfile("06_r-code.R")

# END