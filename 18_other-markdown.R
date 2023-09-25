# Chapter 18 - Other markdown files ----

# There are two additional files that are conventionally
# used to provide some package-level documentation.

# They are important because they are featured on both the
# CRAN landing page and the "pkgdown" website for the package.

# - `README.md`, describes what the package does.
#   This file is essential for GitHub.

# - `NEWS.md`, which describes how the package has changed over time.



## 18.1 `README.md` ----

# The goal of the `README.md` file is to answer the following
# questions about your package:

# - Why should I use it?

# - How do I use it?

# - How do I get it?



### 18.1.1 `REAMDE.Rmd` and `README.md` ----

# It is recommended to write `README` in Markdown, i.e.
# as `README.md`. This will be rendered as HTML and displayed
# on:

# - The repository homepage on GitHub.

# - On the CRAN landing page.

# - On the homepage of your "pkgdown" website.

# Use 
usethis::use_readme_rmd()
# This creates a template `README.Rmd` and adds it to `.Rbuildignore`,
# since only the `.README.md` should be included in the package bundle.

# The template `README.Rmd` looks like this:
# ---
# output: github_document
# ---

# <!-- README.md is generated from README.Rmd. Please edit that file -->

# ```{r, include = FALSE}
# knitr::opts_chunk$set(
#   collapse = TRUE,
#   comment = "#>",
#   fig.path = "man/figures/README-",
#   out.width = "100%"
# )
# ```

# somepackage

# <!-- badges: start -->

# <!-- badges: end -->

# The goal of somepackage is to ...


## Installation

# You can install the development version of somepackage from [GitHub](https://github.com/) with:

# ``` r
# install.packages("devtools")
# devtools::install_github("jane/somepackage")
# ```


## Example

# This is a basic example which shows you how to solve a common problem:

# ```{r examle}
# library(somepackage)
## basic exmaple code
# ```

# What is special about using `README.Rmd` instead of just `README.md`?
# You can include R chunks like so:

# ```{r cars}
# summary(cars)
# ```

# You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date.
# Use `devtools::build_readme()` for this.

# You can also embed plots, for example:

# ```{r pressure, echo = FALSE}
# plot(pressure)
# ```

# In that case, don't forget to commit and push the resulting figure files,
# so they display on GitHub and CRAN.


# This starter `README.Rmd` does the following:

# - I renders to GitHub-flavored Markdown.

# -It includes a comment to remind you to edit `README.Rmd`, NOT `README.md`.

# - It sets up the recommended "knitr" options, including saving images to
#   `pkg/man/figures/README-` which ensures that they are included in your
#   built package.
#   This is important so that your `README` works when displayed by CRAN.

# - It sets up a place for future badges, such as results from automatic
#   continuous integration checks.
#   Examples of functions that insert development badges are:
usethis::use_cran_badge()
# reports the current version of your package on CRAN.

usethis::use_coverage()
# reports test coverage

use_github_actions()
# and friends report the `R CMD check` status of your development package.

# - It includes placeholders where you should provide code for
#   package installation and for some basic usage.

# - It reminds you of the key facts about maintaining your `README.


# You will need to remember to re-render `REAMDE.Rmd` periodically
# with
devtools::build_readme()
# This is guaranteed to render `README.Rmd` against the current source 
# code of your package.


# The "devtools" ecosystem tries to help you keep `README.Rmd` up-to-date
# in two ways:

# - If your package is also a Git repo, use `usethis::use_readme_rmd()`
#   automatically adds the following pre-commit hook:
#!/bin/bash
# if [[ README.Rmd -nt README.md ]]; then
#   echo "README.md is out of date; please re-knit README.Rmd"
#   exit 1
# fi

# This prevents a `git commit` if `README.Rmd` is more recently
# modified than `README.md`.

# You could override this hook with `git commit --no-verify`.

# Note that Git commit hooks are not
# stored in your repository, so this hook needs to be
# added to any fresh clone.

# You could re-run `usethis::use_readme_rmd()` and discard the changes
# to `README.Rmd`.


# - The release checklist is placed by
usethis::use_release_issue()
# includes a reminder to call
devtools::build_readme()



## 18.2 `NEWS` ----

# The `NEWS` file is aimed at existing users and should list 
# all the changes in each release that a user might want to learn
# about.


# A `NEWS.md` file is pleasant to read on GitHub, your "pkgdown"
# website, and is reachable from your package's CRAN landing page.

# Call
usethis::use_news_md() 
# to initiate the `NEWS.md` file.

# There are some conventions to organizing a `NEWS.md` file:

# - Use a top-level heading for each version: e.g. `# somepackage 1.0.0`.
#   The most recent version needs to go at the top.


# - Each change should be part of a bullet-ed list. Only if you have a lot
#   of changes may you use sub-headings `## Major changes`, `## Bug fixes`, etc.


# - If an item is related to an issue on GitHub, include the issue number
#   in parentheses, e.g. `(#10)`.
#   If an item is related to a pull request, include the pull request number
#   and the author, e.g. `(#101, @hadley)`.
#   We omit the username if the contributor is recorded in the `DESCRIPTION`.

# END