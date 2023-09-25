# Chapter 15 - Advanced testing techniques ----

library(testthat)
testthat::local_edition(3)
# Setting global deferred event(s)
# i These will be run:
#   * Automatically, when the R session ends.
#   * On demand, if you call `withr::deferred_run()`
# i Use `withr::deferred_clear()` to clear them without executing.


## 15.1 Test fixtures -----

# When it is not practical to make your test entirely self-sufficient,
# prefer making the necessary object, logic, or conditions available in
# a structured and explicit way.

# This is called a *test fixture*.

#   A test fixture is something used to consistently test some item,
#   device, or piece of software.


# There are three approaches to this:

# - Put repeated code in a constructor-type helper function.
#   Memoise it if the construction is very slow.

# - If the repeated code has side-effects, write a custom
#   `withr::local_*()` function to clean any changes to the
#   environment after execution.

# - Only if the two approaches described above are too cumbersome,
#   create a static file and load it.


### 15.1.1 Create `useful_thing`s with a helper function ----

# If creating `useful_things` does take some lines of code but not
# too much time and memory, create a helper function:
new_useful_thing <- function() {
  # your code to create a `useful_thing`
}

# and call that helper in the tests:
testthat::test_that(desc = "foofy() does this", code = {
  useful_thing1 <- new_useful_thing()
  testthat::expect_equal(object = foofy(useful_thing1, x = "this"), expected = EXPECTED_FOOFY_OUTPUT)
})

testthat::test_that(desc = "foofy() does that", code = {
  useful_thing2 <- new_useful_thing()
  testthat::expect_equal(object = foofy(useful_thing2, x = "that"), expected = EXPECTED_FOOFY_OUTPUT)
})

# But where should the new helper function `new_useful_thing()`
# be defined?

# Test helpers could be defined inside of:

# - `pkg/R/utils.R`

# - `pkg/tests/testthat/helper.R`.

# Both options ensure that the functions are loaded with a call to
# `devtools::load_all()`.


# It is possible that you want to use `new_useful_thing()`
# in the documentation or the vignette, in which case
# it is better to store it under `pkg/R/*.R`, 
# give it its own file, document it, export it, 
# and use it freely in both documentation *and* tests.


### 15.1.2 Create (and destroy) a "local" `useful_thing` ---

# Before, `useful_thing` was a regular R object that was
# automatically cleaned-up after the end of each test.

# But it is possible that the creation of `useful_thing` has
# side-effects that change the environment,
# like a change on the local file system, on a remote source,
# on the R session options, on environment variables, etc.

# In that case you need to crate a `useful_thing` and ensure
# you clean up afterwards.

# Instead of a simple `new_useful_thing()` constructor,
# we write a customized function in the style of "withr"'s
# `withr::local_*()` functions:
local_useful_thing <- function(..., env = parent.frame()) {
  # your code to create a `useful_thing`
  withr::defer(
    # your code to clean up after a `useful_thing`
    envir = env
  )
}

# And use it in tests like this:
testthat::test_that(desc = "foofy() does this", code = {
  useful_thing1 <- local_useful_thing()
  testthat::expect_equal(object = foofy(useful_thing1, x = "this"), expected = EXPECTED_FOOFY_OUTPUT)
})

testthat::test_that(desc = "foofy() does that", code = {
  useful_thing2 <- local_useful_thing()
  testthat::expect_equal(object = foofy(useful_thing2, x = "that"), expected = EXPECTED_FOOFY_OUTPUT)
})

# Note that `base::parent.frame()` can access the environments
# in the function call stack.
base::parent.frame()

# Where should you define the `local_useful_thing()` helper?

# The same advice as before applies.



### 15.1.3 Store a concrete `useful_thing` persistently ----

# If a `useful_thing` is costly to create in terms of time or memory,
# do not re-create it for every test run.

# Create it once, store it as a static fixture, and load it when needed:
testthat::test_that(desc = "foofy() does this", code = {
  useful_thing1 <- readRDS(file = testthat::test_path("fixtures", "useful_thing1.rds"))
  testthat::expect_equal(object = foofy(useful_thing1, x = "this"), expected = EXPECTED_FOOFY_OUTPUT)
})

testthat::test_that(desc = "foofy() does that", code = {
  useful_thing2 <- readRDS(file = testthat::test_path("fixtures", "useful_thing2.rds"))
  testthat::expect_equal(object = foofy(useful_thing2, x = "that"), expected = EXPECTED_FOOFY_OUTPUT)
})


