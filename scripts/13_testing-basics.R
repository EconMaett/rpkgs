# Chapter 13 - Testing basics ----

# Testing ensures your code does what it should do.


## 13.1 Why is formal testing worth the trouble? ----

# Automated testing is preferable to informal, interactive tests.

# It will lead to fewer bugs and better code structure.


## 13.2 Introducing "thestthat" ----

# Test your new R package with functions from the "testthat" package.

# There are some fundamental differences between how "testthat" works
# and how testing in other languages works.

# The main difference comes from the fact that R is at heart
# a functional programming language and not an object-oriented language.

# Because R's two main object-oriented systems, S3 and S4 are based
# on generic functions, i.e., a method implements a generic function
# for objects of a specific class,
# testing approaches built around objects and methods don't make sense here.

# "testthat" 3.0.0, released in 2020-10-31, introduced the idea of an **edition**
# of "thetthat", called "tehstthat 3e".

# An edition is a bundle of behaviors that you have to explicitly choose to sue,
# allowing us to make otherwise backward incompatible changes.

# "testthat 3e" is recommended for all new packages.


## 13.3 Test mechanics and workflow ----

### 13.3.1 Initial setup ----

# To setup your package to use "thestthat", run:
usethis::use_testthat(edition = 3)

# This will:

# 1. Create a `tests/testthat/` directory.

# 2. Add "thestthat" to the `Suggests` field of your `DESCRIPTION` file
#    and specify "thestthat 3e" in the `Config/testthat/edition` field.
#   The `DESCRIPTION` file includes the fields:
#   Suggests: testthat (>= 3.0.0)
#   Config/testthat/edition: 3

# 3. Create a file `tests/testthat.R` that runs all your tests when `R CMD check` is run.
#   For a package named "pkg", the contents of `pkg/tests/testthat.R` look like:
#   `library(testthat)`
#   `library(pkg)`
#   `test_check("pkg")`

# You only need to do this initial setup once per package.

# It is safe to run `usethis::use_testthat(edition = 3)` in a package
# that already uses "thestthat".


# NEVER edit `pkg/tests/testthat.R`!!!

# It is only run during `R CMD check` (and therefore `devtools::check()`),
# but not during `devtools::check()` or `devtools::check_active_file()`.


### 13.3.2 Create a test ----

# The organisation of test files inside of `pkg/tests/testthat/*.R` should
# match the organisation of the files in `pkg/R/*.R`.

# If you have defined a function `pkg::foofy()` in `pkg/R/foofy.R`,
# the associated test should be in `pkg/tests/testthat/test-foofy.R`.

# The easiest way to implement this convention is to use the "usethis"
# helpers `usethis::use_r()` to create new `pkg/R/*.R` files
# and to use `usethis::use_test()` to create the associated
# `pkg/tests/testthat/test-*.R` file.

# `usethis::use_r("foofy")` creates and opens `pkg/R/foofy.R`
# `usethis::use_test("blarg")` creates and opens `pkg/tests/testthat/test-blarg.R`

# When determining the target file, they can deal with the presence or absence
# of the `.R` extension or the `test-` prefix.
# Therefore:
# - `usethis::use_r("foofy.R")` is equivalent to `usethis::use_r("foofy")`.
# - `usethis::use_test("test-blarg.R")` is equivalent to `usethis::use_test("blarg.R")`
#   or `usethis::use_test("blarg")`

# If the target file already exists, it is simply opened for editing.

# In RStudio, if `pkg/R/foofy.R` is the active file in your source editor,
# simply call `usethis::use_test()`.


# When `usethis::use_test()` creates a new test file, it inserts an examle
# test:
library(usethis)

testthat::test_that(desc = "multiplication works", code = {
  testthat::expect_equal(object = 2 * 2, expected = 4)
})
# Test passed


### 13.3.3 Run tests ----

# Running `devtools::load_all()` attaches "testthat".

