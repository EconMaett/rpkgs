# Chapter 14 - Designing your test suite

library(testthat)
testthat::local_edition(3)


## 14.1 What to test ----

#   Whenever you are tempted to type something into a print statement or a
#   debugger expression, write it as a test instead.


# - Focus on testing the external interface of your functions.

# - Strive to test each behavior in one and only one test.

# - Avoid testing simple code that you are confident will work.

# - Always write a test when you discover a bug.


### 14.1.1 Test coverage ----

# The "covr" package can be used to determine which liens of your
# package source code are executed when the test suite is run.

# This is then expressed as a percentage. 

# The "covr" package serves two purposes:

# - Locally, during interactive use, use `devtools::test_coverage_active_file()`
#   and `devtools::test_coverage()` to explore the coverage of an individual file
#   or the whole package.

# - Automatic, remote use via GitHub Actions (GHA). `usethis::use_github_action("test-coverage")`
#   configures a GHA workflow that constantly monitors your test coverage.
#   Test coverage can be a helpful metric when evaluating a pull request.
#   A proposed change that is well-covered by tests less risky to merge.


## 14.2 High-level principles for testing ----

# - A test should ideally be self-sufficient and self-contained.
# - The interactive workflow is important
# - It is more important that test code is obvious
# - Interactive workflow should not "leak" into and undermine the test suite.


### 14.2.1 Self-sufficient tests ----

#   All tests should strive to be hermetic: a test should contain all of the information
#   necessary to set up, execute, and tear down its environment.
#   Tests should assume as little as possible about the outside environment ...

#   The `pkg/R/*.R` files should consist almost entirely of function definitions.
#   Any other top-level code is suspicious and should be reviewed for conversion into a funciton.

#   The `pkg/tests/testthat/test-*.R` files should consist almost entirely of
#   calls to `testthat::test_that(desc, code)`. Any other top-level code is suspicious
#   and should be considered for relocation into calls to `testthat::test_that(desc, code)` or
#   to other files that get special treatment inside an R package or from "testthat".

# Implicitly relying on objects in a test's parent environment makes
# a test suite harder to understand and maintain over time.
# consider this test file with top-level code sprinkled around it, outside
# of `testthat::test_that(desc, code)`:
dat <- data.frame(x = c("a", "b", "c"), y = c(1, 2, 3))

testthat::skip_if(condition = today_is_a_monday())

testthat::test_that(desc = "foofy() does this", code = {
  testthat::expect_equal(object = foofy(dat), expected = ...)
})

dat2 <- data.frame(x = c("x", "y", "z"), y = c(4, 5, 6))

testthat::skip_on_os(os = "windows")

testthat::test_that(desc = "foofy2() does that", code = {
  testthat::expect_snapshot(foofy2(dat, dat2))
})

# It is highly recommended to relocate all file-scoped logic to either
# a narrower scope or to a broader scope.

# A narrower scope, i.e. inlining everything inside `testthat::test_that(desc, code)`
# calls looks like this:
testthat::test_that(desc = "foofy() does this", code = {
  testthat::skip_if(condition = today_is_a_monday())
  
  dat <- data.frame(x = c("a", "b", "c", y = c(1, 2, 3)))
  
  testthat::expect_equal(object = foofy(dat), ...)
})

testthat::test_that(desc = "foofy() does that", code = {
  testthat::skip_if(condition = today_is_a_monday())
  testthat::skip_on_os(os = "windows")
  
  dat <- data.frame(x = c("a", "b", "c"), y = c(1, 2, 3))
  dat2 <- data.frame(x = c("x", "y", "z"), y = c(4, 5, 6))
  
  testthat::expect_snapshot(foofy(dat, dat2))
})


### 14.2.2 Self-contained tests ----

# Each `testthat::test_that(desc, code)` test has its own execution environment,
# which makes it somewhat self-contained.

# For example, an R object you create inside a test does not exist after
# the test exits:
exists("thingy")
# FALSE

testthat::test_that(desc = "thingy exists", code = {
  thingy <- "thingy"
  testthat::expect_true(object = exists(thingy))
})
# Test passed

exists("thingy")
# FALSE

