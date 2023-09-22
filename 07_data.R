# Chapter 07 - Data ----

# The primary purpose of including data in a package is to distribute
# data sets that help document the package's functions.

# Examples are 
# - `tidyr::billboard` (song rankings)
# - `tidyr::who` (tuberculosis data from the WHO)
# - `dplyr::starwars` (Star Wars characters)
# - `dplyr::storms` (storm tracks)

# some packages, like "nyclflights13" and "babynames" only exist to 
# distribute data.

# - To store R objects and make them available to the user, put them in
#   `pkg/data/`. This is where example data sets belong.

# - To store R objects for the developer only, put them in `pkg/R/sysdata.rda`.
#   This is where internal data belongs.

# - To store raw, non-R-specific data for users, put it in `pkg/inst/extdata/`
#   "readr" and "readxl" use this directory to provide some delimited files and
#   Excel workbooks.

# - To story dynamic data that reflects the internal state of your package
#   within a single R session, use an environment.

# - To store data persistently across R sessions, like configurations,
#  use the officially sanctioned locations.


## 7.2 Exported data ----

# Data inside a package that is exported to the user's memory should live
# in the directory `pkg/data/`.

# Each file inside of `pkg/data/` should be a `.rda` file created by
# `save()`, containing a single R object, with the same name as the file.

# Call `usethis::use_data()`:
my_pkg_data <- sample(1e3)
usethis::use_data(my_pkg_data)

# This call works only inside of package projects.

# If you work on a package called "pgk", `usethis::use_data(my_pkg_data)`
# will create the file `pkg/data/my_pk_data.rda` and add
# `LazyData: true` to the `DESCRIPTION` file.

# This makes the `my_pkg_data` object available to users of "pkg" via
# `pkg::my_pkg_data`, after attaching "pkg" with `library(pkg)` with `my_pkg_data`.

# Previously, the lookup table in "golf" was only available
# with `golf:::beach_lookup`.
# This is okay because it is meant for internal use only.

# For larger data sets, use compression settings, controlled by the
# `compress` argument within `usethis::use_data()`

# The default is "bzip2", but "gzip" or "xz" may create even smaller files.

# Other possible data file types are documented in the documentation
# for `utils::data()`
?utils::data

# - Store a single R object in each `pkg/data/*.rda` file.
# - Use the same name of that object and its `.rda` file
# - Use lazy-loading, by default.

# When the `DESCRIPTION` file contains `LazyData: true`, the data
# will be lazily loaded, meaning it won't occupy any memory until it is accessed
# for the first time.
lobstr::mem_used()
library(nycflights13)
lobstr::mem_used()

invisible(flights)
lobstr::mem_used()

# It is best practice to always include `LazyData: true` in the `DESCRIPTION` file
# if you ship `.rda` files below `pkg/data/`.
# If you use `usethis::use_data()` to create such datasets, this is done automatically.


# WARNING: Do NOT pre-load lazily-loaded datasets with `utils::data()`.

# Using `data(some_pkg_data)` creates an object in the user's global workspace.
# You might accidentally overwrite a pre-existing object with the same name.

# `data(foo)` may not create an object called "foo".

# `data(some_pkg_data, package = "pkg")` may be appropriate for data that
# are not strictly necessary.

# But alternatives such as `pkg::some_pkg_data` are better, because
# they do not alter the global workspace.

# In any case, `data()` is historical and not necessary anymore.


### 7.1.1 Preserve the origin story of package data ----

# The data you include in `data/` is a cleaned up version of raw data
# from elsewhere.

# Include the code used to do this in the source version of your package.

# For example, you might include the raw recession dummy data in `pkg/data-raw`
# and the clean "Date" files in `pkg/data/`.
usethis::use_data_raw()
usethis::use_data_raw("my_pkg_data")

# `usethis::use_data_raw()` creates the `pkg/data-raw/` directory and lists
# it in `.Rbuildignore`.

# The `.R` script inside of `pkg/data-raw/` includes a call to
# `usethis::use_data()` at the very end.


# NOTE: If you want to submit your package to CRAN, any data included
# should be smaller than one megabyte.
# Otherwise you need to argue for an exemption.

# It is best to download the data in its own package.

# The default for `usethis::use_data(compress = "")` is `"bzip2"`,
# whereas the default for `base::save(compress = "")` is effectively
# `"gzip"`. `"xz"` is another valid option.

# Experiment with different data compression methods.
# `tools::resaveRdaFiles("data/")` automates this process but it does not
# inform you which method was chosen.
# Learn this after the fact with `tools::checkRdaFiles()`.
# Update the corresponding `usethis::use_data(compress = "")` call
# below `pkg/data-raw/` and re-generate the `.Rda` file.


### 7.1.2 Documenting datasets ----

# Objects inside `pkg/data/` are always effectively exported.
# They use a slightly different mechanism than `NAMESPACE`
# They should be documented.

