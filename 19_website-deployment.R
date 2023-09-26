# Chapter 19 - Website ----

# There are multiple ways to document your package:

# - The function documentation.
# - The dataset documentation
# - Vignettes
# - The README and NEWS file.

# Ideally, you use the "pkgdown" package to create a website where
# all of the above are bundled in one place.


## 19.1 Initiate a site ----

# Assuming your package has a valid structure, "pkgdown" should be able
# to create the website for it.

# It should take no longer than five minutes!

# Simply call
usethis::use_pkgdown()
# to create the initial, minimal setup necessary:

# Here is what `usethis::use_pkgdowown()` does:

# - It creates `_pkgdown.yml`, which is the main configuration file
#   for "pkgdown".
#   In an interactive session, `_pkgdown.yml` will be opened for
#   inspection and editing.
#   But there is no immediate need to change or add anything here.

# - It adds various patterns to `.Rbuildignore`, to keep "pkgdown"-specific
#   files and directories from being included in your package bundle.

# - It adds `docs`, the default destination for a rendered site,
#   to `.gitignore`. This is harmless for those who do not use Git.
#   For those who do use Git, this opts you in to the recommended
#   lifestyle where the definitive source for your "pkgdown" site is built
#   and deployed elsewhere probably via GitHub Actions and GitHub Pages.
#   This means the website at `docs/` serves as a local preview.

pkgdown::build_site()
# is a funciton you will call repeatedly, to re-render your site
# locally.

# In an interactive session, the newly rendered site should apear
# in your default web browser.

# You can also build the site via "Addins" -> "pkdgdown" -> "Build pkgdown"
# in RStudio.

# You can look in the local `pkg/docs/` directory to see the files
# that constitute your package's website.

# To manually browse the site, open `pkg/docs/index.html` in your
# preferred browser.


# This is almost all you truly need to know about "pkgdown".
# It is a great start, and as your package ambitions grow,
# the best place to learn is the "pkgdown"-made website for the
# "pkgdwon" package itself: https://pkgdown.r-lib.org.


## 19.2 Deployment ----

# The next task is to deploy your "pkgdown" site somewhere on the web,
# so that your users can visit it.

# The path of least resistance looks like this:

# - Use Git and host your package on GitHub.

# - Use GitHub Actions (GHA) to build your website, i.e., to run
#   `pkgdown::build_site()`. GHA is a platform where you can configure
#   certain actions to happen automatically when some event happens.
#   We will use it to rebuild your website every time you push to GitHub.

# - Use GitHub Pages to serve your website, i.e., the files you see below
#   `pkg/docs/` locally.
#   GitHub Pages is a static website hosting service that creates a site
#   from files found in a GitHub repository.


# Call the function
usethis::use_pkgdown_github_pages()
# to call `usethis::use_pkgdown()` under the hood.
# It is okay if you previously called `usethis::use_pkgdown()`.

# `usethis::use_pkgdown_github_pages()` will do the following:

# - It initializes an empty, "orphan" branch in your GitHub repository,
#   called `gh-pages` (for "GitHub Pages").
#   The `gh-pages` branch will only live on GitHub.
#   There is no reason to fetch it to your local computer,
#   and it represents a separate, parallel universe from your actual package
#   source. The only files tracked in `gh-pages` are those that constitute
#   your package's website, the files you see below `pkg/docs/`.

# - It turns on GitHub Pages for your repo and tells it to serve a website
#   from the files found in the `gh-pages` branch.

# - It copies the configureation file for a GHA workflow that does 
#   "pkgdown" "build and deploy".
#   The file shows up in your package as
#   `.github/workflows/pkgdown.yaml`.
#   If necessary, some related additions are made to `.gitignore`
#   and `.Rbuildignore`.

# - It adds the URL for your site as the homepage for your GitHub repository.

# - It adds the URL for your site to the `DESCRIPTION` file and
#   to `_pkgdown.yml`.
#   The auto-linking behavior relies on your package listing its URL in these
#   two places.