# The `thingy` object lives and dies within the confines of `testthat::test_that(desc, code)`.
# However, "testthat" does not know how to cleanup after actions that affect other
# aspects of the R landscape:
# - The filesystem. creating and deleting files, changing the working directory.
# - The search path `library()` and `attach()`.
# - Global options, like `options()` and `par()`, and environment variables.

# Watch how calls like `library()`, `options()`, and `Sys.setenv()` have a persistent
# effect *after* a test, even when they are executed inside `testthat::test_that()`.
grep(pattern = "jsonlite", x = search(), value = TRUE)
# character(0)

getOption("opt_whatever")
# NULL

Sys.getenv("envvar_whatever")
# ""

testthat::test_that(desc = "landscape changes leak outside the test", code = {
  library(jsonlite)
  options(opt_whatever = "whatever")
  Sys.setenv(envvar_whatever = "whatever")
  
  testthat::expect_match(object = search(), regexp = "jsonlite", all = FALSE)
  testthat::expect_equal(object = getOption("opt_whatever"), expected = "whatever")
  testthat::expect_equal(object = Sys.getenv("envvar_whatever"), expected = "whatever")
})
# Test passed

grep(pattern = "jsonlite", x = search(), value = TRUE)
# "package:jsonlite"

getOption("opt_whatever")
# "whatever"

Sys.getenv("envvar_whatever")
# "whatever"


# These changes to the landscape persist beyond the current test file, i.e.
# they carry over into all subsequent test files.

# Use the "withr" package to make temporary changes to the global state,
# because it captures the initial state and arranges the eventual 
# restoration.

# We use this in snapshot tests:
usethis::use_testthat(edition = 3)

testthat::test_that(desc = "side-by-side diffs work", code = {
  withr::local_options(width = 20) # <-- look here!
  testthat::expect_snapshot(
    waldo::compare(x = c("X", letters), y = c(letters, "X"))
  )
})


# This test requires the display width to be set at 20 columns, which
# is considerably less than the default width.

# `withr::local_options(width = 20)` sets the `width` option to 20 and,
# at the end o f the test, restores the option to its original value.

# "withr" is useful during interactive development:
# deferred actions are captured on the global environment and can be
# executed explicitly with `withr::deferred_run()` or implicitly
# by restarting R.


# It is recommended to always include the "withr" package in the `Suggests`
# field of your `DESCRIPTION` file if you use it in your tests.

# If you use the "withr" package inside your `pkg/R/*.R` files,
# then you should include it in the `Imports` field of your `DESCRIPTION` package.


# Call `usethis::use_package("withr", type = "Suggests")`
# or `usethis::use_package("withr", type = "Imports")`.


# The "withr" package has pre-implemented `withr::local_*()` and
# `withr::with_*()` functions that handle most of your testing needs.

# Only if no such function exists, use `withr::defer()` to schedule
# some action at the end of your test.


# Here is how you fix the problems of the previous example using the "withr" pacakge.
# Behind the scenes, the landscape changes are reversed.

testthat::test_that(desc = "withr makes landscape changes local to a test", code = {
  withr::local_package(package = "jsonlite")
  withr::local_options(opt_whatever = "whatever")
  withr::local_envvar(envvar_whatever = "whatever")
  
  testthat::expect_match(object = search(), regexp = "jsonlite", all = FALSE)
  testthat::expect_equal(object = getOption("opt_whatever"), expected = "whatever")
  testthat::expect_equal(object = Sys.getenv("envvar_whatever"), expected = "whatever")
})
# Test passed


# "testthat" leans heavily on "withr" to  make test execution environment
# as reproducible and self-contained as possible.

# In "testthat 3e", `testthat::local_reproducible_output()` is implicitly
# part of each `teestthat::test_that(desc, code)` test:

testthat::test_that(desc = "something specific happens", code = {
  testthat::local_reproducible_output() # <-- this happens implicitly in "testthat 3e"
  
  # your test code, which might be sensitive to ambient conditions, such as
  # display width or the number of supported colors
})


# `testthat::local_reproducible_output()` temporarily sets various options
# and environment variables to values favorable to testing, e.g.,
# it suppresses colored output, turns off fancy quotes, sets
# the console width, and sets `LC_COLLATE = "C"`.