# The roxygen2 block includes the special roxygen tags
# `#' @format` to give an overview of the dataset.
# `#' @source` provides the URL
# NEVER use `#' @export` on a data set.


### 7.1.3 Non-ASCII characters in data ----

# You should embrace the UTF-8 Everywhere manifesto.
# The `DESCRIPTION` file placed by `usethis::create_package()`
# always includes `Encoding: UTF-8`.

# Use `base::Encoding()` to learn the current encoding elements in a character vector
# and functions such as `base::enc2utf8()` or `base::iconv()` to convert between encodings.

Encoding("Valérié")
enc2utf8("Valérié")

# If you have UTF-8-encoded strings in your package,
# `R CMD check` may report:
# `- checkign data for non-ASCII character ... NOTE
#    Note: found 352 marked UTF-8 strings`

# This `NOTE` is informational and requires no action from you.

# It will be suppressed by `R CMD check --as-cran`.
# By default, `devtools::check()` sets the `--as-cran` flag and does
# *not* transmit this `NOTE`.
# You can surface it by calling
# `devtools::check(cran = FALSE, env_vars = c("_R_CHECK_PACKAGE_DATASETS_SUPRESS_NOTES_) = "false")`


## 7.2 Internal data ----

# It is possible that a package function needs to access pre-computed
# data. If you put these in `pkg/data/`, they are available to package users,
# which is not appropriate.

# If the data is small and simple, you can define it with `c()` or
# `data.frame()` within `pkg/R/`, perhaps in `pkg/R/data.R`.

# Larger data objects should be stored inside of the package's internal
# data folder `pkg/R/sysdata.rda`.

# The easiewst way to create `pkg/R/sysdata.rda` is 
# `usethis::use_data(internal = TRUE)`:

# internal_this <- ...; internal_that <- ...;
# `usethis::use_data(internal_this, internal_that, internal = TRUE)`.

# Unlike in `pkg/data/`, where one `.rda` file is exported for
# each data object, internal data objects are all stored together
# i a single file `pkg/R/sysdata.rda`.

# During development, `internal_this`, and `internal_that` are
# available after a call to `devtools::load_all()`, just like an
# internal function.

# - Store code that generates individual internal data objects,
#   as well as the `usethis::use_data()` call that writes them
#   into `pkg/R/sysdata.rda`.

# - `usethis::use_data_raw()` can be used to initiate the use of
#   `pkg/data-raw/` or a new `.R` script.

# - If the system data is too large, try `usethis::use_data(compress = "")`.

# NOTE that objects in `pkg/R/sysdata.rda` are NOT exported
# don't impact the `DESCRIPTION` file.


## 7.3 Raw data file ---

# To show exmples of loading / parsing raw data, put the original files
# into `pkg/inst/extdata/`.
# When the package is installed, all files and folders inside `pkg/inst/`
# are moved up one level to the top-level directory.
# This means they cannot have names that conflict with standard parts
# of an R package like `pkg/R/` or `DESCRIPTION`.

# The files below `pkg/inst/extdata` in the source package will
# be located in `pkg/extdata/` in the installed package.

# Include such files when the package's core function is to act
# on external files, like the "readr", "readxl", "xml2", or "archive" packages.

# Some packages provide a CSV-version of the package data that is
# also provided as an R object.

# - "palmerpenguins" includes the files `penguins` and `penguins_raw`,
#   that are also represented as `extdata/penguins.csv` and
# ` extdata/penguins_raw.csv`.

# - "gapminder" contains `gapminder`, `continent_colors` and `country_colors` also
#   as `extdata/gapminder.tsv`, `extdata/continent-colors.tsv` and `extdata/country-colors.tsv`.

# This gives teachers and users more possibilities to work with.


### 7.3.1 Filepaths ----

# The path to a package file found below `extdata/` depends on the local environment,
# i.e. on where installed packages live on that machine.

# `base::system.file()` can report the full path to files distributed with an R package:
base::system.file("extdata", package = "readxl")
# "C:/Users/matth/AppData/Local/R/win-library/4.3/readxl/extdata"

base::system.file("extdata", package = "readxl") |> list.files()
# [1] "clippy.xls"    "clippy.xlsx"   "datasets.xls"  "datasets.xlsx"
# [5] "deaths.xls"    "deaths.xlsx"   "geometry.xls"  "geometry.xlsx"
# [9] "type-me.xls"   "type-me.xlsx" 

# "devtools" provides a shim for `base::system.file()` that is activated
# by `devtools::load_all()` that makes interactive calls to `base::system.file()`
# work within the package namespace.

# By default, `base::system.file()` returns an empty string for a file
# that does not exist, instead of an error:
base::system.file("extdata", "I_do_not_exist.csv", package = "readr")
# ""

# specify `mustWork = TRUE` to force a failure:
base::system.file("extdata", "I_do_not_exist.csv", package = "readr", mustWork = TRUE)
# Error : no file found.

