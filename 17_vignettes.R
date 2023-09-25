# Chapter 17 - Vignettes ----

# A vignette is a long-form guide to your package.

# The vignette format is to show a workflow that 
# solves that problem, start to finish.


# You can see all the vignettes associated with 
# your installed packages with
utils::browseVignettes()

# To limit that to a particular package, specify the package's name:
utils::browseVignettes(package = "tidyr")

# Read a specific vignette with
utils::vignette(topic = "rectangle", package = "tidyr")


# It is most convenient to read vignettes from a package's website,
# the topic of chapter 19.

# A "pkgdown" website presents all of the documentation of a package.

# Vignettes are written with R Markdown.


## 17.1 Workflow for writing a vignette ----

# Run
usethis::use_vignette(name = "my-vignette")
# to do the following:

# 1. Create a `pkg/vignettes/` directory.

# 2. Add the necessary dependencies to the `DESCRIPTION` file, i.e.
#   add the "knitr" package to the `VignetteBuilder` field and add
#   both "knitr" and "rmarkdown" to the `Suggests` field.

# 3. Drafts a vignette, `pkg/vignettes/my-vignette.Rmd`.

# 4. Adds some patterns to `.gitignore`, to ensure that files
#   created as a side-effect of previewing your vignettes are kept out of
#   source control.


# This draft document has the key elements of any R Markdown vignette.

# You can call
usethis::use_vignette()
# to create your second and all subsequent vignettes;
# it will just skip any setup that ahas already been done.


# Once you have the draft vignette, the workflow is as follows:

# 1. Start adding prose and code chunks to the vignette.
#   Use `devtools::load_all()` as needed.

# 2. Render the entire vignette periodically.
#   This requires some attention, because unlike tests,
#   the default vignette is rendered using the currently installed
#   version of your package, not with the current source package,
#   thanks to the initial call to `library(yourpackage)`.

#   One option is to properly install your current source package
#   with `devtools::install()` or Ctrl + Shift + B in RStudio.
#   Then click the "Knit" button or use Ctrl + Shift + K.

#   Another option is using `devtools::build_rmd("vignettes/my-vignette.Rmd")`
#   to render the vignette.
#   This builds your vignette against a temporarily installed
#   development version of your package.



## 17.2 Metadata ----

# The first few liens of a vignette contain important metadata.
# The default template contains the following information:
# ---
# title: "Vignette Title"
# output: rmarkdown::html_vignette
# vignette: >
#   %\VignetteIndexEntry{Vignette Title}
#   %\VignetteEngine{knitr::rmarkdown}
#   %\VignetteEncoding{UTF-8}
# ---

# This metadata is written in YAML (Yet Another Markdown Language),
# a format designed to be both human and computer readable.

# YAML frontmatter is a common feature of R Markdown files.

# The syntax is like that of the `DESCRIPTION` file,
# where each line consists of a field name, a colon, then the value of the field
# field: value

# The one special YAML feature we are using here is `>`.
# It indicates that the following liens of text are plain
# and should not use any special YAML features.


# The default vignette template has these fields:

# - `title`: this is the title that appears in the vignette.
#   If you change it, make the same change to `VignetteIndexEntry{}`.

# - `output`: This specifies the output format. The options include
#   html, pdf, slideshows, etc., but `rmarkdown::html_vignette`
#   needs to be used here.
?rmarkdown::html_vignette


# - `vignette`:  A block of special metadata needed by R.
#   The legacy of LaTeX vignettes is visible here:
#   The metadata looks like LaTeX comments.
#   The only entry you might need to modify is the 
#   `\VignetteIndexEntry{}`.
#   This controls how the vignette appears in the vignette index
#   and needs to match the `title` field.
#   The other two lines tell R to use `knitr` to process the file and
#   that the file is encoded in UTF-8, the only encoding you should
#   ever use for a vignette.


# It is not recommended to use the following fields:

# - `author`: Do NOT use this field unless the vignette was written 
#   by someone other than the person credited as the package author.

# - `date`: If you manage the `date` field with `Sys.date()` it
#   will reflect when the vignette was built, i.e. when the package bundle
#   was created. Omit this field.


# The draft vignette includes two R chunks. The first configures
# the preferred way of displaying code output:
# ```{r, include = FALSE}
# knitr::opts_chunk$set(
#   collapse = TRUE,
#   comment = "#>"
# )
# ```

# The second code chunk attaches the package the vignette belongs to:
# ```{r setup}
# library(yourpackage)
# ```



## 17.3 Advice on writing vignettes ----

# Helpful resources for writing vignettes include:

# - "Creating passionate users" or "Serious Pony" by Kathy Sierra.

# - "Style: Lessons in Clarity and Grace" by Joseph M. Williams
#   and Joseph Bizup.



### 17.4.1 Diagrams ----

# If you include a lot of graphics, your package size might
# grow too large for a successful CRAN submission.



### 17.3.2 Links ----

# There is now way to link to the help topics or from one vignette
# to another.