# After successful execution of `usethis::use_pkgdown_github_pages()`,
# you should be able to visit the new site at the URL displayed in
# the output above.

# By default, the URL has this general form:
# https://USERNAME.github.io/REPONAME/.


## 19.3 Now what?

# For a typical package, you could stop here.

# You have created a basic "pkgdown" site and arranged for it to
# be re-built and deployed regularly.

# Everything beyond this point is "nice to have".

vignette("pkgdown", package = "pkgdown")
# is a good place to start if you want to go beyond the basic
# defaults.


## 19.4 Logo ----

# It is fun to have a pacakge logo.

# The R community has a tradition of hex stickers.

# If you want to print stickers, there is a de facto
# standard for sticker size.

# hexb.in is a reliable source for the dimensions and provides a list
# of potential vendors for printed stickers.

# The "hexSticker" package helps you create  a logo from R.

# Once you have your logo, use
usethis::use_logo()
# to place an appropriately scaled copy of the image file
# at `pkg/man/figures/logo.png` and also 
# provide a copy-pase-able markdown snippet to include your logo
# in your `README` file.

# "pkgdown" will also discover a logo placed in the standard location 
# and incorporate it into your site.


## 19.5 Reference index ----

# "pkgdown" creates a function reference in `pkg/reference/` that
# includes one page for each `.Rd` help topic in `pkg/man/`.

# This is one of the first pages you should admire on your new site.


### 19.5.1 Rendered examples ----

# "pkgdown" executes all your examples and inserts the rendered
# results.

# We find this is a fantastic improvement over just throwin the source
# code.

# This view of your exmaples can be eye-opening and often you will
# notice thigns you want to add, omit, or change.


### 19.5.2 Linking ----

# The help topics will be linked to from many locations within and,
# potentially beyond your "pkgdown" site.

# Functions put inside of square brackeds in roxygen comments like
#' I am a big fan of [thisfunction()] in my package. I
#' also have something to say about [otherpkg::otherfunction()]
#' in somebody else's package.

# On "pkgdown" sites, those square-bracketed functions become hyperlinks
# to the relevant pages in your "pkgdown" site.

# This is automatic within your package. But inbound links from *other*
# people's packages and websites require two things:

# - The `URL` field of your `DESCRIPTION` file must include the URL
#   of your "pkgdwon" site, preferably followed by the URL of your GitHub repo:
# URL: https://dplyr.tidyverse.org, https://github.com/tidyverse

# - Your `_pkgdown.yml` file must include the URL for your site:
# url: https://dplyr.tidyverse.org

# "devtools" takes care of this every chance it gets to do this sort of 
# configuration for you.


# A good resource on auto-linking in "pkgdown" is
vignette("linking", package = "pkgdown")


### 19.5.3 Index organization ----

# By default, the reference index is just an alphabetically-ordered
# list of functions.

# For packages with more than a handful of functions, it may be worthwile
# to crate the index and organize the functions into groups.

# For example, the "dplyr" package uses the folowing technique:
# https://dplyr.tidyverse.org/reference/index.html

# You achieve this by providing a `reference` field in the 
# `_pkgdown.yml` file.

# Here is a redacted excerpt from "dplyr"s `_pkgdown.yml` file:

# reference:
# - title: Data frame verbs

# - subtitle: Rows
#   desc: >
#     Verbs that principally operate on rows.
#   contents:
#   - arrange
#   - distinct
#   ...
# - subtitle: Columns
#   desc: >
#     Verbs that principally operatoe on columns.
#   contents:
#   - glimpse
#   - mutate
#   ...
# - title: Vector functions
#   desc: >
#     Unhlike other dplyr funcitons, these functions work on individual vectors
#     not on data frames.
#   contents:
#   - between
#   - case_match
#   ...
# - title: Built in datasets
#   contents: 
#   - band_members
#   - starwars
#   - storms
#   ...
# - title: Superseded
#   desc: >
#     Superseded functions have been replaced by new approaches that we
#     believe to be superior, but we don't want to force you to change until
#     you're ready, so the existing functions will stay around for several years.
#   contents:
#   - sample_frac
#   - top_n
#   ...


