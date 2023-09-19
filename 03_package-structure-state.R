# Chapter 03 - Package structure and state ----

## 3.1 Package states ----

# When you create or modify a package, you work on its "source code"
# or "source files".

# You interact with the in-development package in its **source** form.

# This is NOT the package form you are most familiar in day-to-day usage.

# Package development workflows make sense if you understand the five states
# an R package can be in:


# - source
# - bundled
# - binary
# - installed
# - in-memory

# You already know some functions that put packages in these states.
# `install.packages()` moves a package from the source, bundled, or binary states
# into the installed state.

# `devtools::install_github()` takes a source package on GitHub and moves
# it into the installed state.

# The `library()` command loads the installed package into memory, making it
# available for immediate use.


## 3.2 Source package ----

# A **source** package is just a directory of files with a specific structure.
# It includes particular components such as a `DESCRIPTION` file,
# an `R/` directory containing `.R` files, and so on.

# Many R packages are developed in the open on GitHub or GitLab.
# If they are on CRAN, you can visit the package's CRAN landing page, e.g.:
# - forcats: https://cran.r-project.org/package=forcats
# - readxl: https://cran.r-project.org/package=readxl

# and one of its URLs links to a repository on a public hosting service, e.g.:
# - forcats: https://github.com/tidyverse/forcats
# - readxl: https://github.com/tidyverse/readxl

# Some maintainers forget to list this URL, even though their package is
# developed in a public repository, and you have to discover it via search.

# Even if a package is not developed on a public platform, you may visit its source
# in the unofficial, read-only mirror maintained by R-hub.
# Examples are:
# - MASS: https://github.com/cran/MASS
# - car: https://github.com/cran/car

# The source you see on the `cran` GitHub organisation is reverse-engineered
# from the package's CRAN releases.


## 3.3 Bundled package ----

# A **bundled** package is a package that has been compressed into a single file.

# By convention from Linux, package bundles in R use the extension
# `.tar.gz` and are referred to as "source tarballs".

# This means multiple files have been reduced to a single `.tar` file
# and then compressed using "gzip" to a `.gz` file.


# A bundle is a platform-agnostic, transportation-friendly intermediary
# between a source package and an installed package.

# Should you ever need to make a bundle from a package, you can use
# `devtools::build()`, which calls `pkgbuild::build()` under the hood,
# and, ultimately, calls `R CMD build`.


# Every CRAN package is available in bundled form via the "Package source"
# field of its landing page.

# Continuing the example from above, you could download the bundles
# `forcats_0.4.0.tar.gz` and `readxl_1.3.1.tar.gz` or whatever the
# current versions may be.

# You could unpack such a bundle in the shell (not in the R console) like so:
# `tar xvf forcats_0.4.0.tar.gz`

# If you decompress a bundle, you will see it looks almost the same as a source
# package.

# The main differences between a source package and an uncompressed bundle are:

# - Vignettes have been built, so rendered outputs, such as HTML, appear below
#   `inst/doc` and a vignette index appears in the `build/` directory.

# - A local source package might contain temporary files used to save time during development,
#   like compilation artefacts in `src/`. These are never found in a bundle.

# - Any files listed in `.Rbuildignore` are not included in the bundle.
#   These are typically files that facilitate your development process,
#    but should be excluded in the distributed product.


### 3.3.1 `.Rbuildignore` ----

# The `.Rbuildignore` file controls which files form the source package
# make it into the downstream forms.

# Each line of `.Rbuildignore` s a Perl-compatible regular expression that is
# matched, without regard to case, against the path to each file in the source package.

# If the regular expression matches, that file or directory is excluded.

# There are some default exclusions implemented by R itself, mostly related
# to classic version control systems and editors such as SVN, Git, and Emacs.


# We modify the `.Rbuildignore` file with `usethis::use_build_ignore()`,
# which takes care of regular expression anchoring and escaping.

# To exclude a specific file or directory, you **MUST** anchor the regular
# expression.

# To exclude a directory called "notes", the `.Rbuildignore` entry must be
# `^notes$`, because the unanchored regular expression `notes` will match any file
# containing "note", e.g., `R/notes.R`, `man/important-notes.R`, `data/endnotes.Rdata`, etc.


# The files you should `.Rbuildignore` fall into two broad classes:

# - Files that help generate package contents:
#   - Using `README.Rmd` to generate a `README.md` file.
#   - Storing `.R` scripts to update internal or exported data.

# - Files that drive package development, checking, and documentation outside of
#   CRAN's purview:
#   - Files relating to the RStudio IDE
#   - Using the "pkgdown" package to generate a website.
#   - Configuration files


## 3.4 Binary package ----

# If you want to distribute your package to an R user who does not have
# package development tools such as "RTools", you need to provide a **binary** package.

# The primary maker and distributor of binary packages is CRAN.

# A binary package is a single file, but unlike a bundled package,
# it is platform specific (Windows or macOS).

# Binary packages for Windows end in `.zip`.
# If yo need to make a binary package, use `devtools::build(binary = TRUE)`.

# Under the hood, this calls `pkgbuild::build(binary = TRUE)` and, ultimately,
# `CMD INSTALL --build`.


# If you submit your package in bundled form to CRAN, the latter will create
# and distribute the package binaries.

# CRAN packages are available in binary form.
# The "readxl" package for Windows in binary form would be
# `readxl_1.3.1.zip`.

# This is what will be installed when you call `install.packages()`.


# If you uncompress a binary package, you will see that the internal structure
# is rather different from a source or bundled package:

# - There are no `.R` files in the `R/` directory - instead there are three files
#   that store the parsed functions in an efficient format.
#   This is the result of loading all the R code and then saving the functions
#   with `save()`.