# You need a directory `pkg/tests/testthat/fixtures`
# that includes:
# - `pkg/tests/testthat/fixtures/make-useful-things.R`
# - `pkg/tests/testthat/fixtures/useful_thing1.rds`
# - `pkg/tests/testthat/fixtures/useful_thing2.rds`


## 15.2 Building your own testing tools ----

### 15.2.1 Helper defined inside a test ----

# Consider this hypothetical test for the `stringr::str_trunc()` function:
testthat::test_that(desc = "truncations work for all sides", code = {
  testthat::expect_equal(
    object = stringr::str_trunc(string = "This string is moderately long", width = 20, side = "right"), 
    expected = "This string is mo..."
    )
  
  testthat::expect_equal(
    object = stringr::str_trunc(string = "This string is moderately long", width = 20, side = "left"),
    expected = "...s moderately long"
  )
  
  testthat::expect_equal(
    object = stringr::str_trunc(string = "This string is moderately long", width = 20, side = "center"),
    expected = "This stri...ely long"
  )
})
# Test passed

# There is a lot of repetition, which increases the chance of copy/paste errors
# and makes it tiring to read.

# Sometimes you want to create a hyper-local helper, *inside the test*.

testthat::test_that(desc = "truncations work for all sides", code = {
  
  trunc <- function(direction) stringr::str_trunc(
    string = "This string is moderately long", 
    width = 20, 
    side = direction
    )
  
  testthat::expect_equal(object = trunc("right"), expected = "This string is mo...")
  testthat::expect_equal(object = trunc("left"), expected = "...s moderately long")
  testthat::expect_equal(object = trunc("center"), expected = "This stri...ely long")
})
# Test passed


### 15.2.2 Custom expectations ----

# Here are two simple cutsom expectations from "usethis":
expect_usethis_error <- function(...) {
  testthat::expect_error(object = ..., class = "usethis_error")
}

expect_proj_file <- function(...) {
  testthat::expect_true(object = file_exists(proj_path(...)))
}

# It can be handy to know that "testthat" makes specific information 
# available when it is running:

# - The environment variable `TESTTHAT` is set to `"true"`.
#   `testthat::is_testing()` is a shortcut:
is_testing <- function() {
  Sys.getenv("TESTTHAT")
}

# - The package-under-test is available as the environment variable
#   `TESTTHAT_PKG` and `testthat::testing_package()` is a shortcut:
testing_package <- function() {
  Sys.getenv("TESTTHAT_PKG")
}

# If you want to use these functions without taking a run-time
# dependency on the "testthat" package, just copy the
# source of these functions directly into your package.



## 15.3 When testing gets hard ----

### 15.3.1 Skipping a test ----

# Reasons to skip a test are:
# - You do not have the necessary credentials
# - You do not have an internet connection
# - You work on a different platform


#### 15.3.1.1 `testthat::skip()` ----

# We create a custom skipper called `skip_if_no_api()` with
# `testthat::skip()`:
skip_if_no_api <- function() {
  if (ap_unavailable()) {
    testthat::skip(message = "API not available")
  }
}

testthat::test_that(desc = "foo api returns bar when given baz", code = {
  skip_if_no_api()
  # ...
})


# `skip_if_no_api()` is another example of a test helper function.

# `testthat::skip()` and the associated reasons are reported inline
# as tests are executed and are also indicated in the summary created
# by `devtools::test()`.



#### 15.3.1.2 Built-in `testthat::skip_*()` functions ----

# Here are some examples of the most useful `testthat::skip_*()` functions:

testthat::test_that(desc = "foo api returns bar when given baz", code = {
  testthat::skip_if(condition = api_unavailable(), message = "API not available")
  # ...
})


testthat::test_that(desc = "foo api returns barr when given baz", code = {
  testthat::skip_if_not(condition = api_available(), message = "API not available")
  # ...
})


testthat::skip_if_not_installed(pkg = "sp")
testthat::skip_if_not_installed(pkg = "stringi", minimum_version = "1.2.2")


testthat::skip_if_offline()
testthat::skip_on_cran()
testthat::skip_on_os(os = "windows")



#### 15.3.1.3 Dangers of skipping ----

# Remember that if you automatically skip too many tests you fool
# yourself into believing that all your tests passed.