# So after changing the `foofy()` function inside `pgk/R/foofy.R`
# with `usethis::use_r("foofy")`,
# you re-load it with `devtools::load_all()`

# You interactively explore and refine expectations and tests
# inside `pkg/tests/testthat/test-foofy.R` with 
# `usethis::use_test("foofy")`, 
# checking `testthat::expect(equal(foofy(...), EXPECTED_FOOFY_OUTPUT)`

# Alternatively, call all your test with
# `testthat::test_file("tests/testthat/test-foofy.R")`


# Bind `devtools::test_active_file()` to a keyboard shortcut in RStudio,
# like Ctrl + T.

# Use `devtools::test()` to run all tests in your package.

# Use `devtools::check()` to run `R CMD check`.

# Note that `devtools::test()` is mapped to Ctrl + Shift + T
# and `devtools::check()` is mapped to Ctrl + Shift + E

# Each failure of a test gives you the description of the test
# and its location and the reason for the failure.


### 13.4 Test organization ----

# Test files always start with the prefix `test-*.R` and live in the
# directory `pkg/tests/testthat/`.

# First we attach "stringr" and "testthat"
library(testthat)
library(stringr)
testthat::local_edition(3)

# The contents of "stringr"'s `stringr/tests/testthat/test-dup.r` are:
test_that(desc = "basic duplication works", code = {
  expect_equal(object = str_dup(string = "a", times = 3), expected = "aaa")
  expect_equal(object = str_dup(string = "abc", times = 2), expected = "abcabc")
  expect_equal(object = str_dup(string = c("a", "b"), times = 2), expected = c("aa", "bb"))
  expect_equal(object = str_dup(string = c("a", "b"), times = c(2, 3)), expected = c("aa", "bbb"))
})
# Test passed

test_that(desc = "0 duplicates equals empty string", code = {
  expect_equal(object = str_dup(string = "a", times = 0), expected = "")
  expect_equal(object = str_dup(string = c("a", "b"), times = 0), expected = rep("", 2))
})
# Test passed

test_that(desc = "uses tidyverse recycling rules", code = {
  expect_error(object = str_dup(string = 1:2, times = 1:3), class = "vctrs_error_incompatible_size")
})
# Test passed

# The file tests three types of errors:
# - "basic duplication works" tests the typical usage of `str_dup()`
# - "0 duplicates equals empty string" probes a specific edge case.
# - "uses tidyverse recycling rules" checks that malformed input results in a specific kind of error.

# Tests are organised hierarchically:
# **expectations** are grouped into **tests** which are organized in **files**:

# - A **file** holds multiple related tests. Here, the `stringr/tests/testthat/test-dup.r` file
#   has all the tests for the code in `stringr/R/dup.R`.

# - A **test** groups together multiple expectations to test the output from a simple function,
#   a range of possibilities for a single parameter from a more complicated function,
#   or tightly related functionality form across multiple functions.
#   This is why they are also called **unit** tests.
#   Create a test with `testthat::test_that(desc, code)`.

#   Since a test failure reports the description (`desc`), use natural language
#   to describe what the test does, e.g. `testthat::test_that("basic duplication", {...})`

# - An **expectation** is the atom of testing. It is the expected result of a function.
#   You can test if it has the correct value or class.
#   You can test if it produces the correct error.
#   Expectations are functions of the family `testthat::expect_*()`.


## 13.5 Expectations ----

# An expectation is the finest level of testing. It makes a binary assertion
# about whether or not an object has the expected properties.

# All expectations have this structure:
# - They start with `testthat::expect_*()`.
# - They have two arguments, `testthat::expect_*(object, expected)`
# - They throw an error if `object` and `expected` disagree.

# There are over 40 `testthat::expect_*(object, expected)` functions
# in "testthat"'s reference index.


### 13.5.1 Testing for equality ----

