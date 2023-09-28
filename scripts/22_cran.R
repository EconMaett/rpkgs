# Chapter 22 - Releasing to CRAN ----

# The function
usethis::use_release_issue()
# will create a checklist that opens a GitHub issue
# containing a list of todo's.

# This checklist is constantly evolving and is responsive to 
# a few characteristics of your package.

# Remember the following advice:

#   If it hurts, do it more often. - Martin Fowler

# This means you should call
devtools::check()
# often.


## 22.1 Decide the release type ----

# When you call 
usethis::use_release_issue()
# you will be asked which type of release you intend to make
#   Setiting active project to '/Users/matth/rrr/usethis'
# Current version is 2.1.6.9000.
# what should the release version be? (0 to exit)

# 1: major --> 3.0.0
# 2: minor --> 2.2.0
# 3: patch --> 2.1.7

# Selection:


## 22.2 Initial CRAN release: Special considerations ----

# Every new package receives a higher level of scrutiny from CRAN.

# In addition to the usual automated checks, the new packages are
# also reviewed by a human referee, which introduces some amount of
# subjectivity and randomness.

# The community maintains a list of common "gotchas" for new packages.

# If your package is not yet on CRAN, the checklist begins with
# a special section that reflects this recent collective wisdom.

# Attending to these checklist items has dramatically improved our team's
# success rate for initial submissions.

# First release:

# - Use
usethis::use_news_md()

# - Use
usethis::use_cran_comments()

# - Update (aspirational) install instructions in `README`

# - Proofread the `Title:` and `Description:`

# - Check that all exported functions have `@returns` and `@examples` roxygen tags

# - Check that `Authors@R:` includes a copyright holder (role 'cph')

# - Check licensing of included files

# - Review https://github.com/DavisVaughan/extrachecks

# If you don't already have a `NEWS.md` file, you are encouraged to create
# one now with 
usethis::use_news_md()

# You will want this file eventually and this anticipates the fact that the
# description of your eventual GitHub release is drawn from `NEWS.md`

usethis::use_cran_comments()
# initiates a file to hold submission comments for yur package.

# It is very barebones at first and reads e.g.:
## R CMD check results

# 0 errors | 0 warnings | 1 note

# * This is a new release.



### 22.2.1 CRAN policies ----

# The official home of CRAN policy is
# https://cran.r-project.org/web/packages/policies.html.

# It is not practical to read this document.

# The GitHub repository `eddelbuettel/crp` monitors the CRAN Repository
# Policy by tracking the evolution of the underlying files in the surce
# of the CRAN website.

# Therefore the commit history of that repository makes policy
# changes much easier to navigate.

# You may follow the "CRAN Policy Watch Mastodon account", which
# toots whenever a change is detected.


## 22.3 Keeping up with change ----

# The main checklist items for a release of a package that
# is already on CRAN includes:

# - Check current CRAN check results

# - Check if any deprecation process should be advanced

# - Polish your `NEWS` file

# - Call
urlchecker::url_check()

# - Call
devtools::build_readme()


## 22.4 Double `R CMD check`ing ----

# The following is meant as a last-minute, final reminder to double-
# check that all is still well:

# - Call
devtools::check(remote = TRUE, manual = TRUE)
# This happens on your primary development machine, presumably with
# the current version of R, and with some extra checks that are usually
# turned off to make day-to-day development faster.


# - Call
devtools::check_win_devel()
# This sends your package off to be checked with CRAN's win-builder service,
# agianst the lates development verision of R, a.k.a r-devel.

# You should receive an e-mail within about 30 minutes with a link
# to the check results.

# It is a good idea to check your package with r-devel,
# because base R and `R CMD check` are constantly evolving.

# Checking with r-devel is required by CRAN policy and will be done
# as part of CRAN's incoming checks.


# When running `R CMD check` for a CRAN submission, you have to address
# any problems that show up:

# - You must fix all `ERROR`s and `WARNING`s. A package that contains
#   any errors or warnings is not accepted by CRAN.


# - Eliminate as many `NOTE`s as possible. It is always easier to fix
#   your `NOTE`s than to persuade CRAN that they are OK.


# - If you can't eliminate a `NOTE`, list it in `cran-comments.md` and
#   explain why you think it is spurious.

#   Note that there will always be one `NOTE` when you first submit your
#   package. This reminds CRAN that this is a new submission that
#   demands some extra checks.
#   You can't eliminate this `NOTE` so just mention in `cran-comments.md`
#   that this is your first submission.


### 22.4.1 CRAN check flavors and relative services ----

# CRAN runs `R CMD check` on all contributed packages upon submission
# and on a regular basis, on multiple platforms or what they call "flavors".

# You can see CRAN's current check flavors at
# https://cran.r-project.org/web/checks/check_flavors.html

# They are combinations of:

# - Operating system and CPU: 
#   Windows, macOOS (x86_64, arm64), Linux (various distributions)
# - R version: r-devel, r-release, r-oldrel
# - C, C++, FORTRAN compilers
# - Locale, in the sense of the `LC_CTYPE` environment variable.
#   This is about which human language is in use and character encoding.


# There are community- and CRAN-maintained resources where you can test
# your package with flavors of these tests:

# - GitHub Actions (GHA) is the primary means of testing packages
#   on multiple flavors.


