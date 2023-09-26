# Chapter 21 - Life cycle ----

# Several practices help your users track changes in your package:

# - The package version number

# - The life cycle stage

# - The deprecation process


## 21.1 Package evolution ----

# Increment the package version number and release it.
# This information lives in the `Version` field of the `DESCRIPTION` file:
# Package: usethis
# Title: Automate Package and Project Setup
# Version 2.1.6
# ....


## 21.2 Package version number ----

# An R package version is a sequence of at least two integers,
# separated by either `.` or `-`.

# Base R offers the 
base::package_version()
# function to parse a package version string into a proper
# S3 class by the same name.

# This class makes it easier to do things like compare versions:

base::package_version(c("1.0", "0.9.1-10"))
# '1.0' '0.9.1.10'

class(base::package_version("1.0"))
# "package_version" "numeric_version"

# these versions are not allowed for an R package
base::package_version("1")
# Error

base::package_version("1.0-devel")
# Error

# comparing package versions
package_version("1.9") == package_version("1.9.0")
# TRUE

package_version("1.9") < package_version("1.9.2")
# TRUE

package_version(c("1.9", "1.9.2")) < package_version("1.10")
# TRUE TRUE

# The package_version() function is necessary to convert the character string
# into a numeric form:
"2.0" > "10.0"
# TRUE

package_version("2.0") > package_version("10.0")
# FALSE

# When comparing strings, "2.0" is considered to be greater than "10.0"
# because the character "2" comes after "1".

# In your own code, you can determine which version of a package is
# installed with 
utils::packageVersion()

packageVersion("usethis")
# '2.2.2.9000'

str(packageVersion("usethis"))
# Classes 'package_version' 'numeric_version' hidden list of 1
#  $ : int [1:4] 2 2 2 9000

packageVersion("usethis") > package_version("10.0")
# FASLE

packageVersion("usethis") > "10.0"
# FALSE


## 21.3 Tidyverse package version conventions ----

# The recommended framework for the package version number is the following:

# - Always use the dot `.` as the separator, never the dash `-`.


# - A released version number consists of three numbers:
#   `<major>.<minor>.<patch>`


# - An in-development package has a fourth component:
#   The development version starting at 9000.



## 21.4 Backward compatibility and breaking change ----


# Examples of breaking change are:

# - Removing a function

# - Removing an argument

# - Narrowing the set of valid inputs to a function


# The following changes are not considered breaking:

# - Adding a function (as long as it does not introduce a conflict)

# - Adding an argument

# - Increasing the set of valid inputs

# - Changing the text of a print method

# - Fixing a bug


# A pragmatic definition of a breaking change is the following:

#   A change is breaking if it causes a CRAN package that was previously
#   passing `R CMD check` to now fail AND the package's original usage
#   and behavior is correct.


## 21.5 Major vs minor vs patch release.

# Recall that version numbers have the following forms:

# `<major>.<minor>.<patch>` for released versions
# `<major>.<minor>.<patch>.<dev>` for in-development versions.

# - **patch releases** include bug fixes.

# - **minor releases** include new features and changes that are backward compatible.

# - **major releases** include changes that are NOT backward compatible.

# Note that the `1.0.0` release version has special significance
# and indicates that your package is feature complete with a stable API.


### 21.5.1 Package version mechanics ----

# Your package starts with the version number `0.0.0.9000`.
usethis::create_package()
# starts with this version by default, and writes it into the
# `Version` field of the `DESCRIPTION` file.

# From that point on, call
usethis::use_version()
# to increment the package version.

# When called with no argument, it presents the following menu:
#> Current version is 0.1
#> What should the new version be? (0 to exit)
#> 
#> 1: major --> 1.0
#> 2: minor --> 0.2
#> 3: patch --> 0.1.1
#>      dev --> 0.1.0.9000
#>      
#> Selection:

usethis::use_version() 
# will add a new heading to `NEWS.md`.


## 21.6 Pros and cons of breaking change ----

# If it is important to protect a data product against change in its
# R package dependencies, the use of a project-specific package
# library is recommended.

# The "renv" package keeps package updates triggered by work in
# project A from breaking code in project B.


## 21.7 Life cycle stages and supporting tools ----

# The "tidyverse" team has created tooling and documentation
# for package evolution that lives in the "lifecycle" package.

# The four life cycle states are:

# - Stable. The default stage that signals that users can rely on the package.