# This is why "pkgdown" websites are so useful.
vignette("linking", package = "pkgdown")

# Automatic links are generated for functions in the host package,
# namespace-qualified functions in another package, vignettes, and more.

# The two most important examples of automatically linked text are:

# - `some_function()`: Auto-linked to the documentation of `some_function()`,
#   within the "pkgdown" website of its host package.
#   Note the use of backticks and the trailing parentheses.

# - `vignette("fascinating-topit")`: Auto-linked to the "fascinating-topic"
#   article within the "pkgdown" website of its host package.
#   Note the use of backticks.



### 17.3.3 File-paths ----

# It may be necessary to refer to another file from a vignette:

# - A figure created by code evaluated in the vignette.
#   By default, in the `.Rmd` workflow, this works by itself.
#   Such figures are automatically embedded into the `.html` files
#   using the data URIs.
vignette("extending-ggplot2", package = "ggplot")
# generates a few figures in evaluated code chunks.


# - An external file that could be useful to users or elsewhere
#   in the package. Put this file in `pkg/inst/` or in `pkg/inst/extdata`,
#   and refer to it with `system.file()` or `fs::path_package()`.
vignette("sf2", package = "sf")
# shows an example of this:
# ```{r}
# library(sf)
# fname <- system.file("shype/nc.shp", package = "sf")
# fname
# nc <- st_read(fname)
# ```


# - An external file whose utility is limited to your vignettes:
#   Put it alongside the vignette source files in `pkg/vignettes/`
#   and refer to it with a file path relative to `pkg/vignettes/`.
# An example from 
vignette("tidy-data", package = "tidyr")
# is found at `vignettes/tidy_data.Rmd` and includes a chunk
# that reads a file located at `vignettes/weather.csv`:
# ```{r}
# weather <- as_tibble(read.csv("weather.csv", stringsAsFactors = FALSE))
# weather
# ```


# - An external graphics file: put it in `pkg/vignettes/`,
#   refer to it with a file path that is relative to `pkg/vignettes/`
#   and use `knitr::include_graphics()` inside a code chunk.
# An example from
vignette("sheet-geometry", package = "readxl")
# includes the code chunk:
# ```{r out.width = '70%', echo = FALSE}
# knitr::include_graphics("img/geometry.png")
# ```


### 17.3.4 How many vignettes? ----

# For a simple package, one vignette is sufficient.
# In that case, call this vignette `somepackage.Rmd` if your
# package is called "somepackage".



### 17.3.5 Scientific publication ----

# If you have implemented a statistical algorithm, you might
# want to describe its details in a vignette so that a user
# of your package may understand what is going on
# under the hood.

# You may then submit your vignette to the Journal of Statistical
# Software, or The R Journal.

# Both journals are electronic only and peer-reviewed.

# Comments from reviewers are very helpful for improving your
# vignette.


# If you want to provide something very lightweight so folks can
# easily cite your package, consider the
# Journal of Open Source Software (JOSS).

# This journal has a speedy submission and review process,
# and it's where "Welcome to the Tidyverse" was published.



## 17.4 Special considerations for vignette code ----

# Any package used in a vignette must be a formally declared
# dependency, i.e. it must be listed in the
# `Imports` or `Suggests` field of the `DESCRIPTION` file.


# There are many possible reasons why it might not be possible
# to evaluate all the code in your vignette, such 
# as on CRAN's machines or in CI/CD.

# These include the usual suspects:
# - lack of authentication credentials
# - long-running code
# - code that is vulnerable to intermittent failure.


# You can control evaluation in an `.Rmd` document with the
# `eval` option of a code chunk, which is `TRUE` by default.

# The value of `eval` can be the result of evaluating
# an expression, such as:

# - `eval = requireNamespace("somedependency")`

# - `eval = !identical(Sys.getenv("SOME_THING_YOU_NEED"), "")`

# - `eval = file.exists("credentials-you-need")`


# The `eval` can be set for an individual code chunk, 
# but it often makes more sense to set it globally.

# In that case, set
# `knitr::opts_chunk$set(eval = FALSE)`
# in an early, hidden chunk to make `eval = FALSE` the default
# for the remainder of the vignette.

# You can still override with `eval = TRUE` in individual chunks.


# In vignettes, we use the `eval` option similar to the
# `#' @examplesIf` roxygen comment in documentation.


# If the code can only be run under certain conditions,
# you must check for those pre-conditions programmatically
# at runtime and use the result to set the `eval` option.


# The first few code chunks in a vignette from the "googlesheets4"
# package, which is a wrapper around the Google Sheets API.

# The vignette code can only be run if we are able to decrypt
# a toke  that allwos us to authenticate with the API.

# Taht fact is recorded in `can_decrypt`, which is then set as the
# vignette-wide default for `eval`.

# ```{ r setup, include = FALSE}
# can_decrypt <- gargle:::secret_can_decrypt("googlesheets4")
# knitr::opts_chunk$set(
#   collapse = TRUE,
#   comment = "#>",
#   error = TRUE,
#   eval = can_decrypt
# )
# ```