### 14.2.3 Plan for test failure ----

# consider this extreme and abstract example of a test that is difficult to
# troubleshoot due to implicit dependencies on a free-range code:

# dozens or hundreds of lines of top-level code, interspersed with other tests,
# which you must read and selectively execute

testthat::test_that(desc = "f() works", code = {
  x <- function_from_some_dependency(object_with_unknown_origin)
  testthat::expect_equal(object = f(x), expected = 2.5)
})

# This test is much easier to drop in on if dependencies are invoked
# via the `::` operator, and test objects are created inline:

testthat::test_that(desc = "f() works", code = {
  useful_thing <- "..."
  x <- somePkg::someFunction(useful_thing)
  testthat::expect_equal(object = f(x), expected = 2.5)
})


# This test is self-sufficient. The code inside the curly braces `{...}`
# explicitly creates any necessary objects or conditions and makes explicit
# calls to any helper functions.

# The test does not rely on any objects or dependencies.


### 14.2.4 Repetition is OK ----

# Good production code is well-factored.
# Good test code is obvious.

# Here is a toy example to make things concrete:
testthat::test_that(desc = "multiplication works", code = {
  useful_thing <- 3
  testthat::expect_equal(object = 2 * useful_thing, expected = 6)
})
# Test passed

testthat::test_that(desc = "subtraction works", code = {
  useful_thing <- 3
  testthat::expect_equal(object = 5 - useful_thing, expected = 2)
})
# Test passed


### 14.2.5 Remove tension between interactive and automated testing ----

# Your test code will be executed in two different settings:

# - Interactive test development and maintenance includes tasks like:
#   - Initial test creation
#   - Modifying tests to adapt to change
#   - Debugging test failure

# - Automated test runs, which is accomplished with functions such as:
#   - Single file: `devtools.:test_active_file()`, `testthat::test_file()`
#   - Whole package: `devtools::test()`, `devtools::check()`


# Automated testing of the whole package takes priority.

# By default, `devtools::load_all()` does the following:

# - Simulates re-building, re-installing, and re-loading your package.

# - Makes everything in your package's namespace available, including
#   un-exported functions and objects and anything you have imported from
#   another package.

# - Attaches "testthat" with `library(testthat)`

# - Runs test helper files, i.e. executes `pkg/tests/testthat/helper.R`


## 14.3 Files relevant to testing ----

### 14.3.1 Hiding in plain sight: files below `R/` ----

# For example, the "dbplyr" package uses `dbplyr/R/testthat.R` to
# define a couple of helpers to facilitate comparisons and expectations
# involving `tbl` objects, which is used to represent database tables:

compare_tbl <- function(x, y, label = NULL, expected.label = NULL) {
  testthat::expect_equal(
    arrange(collect(x), dplyr::across(everything())),
    arrange(collect(y), dplyr::across(everything())),
    label = label,
    expected.label = expected.label
  )
}


expect_equal_tbls <- function(results, ref = NULL, ...) {
  # code that gets things ready ...
  
  for (i in seq_along(rest)) {
    compare_tbl(
      x = rest[[i]], 
      y = ref, 
      label = names(rest)[[i]], 
      expected.label = ref_name
      )
  }
  
  invisible(TRUE)
}


### 14.3.2 `pkg/tests/testthat.R` ----

# The standard `pkg/tests/testthat.R` file looks like this:

library(testthat)
# `library(pkg)`
# `testthat::test_check("pkg")`

# Do NOT edit `pkg/tests/testthat.R` since it is run during `R CMD check`,
# and therefore during `devtools::check()`.

# It is not used during `devtools::test()` and `devtools::test_active_file()`.


### 14.4.4 Testthat helper files ----

# A helper file is stored in `pkg/tests/testthat/helper-*.R`.
# Such files aim to eliminate floating code around the top-level of test files.

# If you have just one such file, call it `helper.R` and store it
# in `pkg/tests/testthat/helper.R`.

# Two simple "usethis" helpers that check that the currently active project,
# usually an ephemeral test project, has a specific file or folder:
expect_proj_file <- function(...) testthat::expect_true(object = file_exists(proj_path(...)))
expect_proj_dir <- function(...) expect_true(dir_exists(proj_path(...)))

