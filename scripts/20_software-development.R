# Chapter 20 - Software development practices

# These are some recommended best practices:

# - Use an Integrated Development Environment (IDE),
#   preferably the RStudio IDE.


# - Use Version Control. Preferably Git.


# - Use Hosted Version Control. Preferably sync your local
#   Git repositories to a hosted service, ideally GitHub.


# - Continuous Integration and Development, a.k.a. CI/CD.


## 20.1 Git and GitHub ----


# Git is a version control system that was originally built to coordinate
# the work of a global group of developers working on the Linux kernel.

# Git manages the evolution of a set of files - called a repository -
# in a structured way.

# Every R package should also be a Git repository and an RStudio project.

# You should also hook your local repository up to a remote host
# like GitHub.


### 20.1.1 Standard practice ----

# Most developers participating in the most recent Stack Overflow
# survey report using Git, while a small number uses SVN for version control

# To learn more about using Git and GitHub with RStudio and R,
# read the article "Excuse me, do you have a moment to talk about version control"?
# or the website "Happy Git and GitHub for the useR".

# Using Git and GitHub has many advantages:

# - You can take bug reports and feature requests. These conversations
#   remain accessible to others and searchable.

# - You can collaborate with others.

# - You can distribute your package with functions like
devtools::install_github("r-lib/devtools")
pak::pak("r-lib/devtools")

# - You can crate a simple website with GitHub Pages.

# - You can use Continuous Integration and Deployment or CI/CD.


## 20.2 Continuous integration (CI/CD) ----

# Continuous Integration and Deployment, or CI/CD means:

# 1. You host your source package on GitHub.
#    The hosted repository provides the formal structure for integrating
#    the work of multiple contributors.

# 2. You configure one or more development tasks to execute automatically
#    when certain events happen in the hosted repository, 
#    such as a push or pull request.
#    For an R package, you can configure automatic runs of 
#    `R CMD check` to discover breakage quickly.


### 20.2.1 GitHub Actions (GHA) ----

# The easiest way to start using Continuous Integration and Deployment (CI/CD)
# is to host your package on GitHub and use GitHUb Actions (GHA).

# Use various "usethis" functions to configure so-called GHA workflows.

# "usethis" copies workflow configuration files from `r-lib/actions`,
# which is where the "tidyverse" team maintains GHA infrastructure that
# is useful to the R community.


### 20.2.2 `R CMD check` via GHA ----

# The most important Continuous Integration task is to run
# `R CMD check`. Call
usethis::use_github_action()
# with no arguments and choose one of the suggested workflows.

# Which action od you want to add? (0 to exit)
# (See <https://github.com/r-lib/actions/tree/v2/examples> for other options)

# 1: check-standard: Run `R CMD check` on Linux, macOS, and Windows
# 2: test-coverage: Compute test coverage and report to https://about.codecov.io
# 3: pr-commands: Add /document and /style commands for pull requests

# Selection:


# `check-standard` is highly recommended. It runs `R CMD check`
# across a few combinations of operating system and R version.

# This increases your chances of quickly detecting code
# that relies on the idiosyncrasies of a specific platform,
# making the code more portable.

# After making that selection, you will see:
# Crating '.github/'
# Adding '*.html' to '.github/.gitignore'
# Creating '.github/workflows/'
# Saving 'r-lib/actions/examples/check-standard.yaml@v2' to .github/workflows/R-CMD-check.yaml'
# * Learn more at <https://github.com/r-lib/actions/blob/v2/examples/README.md>.
# Adding R-CMD-check badge to 'README.md'.

# The key things that happen here are:

# - A new GHA workflow file is written to
#   `.github/workflows/R-CMD-check.yaml`.
#   GHA workflows are specified via YAML files.
#   The message reveals the source of the YAML and gives a link
#   to learn more.

# - Some helpful additions may be made to various "ignore" files.

# - A badge reporting the `R CMD check` result is added to your README,
#   if it has been created with "usethis" and has an identifiable badge
#   "parking area".
#   Otherwise, you will be goven some text you can copy and paste.


#@ Commit these file changes and push to GitHub.

# If you visit the "Actions" section of your repository, you should
# see that a GHA workflow run has been launched.

# In due course, its success or failure will be reported there, in
# your README badge, and in your GitHub notifications.


### 20.2.3 Other uses for GHA ----

usethis::use_github_action()
# gives you access to pre-made workflows other than `R CMD check`.

# You can use it to configure any of the example workflows in 
# `r-lib/actions` by passing the workflow's name.


usethis::use_github_action("test-coverage")
# configures a workflow to track the test coverage of your package.

?usethis::use_pkgdown_github_pages
# builds your package's website and deploys the rendered site to 
# GitHub Pages

# END