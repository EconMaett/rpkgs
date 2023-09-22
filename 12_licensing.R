# Chapter 12 - Licensing ----

## 12.1 Big picture ----

# There are two types of open source licenses:

# - **Permissive** licenses allow the code to be freely copied, modified, and
#   published on the single restriction that the license is preserved.
#   The MIT and Apache licenses are two common permissive licenses.
#   The BSD license is an older variant thereof.

# - **Copyleft** licenses are stricter. The most common example is the
#   GPL license that allows you to freely copy and modify the code for
#   personal use, but if you publish modified versions or bundles with
#   other code, the modified version or complete bundle must also be
#   licensed with the GPL.


# A 2022 analysis found that about 70% of CRAN packages use a 
# copyleft license and only about 20% use a permissive license.


## 12.2 Code you write ----

# - If you want a permissive license so others may use your code with minimal
#   restrictions, use the MIT license with `usethis::use_mit_license()`.

# - If you want a copyleft license, so that all derivatives and bundles
#   of your code are also open source, choose the GPLv3 license with
#   `usethis::use_gpl_license()`.

# - If your package primarily contains data, not code, and you want
#   minimal restrictions, choose the CC0 license with `usethis::use_cc0_license()`.
#   Or choose the CC BY license with `usethis::use_ccby_license()` for more attribution.

# - Use `usethis::use_proprietary_license()` but note that you can't publish
#   such packages on CRAN.


### 12.2.1 Key files ----

# Three key files record your licensing decision:

# 1) Every license sets the `License` field in your `DESCRIPTION` file.
#    It contains the name of the license in a machine-readable form so that
#   `R CMD check` and CRAN can detect and verify it.
#   It comes in four main forms:

#   a) A name and version specification, e.g. `GPL (>= 2)` or `Apache License (== 2.0)`.

#   b) A standard abbreviation like `GPL-2`, `LGPL-2.1`, `Artistic-2.0`.

#   c) A name of a license "template" and a file containing specific variables
#     like `MIT + file LICENSE`, where the `LICENSE` file contains two fields:
#     - the year
#     - the copyright holder

#   d) A pointer to the full text of a non-standard license, `file LICENSE`.


# 2) The `LICENSE` file.

# 3) The `LICENSE.md` file.

# `LICENSE.note`is used when you have bundled your code with that written
# by other people.


### 12.2.2 More licenses for code ----

# - `usethis::use_apache_license()`: Includes an explicit patent grant.
#   Some organizations care about protection from patent claims.

# - `usethis::use_lgpl_license()`: The LGPL allows you to bundle 
#   LGPL code using any license for larger work.

# - `usethis::use_gpl_license()` The GPL has two major versions, GPLv2
#   and GPLv3, which are not compatible, meaning you cannot bundle
#   them in the same project.
#   To avoid this problem, license your package as GPL >= 2 or GPL >= 3
#   so that future versions of the GPL license apply to your code.

# - `usethis::use_agpl_license()`: The AGPL defines distribution to include
#   providing a service over a network, so that if you use AGPL code to provide
#   a web service, all bundled code must also be open-sourced.
#   Many companies expressly forbid the use of AGPL software.

# Use https://choosealicense.com


### 12.2.3 Licenses for data ----

# If you release a package that primarily contains data, use one of two
# Creative Commons licenses:

# - `usethis::use_cc0_license()`: Permissive license for data.

# - `usethis::use_ccby_license()`: Requires attribution when someone uses your data


### 12.2.4 Re-licensing ----

# Changing your license after the fact requires the permission of all copyright
# holders, meaning everyone who has contributed a non-trivial amount of your code
# has to consent.


## 12.3 Code given to you ----

# When someone contributes code to your package using a pull request or similar,
# you can assume that the author is happy for their code to use your license.

# This is explicitly stated in the GitHub terms of service.

# Nonetheless, the author retains the copyright of their code, 
# meaning you can't change the license without their permission.

# If you want to retain the ability to change the license, you need an
# explicit "contributor license agreement", or CLA,
# where the author explicitly reassigns the copyright.

# This is important for dual open-source/commercial projects.

# In the "tidyverse", all code contributors are asked to include
# a bullet in `NEWS.md` with their GitHub username, and
# all contributors are being thanked in release announcements.

# Only core developers are added to the `DESCRIPTION` file.


## 12.4 Code you bundle ----

# Three common reasons to bundle your code with that written by others are:

# 1) You include someone's CSS or JS library to create a beautiful
#   webpage or HTML widgets for R Shiny.

# 2) You provide an R wrapper for a simple C or C++ library
#    (You would directly link to a complex C/C++ library)

# 3) You copied a small amount of R code form another package to avoid
#   taking on another dependency.


### 12.4.1 License compatibility ----

# Before you bundle your and someone else's code into a new package,
# check that the bundled license is compatible with your license.

# You can bundle MIT licensed code in a GPL licensed package, 
# but you can *not* bundle GPL licensed code in an MIT licensed package.

# There are five main cases:

# 1) If your license and their license are the same it's OK to bundle.

# 2) If their license is MIT or BSD, it's OK to bundle.

# 3) If their code has a copyleft license, and your code has a permissive
#   license, it is NOT OK to bundle.
#   Solution: Put their code in a separate package.

# 4) If the code comes from Stack Overflow, it is licensed with the Creative 
#   Common CC BY-SA license, which is only compatible with GPLv3.

# 5) Do some research on how to make licenses compatible.



### 12.4.2 How to include ----

# Preserve all existing licenses and copyright statements.

# - If you include a fragment of another project, put it in its own file
#   that also contains any copyright statements and license description 
#   at the top.

# - If you include multiple files, put it in its own directory, with a `LICENSE`
#   file in the top-level directory.

# Include some metadata in the`Authors@R` tag.
# Use `role = "cph"` to declare that the author is a copyright holder,
# with a `comment` describing the author's role.

# To submit to CRAN, a `LICENSE.note` file needs to describe 
# the overall license of the package.

# For example, the "diffviewer" package bundles six JavaScript libraries
# together, all of which use a permissive license.
# The `DESCRIPTION` file of the "diffviewer" package lists all copyright 
# holders, and the `LICENSE.note` describes their licenses.


## 12.5 Code yo use ----

# All the code you write uses R, and R itself is licensed with the GPL.

# The R Foundation made it clear in 2009 that this does not mean that
# all your R code must always be GPL licensed.

# Similarly, your own packages do not need to use a license that is
# compatible with any "tidyverse" packages you have used in your code.


# For other languages, particularly C, creating a new C executable
# almost invariably ends up copying some component of the code you use into the 
# executable.

# This can come up if your R package has compiled code and you link to it
# using the `LinkingTo` field in your `DESCRIPTION` file.

# If yo are just linking to R itself, you are free to license your own
# package as you wish, because R headers are licensed with the Lesser GPL.

# END