# A helper file is also a good location for setup code that is needed 
# for its side effects.

# `pkg/tests/testthat/helper.R` is the appropriate place for an API-wrapping
# package to authenticate the testing credentials.


### 14.3.4 Testthat setup files ----

# "Testthat" has one more special file type: setup files, defined as any
# file below `test/testthat/` that begins with `setup`

# If you have just one such file, call it `setup.R` and store it in
# `pkg/tests/testthat/setup.R`.

# The difference between a `helper.R` and a `setup.R` file is:
# - `setup.R` is not executed by `devtools::load_all()`
# - `setup.R` contains the corresponding teardown code

# Your setup needs to be reversed after test execution, so the teardown-code
# in `setup.R` should include an artificial environment, `testthat::teardown_env()` that
# exists as a handle to use in `withr::defer()` and `withr::local_*()`
# or `withr::with_*()`.


# An example for a `setup.R` file from the "reprex" package, where we turn off 
# clipboard and HTML preview functionality during testing:
op <- options(reprex.clipboard = FALSE, reprex.html_preview = FALSE)

withr::defer(expr = options(op), envir = testthat::teardown_env())


# Since we are just modifying options here, we can be even more concise and
# use the pre-built function `withr::local_options()` and pass `testthat::teardown_env()`
# as the `.local_envir`:
withr::local_options(
  .new = list(reprex.clipboard = FALSE, reprex.html_preview = FALSE),
  .local_envir = testthat::teardown_env()
)


### 14.3.5 Files ignored by "testthat" ----

# The "testthat" package only automatically executes files where these are both true:

# - File is a direct child of `pkg/tests/testthat/`

# - File name starts with one of these prefixes:
#   - `helper`
#   - `setup`
#   - `test`



### 14.3.6 Storing test data ----

# You might want a sub-directory that holds test-data.
# A good place is `pkg/tests/testthat/fixtures/`,
# with the files `make-useful-things.R`,
# and `useful_thing1.rds`, `useful_thing2.rds`.

# Then, in your tests, use `testthat::test_path()` to build
# a robust file-path to such files:
testthat::test_that(desc = "foofy() does this", code = {
  useful_thing <- readRDS(file = testthat::test_path("fixtures", "useful_thign1.rds"))
  # ...
})


# `testthat::test_path()` produces the correct path in the two important 
# modes of test execution:

# - Interactive test development and maintenance, when your working directory
#   is set to the top-level of the package.

# - Automated testing, where the working directory is set
#   to something below `pkg/tests/`


### 14.3.7 Where to write files during testing ----

# **You should only write files inside the session temp directory**.

# NEVER write into your package's `pkg/tests/` directory.

# A high level of file system discipline eliminates various testing bugs
#and will make your CRAN submission run more smoothly.

# This test is from the "roxygen2" package and demonstrates everything we recommend:

testthat::test_that(desc = "can read from file name with utf-8 path", code = {
  path <- withr::local_tempfile(
    pattern = "Universit\u00e0-", 
    lines = c("#' @include foo.R", NULL)
    )
  testthat::expect_equal(object = find_includes(path), "foo.R")
})

# `withr::local_tempfile()` creates a file within the session temp directory
# whose lifetime is tied ot the "local" environment - here the execution
# environment of an individual test.

# It is a wrapper around `base::tempfile()` and passes, e.g., the `pattern`
# argument through, so you have some control over the file name.

# You can optionally provide `lines` to populate the file with at creation time
# and you can write to the file in all the usual ways in subsequent steps.

# With no special effort on your part, the temporary file is deleted
# at the end of your test.


# Sometimes you need more control over the file names
# Use `withr::local_tempdir()` to create a self-deleting temporary
# directory and write intentionally-named files inside this directory.


# Instead of `withr::defer()`, you might use `base::on.exit()`, but this
# requires you capture the original state and write the restoration code yourself.

# You also need to always set `base::on.exit(..., add = TRUE)` if there is 
# *any* change a second `base::on.exit()` call could be added in the unit test.
# You also want to default to `after = FALSE`.

# END