# `testthat::expect_equal(object, expected)` checks for equality, with
# a reasonable amount of numeric tolerance:
testthat::expect_equal(object = 10, expected = 10)
testthat::expect_equal(object = 10, expected = 10L)
testthat::expect_equal(object = 10, expected = 10 + 1e-7)
testthat::expect_equal(object = 10, expected = 11)
# Error

# To test for exact equivalence, use `testthat::expect_identical()`:
testthat::expect_equal(object = 10, expected = 10 + 1e-7)
testthat::expect_identical(object = 10, expected = 10 + 1e-7)
# Error

testthat::expect_equal(object = 2, expected = 2L)
testthat::expect_identical(object = 2, expected = 2L)
# Error


### 13.5.2 Testing errors ----

# Use `testthat::expect_error()` to check whether an expression throws an error.
# This is more important than `testthat::expect_warning()` and
# `testthat::expect_message()`.

1 / "a"
# Error : non-numeric argument to binary operator
testthat::expect_error(object = 1 / "a")

log(-1)
# Warning message: NaNs produce
testthat::expect_warning(object = log(-1))

testthat::expect_error(object = str_duq(1:2, 1:3))
# This does not fail, even tough we used `str_duq()` instead of the
# correct `stringr::str_dup()`!

# The test has passed, but for the wrong reason.
str_duq(1:2, 1:3)
# Error : could not find function "str_duq"

# Historically, the best defense against this was to assert that the
# condition message matches a certain regular expression, defined
# in the second argument, `regexp`:
testthat::expect_error(object = 1 / "a", regexp = "non-numeric argument to binary operator")
testthat::expect_warning(object = log(-1), regexp = "NaNs produced")

# This does force the typo to the surface:
testthat::expect_error(object = str_duq(1:2, 1:3), regexp = "recycle")
# Error: 
# Actual message: "could not find function \"str_duq\""


# Recent developments in the "base" and "rlang" packages make it likely
# that conditions are signaled with a *class* that provides a better basis
# for precise expectations.

# fails, error has wrong class
testthat::expect_error(object = str_duq(1:3, 1:3), class = "vctrs_error_incompatible_size")
# Error : unexpected class

# passes, error has expected class
testthat::expect_error(object = str_dup(1:2, 1:3), class = "vctrs_error_incompatible_size")


# Whenever possible, express your expected error in terms of the 
# condition's class, not its message.

# This is likely if the package you are testing signals the condition

# If the condition originates from the "base" R package, proceed with caution.

# To check for the *absence* of an error, warning, or message, use `testthat::expect_no_error()`:
testthat::expect_no_error(object = 1 / 2)

# This is equivalent to simply executing `1 / 2` inside a test,
# but the explicit expectation statement makes the code more expressive.


### 13.5.3 Snapshot tests ----

# "testthat 3e" provides snapshot tests where you record the expected
# results in a separate file.

# "testthat" alerts you when a newly computed result differs from the previously
# recorded snapshot.

# Snapshots are well suited to monitor the package's user interface,
# such as informal messages or errors.

# But you can also test complicated objects and errors.

# We illustrate snapshot tests with the "waldo" package.

# Under the hood, "testthat 3e" uses "waldo" to do the heavy lifting
# of "actual vs. expected" comparisons.

# One of "waldo"'s design goals is to present differences
# in a clear and actionable manner, as opposed to frustrating declarations.

# The formatting of output from `waldo::compare()` is well-suited for snapshot tests.

# The binary outcome of `TRUE` (actual == expected) vs. `FALSE` (actual != expected)
# is fairly easy to check and could get its own test.

# "waldo" uses different layouts for showing *diffs*.
# Here we deliberately constrain the width, to trigger a side-by-side layout:
withr::with_options(
  new = list(width = 20), 
  code = waldo::compare(x = c("X", letters), y = c(letters, "X"))
)


# The two primary inputs differ at two locations: once at the start and
# once at the end.

# This layout presents both of these, with some surrounding context, which helps
# the reader orient themselves.

# As a snapshot test this looks like this:
library(testthat)
usethis::use_testthat(edition = 3)