# - A `Meta/` directory contains `.rds` files that contain cached metadata about
#   the package, like what topics the help files cover and a parsed version of
#   the `DESCRIPTION` file. You can use `readRDS()` to read these files.
#   The files make package loading faster by caching costly computations.

# - The actual help content appears in `help/` and `html/` (no longer in `man/`).

# - If you had any objects in `data/`, they have now been converted into a more efficient form.

# - The contents of `inst/` are moved to the top-level directory. For example,
#   vignette files are now in `doc/`.

# - some files and folders have been dropped, such as `README.md`, `build/`, `tests/`,
#   and `vignettes/`.


## 3.5 Installed package ----

# An **installed** package is a binary package that has been decompressed into
# a package library.

# There are many methods to install a package, depending on the state of the uninstalled
# package:

# - `library()` puts an installed package into memory.
# - `install.packages()` takes a package from a CRAN repository, downloads the
#   binary files and installs it as a library.
# - `install.packages(type = "source")` takes a package from its CRAN repository,
#   puts the bundle on disk, and installs the library.
# - `devtools::install_github()` installs a package from its GitHub repository,
#   puts the bundle on disk, and installs the library.
# - `devtools::install()` takes your source code, puts the bundle on disk, and installs the library.
# - `devtools::build()` takes your source code and builds the bundle on disk.
# - `devtools::build(binary = TRUE)` takes your source code and saves it as a binary on your disk.
# - `devtools::load_all()` takes your source code and directly puts it as a library into the memory.

# The built-in command line tool `R CMD INSTALL` powers all package installations.

# Usually, installing R packages from within an R session works just fine.
# It can cause errors though, when you try to re-install a package that is already
# in use in the current session.

# If you try to install an R package with compiled code on Windows, an attempt to
# install a new version of a package that is currently in use can result in a
# corrupt installation, meaning the package's R code has been updated, but its
# compiled code has not.

# Windows users should strive to install packages in a clean R session, with as
# few packages loaded as possible.

# The problem arises due to how file handles are locked on Windows.

# The "pak" package provides an alternative to `install.packages()` and
# `devtools::install_github()`.

# One of "pak"'s flagship features is that it nicely solves the "locked DDL" problem
# described above, i.e. updating a package with compiled code on Windows.

# "pak" will soon become the official recommendation for package installment.


# In the meantime, you should use "devtool"'s `install_*()` functions.
# This family of functions is powered by the "remotes" package and re-exported by "devtools".

library(remotes)

funs <- as.character(lsf.str(pos = "package:remotes"))
funs

grep(pattern = "^install_.+", x = funs, value = TRUE)

# There are functions to install packages from public repositories
# such as CRNAN, GitHub, GitLab, or BioConductor,
# to install from versioning software such as Git or SVN,
# to install from a custom URL and to install specific versions of a package.


# The `.Rinstignore` file lets you keep files present in a package bundle out of the
# installed package. This is rarely needed though.


## 3.6 In-memory package ----

library(usethis)

# Assuming the package "usethis" is installed, the call `library(usethis)` makes
# all the functions within the "usethis" package available for use directly from memory.

# We can for example call `create_package(path = "path/to/my/coolpackage")`.

# The "usethis" package is now loaded into memory, and has been attached to the
# **search path**.

# The distinction between loading and attaching packages is not important when
# writing scripts, but very important when writing packages.


# `library()` is not a great way to test packages during development, thus
# you should use `devtools::load_all()` during the development process.
# It loads the source package directly into memory.


## 3.7 Package libraries ----

# When you call `library(somepackage)`, R looks through the current **libraries**
# for an installed package named "somepackage" and, if successful, makes it available for use.

# In R, a **library** is a directory containing installed packages.

# Please note that we use the `library()` function to load a **package**.

# The libraries saved on your disk can be seen with `.libPaths()` on Windows:
.libPaths()
lapply(X = .libPaths(), FUN = list.dirs, recursive = FALSE, full.names = FALSE)

# `.libPaths()` revealed that there are two active libraries:
# 1. A user library
# 2. A system-level or global library.

# With this setup, add-on packages installed from CRAN or under local development
# are kept in the user library.

# The file paths of these libraries make it clear they are associated with a specific
# version of R.

# This reflects and enforces the fact that you need to re-install your add-on
# packages when you update R from say version 4.3 to 4.4, which is a change
# in the **minor** version.

# You generally do not need to re-install add-on packages for a **patch** release,
# e.g. going from 4.3.1 to 4.3.2.


# Packages like "renv" and its predecessor, "packrat", automate the process of
# managing project-specific libraries.

# This is important to make data products reproducible, portable, and isolated
# from one another.

# During package development, you might want to prepend the library search path
# with a temporary library, containing a set of packages at specific versions,
# in order to explore issues with backwards and forwards compatibility, without
# affecting other day-to-day work.

# The main levers that control which libraries are active are:

# - Environment variables, like `R_LIBS` and `R_LIBS_USER`, which are consulted at startup.

# - Calling `.libPaths()` with one or more filepaths.

# - Executing small snippets of code with a temporarily altered library search path via
#   `withr::with_libpaths()`.

# - Arguments ot individual functions, like `install.packages(lib = ...)`
#   and `library(lib.loc = ...)`.


# Note that `library()` should NEVER be used *inside a package*.


# To see the set of filepaths that should be on your radar, execute
dir(full.names = TRUE, recursive = TRUE, include.dirs = TRUE, all.files = TRUE)
# in the package's top-level directory.

# You can also check out the help files for
?Startup
?.libPaths

# END