# Learn more by calling
?pkgdown::build_reference


## 19.6 Vignettes and articles ----

# Vignettes are long-form guides for a package.

# They offer you more control over the integration of prose and
# code and over the presentation of the code itself, e.g.
# code can be executed but not seen, seen but not executed,
# selectively skipped depending on the environment in which
# the code is run, etc.

# "pkgdown" uses the term *Articles* instead of "Vignettes*.

# The *Articles* menu lists your package's official vignettes,
# the ones that are included in the package bundled,
# and, optionally, other non-vignette articles.


### 19.6.1 Linking ----

# Vignettes can include automatic inbound links from within your
# package.

# You can refer to a vignette with an inline call like
# `vignette("some-topic")`.

# The need to specify the host package depends on the context:

# - `vignette("some-topic")`: Use this form in your own roxygen
#   comments, vignettes, and articles, to refer to a vignette in your
#   package. The host package is implied.

# - `vignette("some-topic", package = "somepackage")`: Use this form
#   to refer to a vignette in some other package. 
#   The host package must be explicit.


# Note that this shorthand does **not** work for linking to non-vignette articles.

# Since the syntax leans on the `vignette()` function,
# evaluating the code in the console would fail because R won't be
# able to find such a vignette.

# Non-vignette articles must be linked like any other URL.

# When you refer to a function in your package, in your vignettes and 
# articles, make sure to put it inside backticks and include parentheses.

# Qualify functions from other packages with their namespace:
# I am a big fan of `thisfunction()` in my package. I also have something to
# say about `otherpkg::otherfunction()` in somebody else's package.

# Remember that automatic inbound links from *other*people's packages
# and websites require that your package advertises the URL of its
# website in `DESCRIPTION` and `_pkgdown.yaml`, as configured by
usethis::use_pkgdown_github_pages()


### 19.6.2 Index organization -----

# # The default listing of articles in a package is alphabetical.

# You might want to feature the articles aimed at the typical user
# and tuck those meant for advanced users behind "More articles...".
?pkgdown::build_articles


### 19.6.3 Non-vignette articles ----

# An article is like a vignette in that it tells a story that involves
# multiple functions and is written with R Markdown.

# But it does not ship with the package bundle.

# To create a new article, call
usethis::use_article()

# The main reasons to create an article as opposed to a vignette are:

# - You want to sow how your new package works together with another package
#   that you did not want to formally depend on.
#   In vignettes and examples, you can only use packages listed in the
#   `Imports` and `Suggests` fields of your `DESCRIPTION` file.

#   A good example is the "readxl" package that includes an article
#   that shows how you can use "radxl" together with the "tidyverse".
#   The "tidyverse" meta-package is listed in 
#   the `readxl/Config/Needs/website` field of the `DESCRIPTON` file.
#   This keeps "tidyverse" outside of "readxl"'s dependencies but ensures
#   it is installed when the website is built.


# - You want to use code that requires authentication or access to
#   specific assets, tools, or secrets not available on CRAN.

#   An example is the "googledrive" package, which features
#   *no* vignettes, only non-vignette articles.


# - Content that involves a lot of graphics, which would otherwise
#   bump against CRAN's size constraints.


## 19.7 Development mode ----

# Every "pkgdown" site has a so-called *development mode*,
# that can be specified via the `development` field in the
# `_pkgdown.yml` file.

# If unspecified, the default is `mode: release`, which
# results in a single "pkgdown" site.

# Despite the name, this single site reflects the state of the current
# source package, which could be either a released state or a development state.

# Packages with a substantial user base should use "auto" development
# mode by specifying the field
# development:
#   mode: auto

# This directs "pkgdown" to generate a top-level site from the released
# version and to document the development version in a `pkg/dev/` sub-directory.

# All of the "core tidyverse" packages use "auto" development mode.

# END