test_that(desc = "side-by-side diffs work", code = {
  withr::local_options(width = 20)
  expect_snapshot(
    waldo::compare(x = c("X", letters), y = c(letters, "X"))
  )
})
# Note that this only works inside of a package.

# There is always a warning upon initial snapshot creation.

# The snapshot is added to `pkg/tests/testthat/_snaps/diff.md`,
# under the heading "side-by-side diffs work".


# You can call `testthat::snapshot_review("diff")` to review changes locally
# in a Shiny app, which lets you skip or accept individual snapshots.

# If all changes are intentional and expected, go straight to
# `testthat::snapshot_accept("diff")`.

# Once you have re-synchronized your actual output and the snapshots on file,
# your tests will pass again.

# `testthat::expect_snapshot()` has a few arguments worth knowing about:

# - `cran = FALSE`: By default, snapshot tests are skipped if it looks like the
#   tests are running on CRAN's server.

# - `error = FALSE`: By default, snapshot code is *not* allowed to throw an error.
testthat::expect_snapshot(error = TRUE, str_dup(1:2, 1:3))

# - `transform`: Sometimes a snapshot contains volatile, insignificant elements
#   such as a temporary filepath or a timestamp. The `transform` argument accepts a function,
#   presumably written by you, to remove or replace such changeable text. 
#   Another use of `transform` is to scrub sensitive information from the snapshot.


# - `variant`: Sometimes snapshots reflect the ambient conditions, such as the operating
#   system or the version of R or one of your dependencies, and you need a
#   different snapshot for each variant.

# In typical usage, "testthat" will manage the snapshot files below
# `pkg/tests/testthat/_snaps/`.
# This happens when you call `testthat::snapshot_accept()`.


### 13.4.5 Shortcuts for other common patterns ----

# Several expectations can be described as "shortcuts", i.e., they streamline a pattern
# that comes up often enough to deserve its own wrapper.

# - `testthat::expect_match(object, regexp, ...)` is a shortcut that wraps
#   `base::grepl(pattern = regexp, x = object, ...)`.
#   It matches a character vector input against a regular expression `regexp`.
#   The "all" option controls whether all elements or just one element need to match.
#   Read the documentation:
?testthat::expect_match
#   Additional arguments like `ignore.case = FALSE` or `fixed = TRUE` can be passed down to `grepl()`.
string <- "Testing is fun!"

testthat::expect_match(object = string, regexp = "Testing")

# Fails, match is case-sensitive
testthat::expect_match(object = string, regexp = "testing")
# Error

# Passes, because additional argument is passed to base::grepl():
testthat::expect_match(object = string, regexp = "testing", ignore.case = TRUE)


# - `testthat::expect_length(object, n)` is a shortcut for 
#   `testthat::expect_equal(length(object), n)`.


# - `testthat::expect_setequal(x, y)` tests that every element of `x` occurs
#   in `y`, and every element of `y` occurs in `x`.
#   It will NOT ail if `x` and `y` have their elements in different order.


# - `testthat::expect_s3_class()` and `testthat::expect_s4_class()` check that
#   an object `inherit()`s from a special class.
#   `testthat::expect_type()` checks the `typeof()` an object.
model <- lm(formula = mpg ~ wt, data = mtcars)
testthat::expect_s3_class(object = model, class = "lm")
testthat::expect_s3_class(object = model, class = "glm")
# Error: `model` inherits from 'lm' not 'glm'.

# `testthat::expect_true()` and `testthat::expect_false()` are useful catchalls
# if none of the other expectations does what you need.


# Note that the legacy function `testthat::context()` is superseded now
# and its use in actively maintained code is discouraged.

# In "testthat 3e", `testthat::context()` is formally deprecated; you should remove it.

# Once you adopt an intentional, synchronized approach to the organisations below
# `pkg/R/` and `pkg/tests/testthat/`, the contextual information is in the file name,
# rendering the legacy `testthat::context()` superfluous.

# END