# - Experimental. The maintainer reserves the right to change it without
#   much of a deprecation process.
#   Such a package has not had a `1.0.0` release yet.

# - Deprecated. This applies to functionality that is slated for removal.
#   Initially, it still works but triggers a deprecation warning
#   with information about preferred alternatives.
#   After some time, such functions are removed for good.

# - Superseded. A softer variant of deprecated, where legacy
#   functionality is preserved.

vignette("stages", package = "lifecycle")


# The life cycle state is communicated through a badge.

# If you would like to use life cycle badges, call
usethis::use_lifecycle()
# Adding 'lifecycle' to Imports field in DESCRIPTION
# * Refer to function with `lifecycle::fun()`
# Adding '@importFrom lifecycle deprecated' to 'R/somepackage-package.R'
# Writing 'NAMESPACE'
# Creating 'man/figures/'
# Copied SVG badges to 'man/figures/'
# * Add badges to documentation topics by inserting one of
#' `r lifecycle::badge('experimental')`
#' `r lifecycle::badge('superseded')`
#' `r lifecycle::badge('deprecated')`


# This leaves you in a position to use "lifecycle" badges in help
# topics and to use "lifecycle" functions.


# An example of a superseded function is `dplyr::top_n()`,
# which includes a "lifecycle" badge in its `#' @description` block:
#' Select top (or bottom) n rows (by value)
#' 
#' @description
#' `r lifecycle::badge("superseded")`
#' `top_n()` has been superseded in favor of ...


# For a function argument, include the badge in the `#' @param` tag.
# The `readr::write_file(path = "...")` argument is deprecated:
#' @param path `r lifecycle::badge("deprecated")` Use the `file` argument
#' instead.


# Call
usethis::use_lifecycle_badge()
# if you want to use a badge in `README` to indicate the life cycle
# of an entire package.

# If the life cycle of your package is stable, it is not necessary
# to also use a badge since that is the assumed default stage.


### 21.7.2 Deprecating a function ----

# If you want to remove a function from your package you should do so
# in *phases*.

# Deprecation means something is explicitly discouraged, but
# has not yet been removed.

# Various deprecation scenarios are explored in
vignette("communicate", package = "lifecycle")


lifecycle::deprecate_warn()
# is used inside a function to inform the user that he or she
# is using a deprecated feature and, ideally, to let them
# know about the preferred alternative.

# In this example, the `plus3()` function is being replaced by `add3()`:

# new function
add3 <- function(x, y, z) {
  return(x + y + z)
}


# old function
plus3 <- function(x, y, z) {
  lifecycle::deprecate_warn(when = "1.0.0", what = "plus3()", with = "add3()")
  return(add3(x, y, z))
}

plus3(x = 1, y = 2, z = 3)
# 6
# Warning message:
# `plus3()` was deprecated in <somepackage> 1.0.0.
# i Please use `add3()` instead.


lifecycle::deprecate_warn()
# and friends all have the following features:

# - The warning message is built from inputs `when`, `what`, `with`,
#   and `details`, which gives deprecation warnings a predictable form.

# - By default, a specific warning is only issued every 8 hours.
#   The goal is to be just annoying enough to motivate the user to update
#   their code before the function or argument is removed.
#   Near the end of the deprecation process, the `always` argument
#   can be set to `TREU` to warn on every call.

# - If you use
lifecycle::deprecate_soft()
# instead of 
lifecycle::deprecate_warn()
# a warning is only issued if the person reading it is the one who
# can update the offending code.


### 21.7.3 Deprecating an argument ----

lifecycle::deprecate_warn()
# is useful when deprecating an argument.

lifecycle::deprecated()
# can be used as the default value for the deprecated argument.

# Here, we show the switch from the `path` to the `file` argument
# in the `readr::write_file()` function:
write_file <- function(x,
                       file,
                       append = FALSE,
                       path = lifecycle::deprecated()) {
  if (lifecycle::is_present(path)) {
    lifecycle::deprecate_warn(when = "1.4.0", what = "write_file(path)", with = "write_file(file)")
    file <- path
  }
  # ...
}

# When the user calls
readr::write_file(x = "hi", path = tempfile("lifecycle-demo-"))
# he or she will get the warning
# Warning: The `path` argument of `write_file()` is deprecated as of readr
# 1.4.0.
# i Please use the `file` argument instead.


# The use of 
lifecycle::deprecated()
# as the default accomplishes two things:

# First, if the user reads the documentation, it is a strong signal that
# the argument is deprecated.