# `fs::path_package()` is essentially `base::system.file()` with 
# some added features:
# - It errors if the file path does not exist.
# - It throws distinct errors if the package does not exist.
# - It works for interactive calls during development.
fs::path_package("extdata", package = "idonotexist")
# Error: Can't find package 'idonotexist' in library locations

fs::path_package("extdata", "I_do_not_exist.csv", package = "readr")
# Error: I_do_not_exist.csv' do not exist

fs::path_package("extdata", "chickens.csv", package = "readr")
# C:/Users/matth/AppData/Local/R/win-library/4.3/readr/extdata/chickens.csv


### 7.3.2 `pkg_example()` path helpers ----

# A convenience function that makes example files easy to access is
# a user-friendly wrapper around `base::system.file()` or `fs::path_package()`
# with some added features, such as the ability to list the example files.

readxl_example <- function(path = NULL) {
  if (is.null(path)) {
    dir(path = system.file("extdata", package = "readxl"))
  } else {
    system.file("extdata", path, package = "readxl", mustWork = TRUE)
  }
}

readxl::readxl_example()

readxl::readxl_example("clippy.xlsx")


## 7.4 Internal state ----

# Sometimes there is information that functions form your package need to
# access at load time, not at build time.

# Use an *environment* for this purpose.
# This environment must be created at build time, but can be populated
# with values after the package has been loaded.

# This works because environments have reference semantics, and not value semantics
# like other R objects.

# Consider a package to store the user's favorite letters and numbers.
# This file lives in `pkg/R/`:
favorite_letters <- letters[1:3]

#' Report my favorite letters
#' @export
mfl <- function() {
  return(favorite_letters)
}

#' Change my favorite letters
#' @export
set_mfl <- function(l = letters[24:26]) {
  old <- favorite_letters
  favorite_letters <<- l
  invisible(old)
}

# `favorite_letters` is initialized to `"a", "b", "c"` at build-time.
# The user can inspect `favorite_letters` with `mfl()`
# and set their favorite letters with `set_mfl()`.

# The super-assignment operator will change `favorite_letters`
# directly inside the global environment.
mfl()
# "a" "b" "c"

set_mfl(l = c("j", "f", "b"))
favorite_letters
# "j" "f" "b"

# This will fail inside of a package, because you can't change the 
# name-value bindings for objects in the package `NAMESPACE`.

# If we maintain the state within an internal package environment, we **can**
# modify objects contained inside the environment.

# Here we use an internal enviornment called "the":
the <- new.env(parent = emptyenv())
the$favorite_letters <- letters[1:3]

#' Report my favorite letters
#' @export
mfl2 <- function() {
  return(the$favorite_letters)
}

#' Change my favorite letters
#' @export
set_mfl2 <- function(l = letters[24:26]) {
  old <- the$favorite_letters
  the$favorite_letters <- l
  invisible(old)
}

# Now we can use this function within a package:
mfl2()
# "a" "b" "c"

set_mfl2(l = c("j", "f", "b"))

mfl2()
# "j" "f" "b"

# Note that at load time, the environment "the" is reset to its original
# definition, so when the user restarts R, the changes will be lost.

# You need to specify `parent = emptyenv()` because you don't want the
# environment to inherit from any nonempty environment.


# Because the definition of the environment needs to happen
# as a top-level assignment in a file below `pkg/R`,
# `pkg/R/aaa.R` is a common save choice.


# Packages that use an internal environment are:

# - "googledrive": Various functions need to know the file ID for the user's
#   home directory on Google Drive.
#   This requires an API call that yields a string of random characters.
#   It is determined upon first need, then cached for later used.

# - "usethis" needs to know the active project, the target directory for file modification.
#   It is often the current working directory.
#   Instead of the user having to specify the target project repeatedly,
#   it is determined when first needed, cached, and can be reset later.



## 7.5 Persistent user data ----

# Sometimes there is data that your package obtains on behalf of the user
# that should persist *even across R sessions*.

# It should comply with the external XDG Base Directory Specification.

# You need to use the official locations for persistent file storage
# to comply with CRAN's submission policies.

# You can't just write persistent data into the user's home directory.
# For R version 4.0 or later, packages may store user-specific data,
# configuration and cache files in their respective user directories
# obtained from `tools::R_user_dir()`, provided that
# default sizes are kept as small as possible.

# Examples of the generated file paths:
tools::R_user_dir(package = "pkg", which = "data")
# "C:\\Users\\matth\\AppData\\Roaming/R/data/R/pkg"

tools::R_user_dir(package = "pkg", which = "config")
# "C:\\Users\\matth\\AppData\\Roaming/R/config/R/pkg"

tools::R_user_dir(package = "pkg", which = "cache")
# "C:\\Users\\matth\\AppData\\Local/R/cache/R/pkg"


# For sensitive data such as user credentials, obtain the user's consent
# before storing it.

# The user's operating system or command line tools might provide
# more secure means to store sensitive data.

# The packages "keyring", "gitcreds", and "credentials" provide
# tools for such purposes.

# END