# - R-hub builder (R-hub) is a service supported by the R Consortium
#   where package developers can submit their package for checks
#   that replicate various CRAN check flavors.

#   You can use R-hub via a web interface (https://builder.r-hub.io)
#   or, as recommended, through the "rhub" package.
rhub::check_for_cran()
# is a good option for a typical CRAN package and similar to the
# GHA workflow configured by
usethis::use_github_action("check-standard")

# Unlike GHA, R-hub currently does not cover macOS, only Windows and Linux.

# "rhub" also helps you access some of the more exotic check flavors
# and offers specialized checks relevant to packages with compiled code,
# such as 
rhub::check_with_sanitizers()


# - macOS builder is a service maintained by the CRAN personnel who build
#   the macOS binaries for CRAN packages.
#   This is a new addition to the list of checks packages with 
#   "the same setup and available as the CRAN M1 build machine".

# You can submit your package using the web interface
# https://mac.r-project.org/macbuilder/submit.html
# or with
devtools::check_mac_release()



## 22.5 Reverse dependency checks ----

revdepcheck::revdep_check(num_workers = 4)

# At a high-level, checking your reverse dependencies ("revdeps")
# breaks down into:

# - Form a list of your reverse dependencies. These are cRAN packages
#   that list your package in their `Depends`, `Imports`, `Suggests`,
#   or `LinkingTo` fields.


# - Run `R CMD check` on each one.


# - Make sure you haven't broken someone else's package with the
#   planned changes in your package.


# All of your reverse dependency tooling is concentrated in the "revdepcheck"
# package https://revdepcheck.r-lib.org/

# At the time of writing, the "revdepcheck" package is not on CRAN.

# You can install it from GitHub via
devtools::install_github("r-lib/revdepcheck")

# or 
pak::pak("r-lib/revdepcheck")

# Do this when you are ready to do revdep checks for the first time:
usethis::use_revdep()

# This does some on-time setup in your package's `.gitignore`
# and `.Rbuildignore` files.

# Revdep checkign will create some large folders below
# `pkg/revdep/`, so you want to configure these ignore files.

# You will also see this reminder to actually perform revdep checks with
revdepcheck::revdep_check(num_workers = 4)

# This runs `R CMD check` on all of your reverse dependencies,
# with our recommendation to use 4 parallel workers to speed things along.


# To minimize false positives, `revdepcheck::revdep_check()`
# runs `R CMD check` twice per revdep.

# Once with the released version of your package currently on
# CRAN and again with the local development version,
# i.e. with your release candidate.

# The "tidyverse" team uses
revdepcheck::cloud_check()
# which runs the checks in the cloud, massively in parallel, making it 
# possible to run revdep checks for packages like "testthat"
# with over 10,000 revdeps in just a few hours.


# At the time of writing, `revdepcheck::cloud_check()` is only
# available fro package maintainers at Posit.


# IN addition to interactive messages, the revdep check results
# are written to the `pkg/revdep/` folder:

# - `pkg/revdep/README.md` is a high-level summary aimed at maintainers.
#   The file name and Markdown format create a nice landing page for
#   the `pkg/revdep/` folder on GitHub.

# - `pkg/revdep/problems.md` This lists the revdeps that appear to be
#   broken by your release candidate.

# - `pkg/revdep/failures.md` This lists the revdeps that could not be checked
#   because of an installation failure.

# - `pkg/revdep/cran.md` This is a high-level summary aimed at CRAN.
#   Copy and paste this into `cran-comments.md`.

# - Other files and folders, such as `checks.noindex`, `data.sqlite`,
#   and `library.noindex` are for "revdepcheck"s internal use.



## 22.6 Update comments for CRAN ----

# Update `cran-comments`

# When you are ready to submit your package to CRAN, call
devtools::submit_cran()

# This incorporates the contents of `cran-comments.md`
# when it uploads the submission.


## 22.7 The submission process ----

# You sill call 
usethis::use_version("minor") # or "patch" or "major"
devtools::submit_cran()

# Teh call to 
devtools::submit_cran()
# is a convenience function that wraps up a few steps:

# - It creates the package bundle with
pkgbuild::build(manual = TRUE)
# Which calls `R CMD build`

# - It posts the resulting `*.tar.gz` file to CRAN's official submission
#   form https://cran.r-project.org/submit.html, populating your
#   name and email from `DESCRIPTION` and your submission comments from
#   `cran-comments.md`.

# - It confirms that the submission was successful and reminds you to
#   check your email for the confirmation link.

# - It writes submission details to a local `CRAN-SUBMISSION` file,
#   wich lrecords the package version, SHA, and time of submission.
#   This ifnormationis later used by 
usethis::use_github_release()
#   to create a GitHub release once your package has been accepted.
#   `CRAN-SUBMISSION` is added to `.Rbuildignore`.


# If your package is rejected, fix the problems and re-run
devtools::check()

# Increase the patch version of your package.

# Add a "Re-submission" section at the top of `cran-comments.md`.
# This should identify that the package is a re-submission, and list the
# changes you made

# Run 
devtools::submit_cran()
# again to re-submit the package.


## 22.9 Celebrating success ----

# Once you have recieved an email that your package was accepted
# for distribution by CRAN, 

# git push your changes

# call
usethis::use_github_release()


# Call
usethis::use_dev_version()


# git push your changes


# END 