# The package maintainer can use
lifecycle::is_present()
# to determine if the user has specified the deprecated argument and 
# proceed accordingly.

# If you are using "base" R only, the
base::missing()
# function has substantial overlap with
lifecycle::is_present()
# but it can be trickier to use.


### 21.7.4 Deprecation helpers ----

# An example of a typical function after starting the deprecation
# process from the "googledrive" package:
drive_publish <- function(file, ..., verbose = lifecycle::deprecated()) {
  warn_for_verbose(vebose)
  # Rest of the function
}

# Note the use of `verbose = lifecycle::deprecated()`.

# A simplified version of `warn_for_verbose()`:
warn_for_verbose <- function(verbose = TRUE,
                             env = rlang::caller_env(),
                             user_env = rlang::caller_env(n = 2)) {
  # This function is not meant to be called directly, so don't worry about its
  # default of `verbose = TRUE`.
  # In authentic, indirect usage of this helper, this picks up on whether
  # `verbose` was present in the **user's** call to the calling function.
  if (!lifecycle::is_present(verbose) || isTRUE(verbose)) {
    return(invisible())
  }
  
  lifecycle::deprecate_warn(
    when = "2.0.0",
    what = I("The `verbose` argument"),
    details = c(
      "Set `options(googledrive_quiet = TRUE)` to suppress all googledrive messages.",
      "For finer control, use `local_drive_quiet()`or `with_drive_quite()`.",
      "googledrive's `verbose`argument will be removed in the future."
    ),
    user_env = user_env
  )
  # only set the option during authentic, indirect usage
  if (!identical(x = env, y = rlang::global_env())) {
    local_drive_quiet(env = env)
  }
  invisible()
}


### 21.7.5 Dealing with change in a dependency ----

# If you don't want to require your users to update a package that
# your own package depends on, you could make your package work with
# both the new and the old versions.

# This means you will have to check its version at run-time
# and proceed accordingly:
your_existing_function <- function(..., cool_new_feature = FALSE) {
  if (isTRUE(cool_new_feature) && packageVersion("otherpkg") < "1.0.0") {
    message("otherpkg >= 1.0.0 is needed for cool_new_feature")
    cool_new_feature <- FALSE
  }
  # the rest of the function
}

your_new_function <- function(...) {
  if (packageVersion("otherpkg") < "1.0.0") {
    stop("otherpkg >= 1.0.0 needed for this function.")
  }
  # the rest of the function
}

# Alternatively, this would be a great place to use
rlang::is_installed()
# and
rlang::check_installed()
# with the `version` argument.


# Sometimes you can re-factor your code to make it work with either
# version of the other package, in which case you don't need to 
# condition on the other package's version at all.

# Consider this example:
your_function <- function(...) {
  if (packageVersion("otherpkg") >= "1.3.9000") {
    otherpkg::their_new_function()
  } else {
    otherpkg::their_old_function()
  }
  # the rest of the function
}


### 21.7.6 Superseding a function ----

# An example is `tidyr::spread()` and `tidyr::gather()`.
# Those functions have been superseded by
# `tidyr::pivot_wider()` and `tidyr::pivot_longer()`.

# But some users still prefer to use the older functions and they
# may be in use in lots of projects that are not under active development.

# Thus, `spread()` and `gather()` are marked as superseded,
# but they are not at risk of removal.


# A related phenomenon is when you change some aspect of your package
# but you give existing users a way to opt-in to the legacy behavior:

# - In "tidyr 1.0.0", the interface of `tidyr::nest()` and `tidyr::unnest()` changed.
#   The old interface remains available via `tidyr::nest_legacy()` and `tidyr::unnest_legacy()`.


# - "dlyr 1.1.0" uses a much faster algorithm for computing groups, but this
#   speedier method sorts the groups with respect to the C locale,
#   whereas previously the system locale was used.
#   The global option `dplyr:legacy_locale` allows users to request the legacy behavior.

# - The "tidyverse" packages have been standardizing on a common approach to
#   name repair, which is implemented in `vctrs::vec_as_names()`.
#   The "vctrs" package also offers `vctrs::vec_as_names_legacy()`,
#   which makes it easier to get names repaired with older strategies.

# - "readr 2.0.0" introduced a so-called "second edition", marking the siwtch
#   to a backend provided by the "vroom" package.
#   Functions like `readr::with_edition(1, ...)` and `readr::local_edition(1)`
#   make it easier for a user to request first edition behavior.

# END