# ```{r eval = !can_decrypt, echo = FALSE, comment = NA}
# message("No token available. Code chunks will not be evaluated.")
# ```

# ```{r index-auth, include = FALSE}
# googlesheets4::gs4_auth_docs()
# ```

# ```{r}
# library(googlesheets4)
# ```


# Notice the second code chunk uses `eval = !can_decrypt`,
# which prints an explanatory message for anyone who
# builds the vignette without the necessary credentials.



# Use `include = FALSE` for code chunks that should be evaluated
# but do not need to be seen in the rendered vignette.

# The `echo` option controls whether code is printed, in 
# addition to output.

# `error = TRUE` allows you to purposefully execute
# code that could throw an error.

# The error will appear in the vignette, just
# as it would for the user, but it won't prevent the
# execution of the rest of your vignette's code,
# nor will it cause `R CMD check` to fail.



### 17.4. 1 Article instead of vignette ----

# If you do NOT want any of your code to be executed on CRAN,
# you should write an Article instead of a Vignette.


# An Article is a vignette-like `.Rmd` document that is created
# by "pkgdown", but that appears only in the website.


# An article will be less accessible than a vignette for users
# with limited internet access.

# But for a package that wraps around a web API, it is often the
# only solution.


# Draft a new article with
usethis::use_article()
# to ensure that the article will be `.Rbuildignore`d.


# A reason to use articles is if you want to show
# how your package interacts with other packages that
# you did not want to depend on formally.


# Another reason to use an article is when you want to
# include a lot of graphics that might be too large
# to pass `R CMD check` and CRAN.



## 17.5 How vignettes are built and checked ----

# Note that vignettes and function documentation are built very
# differently:

# - The source of the function documentation is stored in the
#   roxygen comments `#'` above the `pkg/R/*.R` files,
#   and `devtools::document()` generates the files
#   `pkg/man/*.Rd`.


# - Vignettes are different because the `.Rmd` source is considered
#   part of the source package and of the `R CMD build` and `R CMD check`
#   machinery.



### 17.5.1 `R CMD build` and vignettes ----

# Realize that the `pkg/vignettes/*.Rmd` source files exist only
# when a package is in source or bundled form.

# Vignettes are rendered when a source package is converted
# to a bundle via `R CMD build` or a convenience wrapper such
# as `devtools::build()`.

# The rendered `.html` files are placed in `pkg/inst/doc/*.html`,
# along with their source `pkg/inst/doc/*.Rmd`
# and extracted R code `pkg/inst/doc/*.R`.

# When a package binary is made, the `pkg/inst/doc` directory is
# promoted to a top-level `pkg/doc/` directory,
# as happens with everything below `pkg/inst/`.


# This leas to the following recommendations:

# - Active, interactive work on your vignettes:
#   Use your usual interactive `.Rmd` workflow, such as the "knit" button,
#   or `devtools:.build_rmd("vignettes/my-vignette.Rmd")` to render
#   a vignette to `.html` in the `pkg/vignettes/` directory.
#   Regard the `.html` file as a disposable preview.
#   If you initiate vignettes with
#   `usethis::use_vignette()`, this `.html` file will already be
#   `.gitignrore`d.


# - Make the current state of vignettes in development version 
#   available to the world:

#   - Offer a "pkgdown" website, preferably with automated "build and
#     deploy", such as using GitHub Actions to deploy to GitHub Pages.
#     Here are "tidyr"'s vignettes in the development version
#     (note the "dev" in the URL).

#   - Be aware that anyone who installs your package directly from
#     GitHub will need to explicitly request vignettes, e.g.,
#     with 
#     `devtools::install_github(dependencies = TRUE, build_vignettes = TRUE)`.


# - Prepare built vignettes for a CRAN submission.
#   Do not try to do this by hand or in advance.
#   Allow vignette (re-)building to happen as part of 
#   `devtools::submit_cran()` or `devtools::release()`,
#   both of which build the package.


# If you *really* need to build vignettes in the official manner
# on an *ad hoc* basis,
# use `devtools::build_vignettes()`.

# It is not recommended and you should avoid it.



### 17.5.2 `R CMD check` and vignettes ----

# `R CMD check` does some static analysis of vignette-related files.

# If your vignettes use packages that do not appear in the
# `DESCRIPTION` file, this error will be caught here.

# If files that *should* exist *don't* exist, this is caught here.


# The vignette code is then extracted into a `.R` file, 
# using the "tangle" feature of the relevant vignette engine,
# which is "knitr" in our case, and this file is run.

# The code originating form chunks marked as `eval = FALSE`
# will be commented out in this file and therefore not executed.

# The the vignettes are rebuilt from source, using the "weave"
# feature of the vignette engine, again "knitr" in our case.

# This executes all the vignette code yet again, except for 
# chunks marked `eval = FALSE`.


# END