### 15.3.2 Mocking ----

# The practice known as mocking is when we replace something that is
# complicated or unreliable or out of our control with something simpler,
# that is fully within our control.

# Usually we are mocking an external service such as a REST API,
# or a function that reports something about session state, such
# whether the session is interactive.


# The classic application of mocking is when you create a package
# that forms a wrapper around an external API.

# To test your functions, you would need to make a live call to that API
# and get a response.

# It is common for such APIs to require authentication and to have
# occasional downtime.

# In that case, it is more productive to *pretend* to call the API.

# In case you need mocking to build a wrapper around an API,
# there are packages that help you like:
# - "mockery"
# - "mockr"
# - "httptest"
# - "httptest2"
# - "webfakes"


# At some point in the future, the "testthat" package will re-introduce
# some mocking capabilities.

# Version v3.1.7 has two new experimental functions:
# - `testthat::with_mocked_bindings()`
# - `testthat::local_mocked_bindings()`


### 15.3.3 Secrets ----

# Check out the "Wrapping APIs" vignette in the "httr2" package,
# which offers substantial support for secret management.


## 15.4 Special considerations for CRAN packages ----


# CRAN runs `R CMD check` on all contributed packages, both
# upon submission and on a regular basis after acceptance.

# This check includes, but is not limited to, your "testthat" tests.

# When a package runs afoul of the CRAN Repository Policy,
# it is often the test suite that is the culprit.


### 15.4.1 Skip a test ----

# If a specific test is inappropriate to be run by CRNA,
# include `testthat::skip_on_cran()` at the very start:
testthat::test_that(desc = "some long-running thing works", code = {
  testthat::skip_on_cran()
  # test code that takes a long time to run
})

# Under the hood, `testthat::skip_on_cran()` consults the
# `NOT_CRAN` environment variable.

# If the environment variable `NOT_CRAN` is defined to be `"true"`,
# the test is not run.

# The environment variable `NOT_CRAN` is set by "devtools" and
# "testthat", allowing those tests to run in environments where you 
# expect success and where you can tolerate and troubleshoot occasional failure.


# In particular, the GitHub Actions workflows we recommend **will**
# run tests with the environment variable `NOT_CRAN = "true"`.


### 15.4.2 Speed ----

# If your tests need more than a minute to run in total, use 
# `testthat::skip_on_cran()`.


### 15.4.3 Reproducibility ----

# Be careful not to test things that are likely to be variable on
# CRAN machines.

# It is very risky to test how long something takes (because CRAN
# machines are heavily loaded) or to test parallel code (
# because CRAN runs multiple package tests in parallel, multiple cores
# will not always be available).

# Numerical precision can also vary across platforms, so use 
# `testthat::expect_equal()` instead of `testthat::expect_identical()`.


### 15.4.4 Flaky tests ----

# A classic example for flaky tests is any test that accesses
# a website or web API.

# Given that any web resource around the world will experience 
# occasional downtime, it is best not to let such tests run on CRAN.

# The CRAN Repository Policy states that:

#   Packages which use Internet resources should fail gracefully with
#   an informative message if the resource is not available or has changed
#   (and not give a check warning nor error).


# Recall that snapshot tests, by default, are also skipped by CRAN.

# You typically use snapshot tests to monitor how various informational
# messages look.

# Slight changes in message formatting are something you want to be
# alerted to, but they do not indicate a major defect in your package.

# This is the motivation for the default `testthat::skip_on_cran()`
# behavior in snapshot tests.



### 15.4.5 Process and file system hygiene ----

# It is recommended to only write into the "session temp directory"
# and to clean up after yourself.

# This practice makes your test suite more maintainable
# and predictable.

# The CRAN Repository Policy states that:

#   Packages should not write in the user's home file space (including
#   clipboards), nor anywhere else on the file system apart from the R
#   session's temporary directory (or during installation in the location
#   pointed to by TMPDIR: and such usage should be cleaned up)....
#   Limited exceptions may be allowed in interactive sessions if the package
#   obtains information from the user.


# Similarly, you should make an effort to be hygienic with respect to
# any processes you launch:

#   Packages should not start external software (such as PDF viewers or
#   browsers) during examples or tests unless that specific instance
#   of software is explicitly closed afterwards.

# It is best to turn off any clipboard functionality
# in your tests, as the clipboard is considered part of the 
# user's home file space and, on Linux, can launch external processes.

# END