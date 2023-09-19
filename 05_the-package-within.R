# Chapter 05 - The package within ----

# This chapter also describes how to create a small toy package, just
# like the first.

# We start with a data analysis script and isolate and extract reusable data
# from the script and put it into an R package, and then use that package in a
# simplified script.

# The section headers incorporate the NATO phonetic alphabet and have no specific meaning.

# 5.1 Alfa: a script that works ----

# We consider `data-cleaning.R`, a fictional data analysis script for a group
# that collects reports from people who went for a swim:

#   Where did you swim and how hot was it outside?

# The data comes in a CSV file, called `swim.csv`
library(tidyverse)

csv_text <- "
name,where,temp
Adam,beach,95
Bess,coast,91
Cora,seashore,28
Dale,beach,85
Evan,seaside,31
"

swim <- read_csv(file = csv_text)
swim

write_csv(swim, file = "swim.csv")

# The script `data-cleaning.R` begins by reading `swim.csv` into a data frame
infile <- "swim.csv"
(dat <- read.csv(file = infile))

# Then all observations are classified as using American ("US") or
# British English ("UK"), based on the word chosen to describe the sandy place where
# ocean and land meet.

# The `where` column is used to build the new `english` column.
dat$english[dat$where == "beach"] <- "US"
dat$english[dat$where == "coast"] <- "US"
dat$english[dat$where == "seashore"] <- "UK"
dat$english[dat$where == "seaside"] <- "UK"

# sadly, the temperatures are reported as either Fahrenheit or Celsius.
# We guess that Americans report temperatures in Fahrenheit and convert those
# observations to Celsius.
dat$temp[dat$english == "US"] <- (dat$temp[dat$english == "US"] - 32) * 5 / 9
dat

# Finally, this cleaner data is written back out to a CSV file.
# We like to capture a timestamp in the file when we do this:
now <- Sys.time()
timestamp <- format(now, "%Y-%B-%d_%H-%M-%S")
(outfile <- paste0(timestamp, "_", sub(pattern = "(.*)([.]csv$)", replacement = "\\1_clean\\2", x = infile)))
write.csv(dat, file = outfile, quote = FALSE, row.names = FALSE)


## 5.2 Bravo: a better script that works ----

# The package that lurks within the original script is still hard to see.
# It is obscured by some suboptimal coding practices,
# such as the use of repetitive copy/paste-style code and the mixing of code and data.

# A good first step is to refactor this code, isolating as much data and logic
# as possible in proper objects and functions.

# We also introduce some add-on packages.
# The tidyverse is ideal for data wrangling.
library(tidyverse)

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

lookup_table <- tribble(
  ~where, ~english,
  "beach", "US",
  "coast", "US",
  "seashore", "UK",
  "seaside", "UK"
)

dat <- dat |>
  left_join(y = lookup_table, by = join_by(where))

f_to_c <- function(x) (x - 32) * 5 / 9

dat <- dat |>
  mutate(temp = if_else(condition = english == "US", true = f_to_c(temp), false = temp))

dat

now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub(pattern = "(.*)([.]csv$)", replacement = "\\1_clean\\2", x = infile))
}

write_csv(dat, file = outfile_path(infile))

# The key changes are:

# - We use tidyverse functions (from the "readr" and "dplyr" packages)
#   We have to start with `library(tidyverse)`.

# - The map between different "beach" words is isolated in a lookup table,
#   letting us creating the `english` column in one go with `left_join()`.
#   This makes the code less repetitive and easier to understand.

# - We created new helper functions, `f_to_c()`, `timestamp()`, and `outfile_path()`
#   that hold the isolated logic for converting temperatures and forming the timestamped
#   output file.

# It is now easier to recognize the reusable bits of the script, i.e., the bits
# that have nothing to do with the specific input file `swim.csv`.

# This sort of refactoring happens naturally when you are creating your own
# package.


## 5.3 Charlie: a separate file for helper functions ----

# The next step is to move reusable data and logic out of the analysis
# script and into separate files.

# We create a separate CSV-file for the lookup table:
lookup_text <- "
where,english
beach,US
coast,US
seashore,UK
seaside,UK
"

lookup_csv <- read_csv(file = lookup_text)

write_csv(lookup_csv, file = "beach-lookup-table.csv")

# Then we create a new file called `cleaning-helpers.R` that contains the helper functions we
# have created previously:
library(tidyverse)

localize_beach <- function(dat) {
  lookup_table <- read_csv(
    file = "beach-lookup-table.csv",
    col_types = cols(where = "c", english = "c")
  )
  left_join(x = dat, y = lookup_table, by = join_by(where))
}

f_to_c <- function(x) (x - 32) * 5 / 9

celsify_temp <- function(dat) {
  mutate(.data = dat, temp = if_else(condition = english == "US", true = f_to_c(temp), false = temp))
}

now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub(pattern = "(.*)([.]csv$)", replacement = "\\1_clean\\2", x = infile))
}

# We have added high-level helper functions `localize_beach()` and
# `celsify_temp()` to the pre-existing helpers `f_to_c()`, `timestamp()`,
# and `outfile_path()`.

# The new version of the data cleaning script is much shorter:
library(tidyverse)
source(file = "cleaning-helpers.R")

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

(dat <- dat |>
  localize_beach() |>
  celsify_temp())

write_csv(dat, file = outfile_path(infile))

# notice that the script is shorter and easier to read and modify,
# because all the repetitive clutter has been removed.

# Read more about such design decisions on https://design.tidyverse.org/.


## 5.4 Delta: a failed attempt at making a package ----

# This first attempt at creating a package will result in failure,
# but it is helpful to show some common missteps and what happens behind
# the scenes.

# The simplest steps you might take in an attempt to convert the file `cleaning-helpers.R`
# into a proper package:

# - Use `usethis::create_package(path = "path/to/delta")` to scaffold a new R package,
#   with the name "delta". -> This is a good first step!

# - Copy `cleaning-helpers.R` into the new package, specifically, to `R/cleaning-helpers.R`.
#   While this is morally correct, it is mechanically wrong.

# - Copy `beach-lookup-table.csv` into the new package. But where? If we try
#   the top-level of the source package, this will not end well. Shipping data files
#   is covered in Chapter 7.

# - Install this package using `devtools::install()` or Ctrl + Shift + B.
#   This actually works.

usethis::create_package(path = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/delta")
# Copy the file `cleaning-helpers.R` into the `delta/R` directory, and
# copy the file `beach-lookup-table.csv` into the `delta/` directory.
devtools::install(pkg = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/delta")


# The next version of the script should look like this:
library(tidyverse)
library(delta)

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat |>
  localize_beach() |>
  celsify_temp()

write_csv(dat, outfile_path(infile))

# The only change from the previous script is that
# `source(file = "cleaning-helpers.R")` has been replaced by `library(delta)`.

# But if you try to run the script `data-cleaning_v4.R`, you will get an error
# when you try to access the helper functions form the `delta` package.

# In contrast to `source()`ing a file of helper functions, a call to `library(delta)`
# does not dump its functions into the global workspace.

# By default, functions in a package are for internal use only.
dat |>
  delta:::localize_beach() |>
  delta:::celsify_temp()
# Would therefore work, since the `:::` operator lets you access functions that
# are for internal use only. This is implemented in `data-cleaning_v5.R`.

# Instead of using the `:::` operator, you may export the functions
# `localize_beach()`, `celsify_temp()`, and `outfile_path()` so that external
# users may call them.

# In the `devtools` workflow, we achieve this by putting `@export` in the
# special roxygen comment above each function.
# This namespace management is covered in chapter 11.

# We add `#' @export` above all three functions in the file `delta/R/cleaning-helpers.R`
# and restart R, run `devtools::document()` to regenerate the `NAMESPACE` file,
# and re-install the delta package with `devtools::install()`.
delta_dir <- "C:/Users/matth/OneDrive/Dokumente/R-pkgs/delta"
devtools::install(pkg = delta_dir)

library(tidyverse)
library(delta)

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat |>
  localize_beach() |>
  celsify_temp()

write_csv(dat, outfile_path(infile))

# Unfortunately, this only works if the working directory is set to the top-level
# of the source package. This is implemented in `data-cleaning_v6.R`:
library(tidyverse)

orig_wd <- getwd()

infile <- "swim.csv"

dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat

setwd(dir = delta_dir)
devtools::install()
library(delta)

dat <- dat |>
  delta::localize_beach() |>
  delta::celsify_temp()

write_csv(dat, paste0(orig_wd, "/", delta::outfile_path(infile)))

setwd(dir = orig_wd)
# This works but is very cumbersome.

# If we don't change the working directory to the source code of the "delta" package,
# the lookup table consulted inside the function `delta::localize_beach()` cannot be found.

# Chapter 7 covers the inclusion of data in packages.

# We can confirm that `devtools::load_all()` works fine too.
devtools::load_all(path = delta_dir)
# The funcitons can now be accessed with the `::` operator like `delta::fun()`.

# But `devtools::check()`, which runs `R CMD check`, will fail:
devtools::check(pkg = delta_dir)
# We get one error:
# Checking whether package 'delta' can be installed ... ERROR
# See below...
# Install failure
# Error in library(tidyverse) : there is no package called 'tidyverse'
# Error: unable to load R code in package 'delta'
# Execution halted
# Error: lazy loading failed for package 'delta'

# This error occurs when the strictness for `R CMD check` meets the very first line
# of `R/cleaning-helpers.R`: `library(tidyverse)`.

# Dependencies must be declared in the `DESCRIPTION` files.

# To review, simply copying `cleaning-helpers.R` to `delta/R/cleaning-helpers.R`
# failed for the following reasons:
# - It does not account for exported vs. non-exported functions.
# - The CSV-file holding the lookup table cannot be found in the installed package.
# - It does not declare the dependency on other add-on packages.


## 5.5 Echo: a working package ----
echo_dir <- "C:/Users/matth/OneDrive/Dokumente/R-pkgs/echo"
usethis::create_package(path = echo_dir)

# We simply include the code to create the lookup table inside of `R/cleaning-helpers.R`
lookup_table <- dplyr::tribble(
  ~where, ~english,
  "beach", "US",
  "coast", "US",
  "seashore", "UK",
  "seaside", "UK"
)
# This is okay for small, internal, static data.

# Al calls for the tidyverse have now been qualified by the specific package that
# acutally provides the function, such as `dplyr::tribble()`,
# `dplyr::left_join()` and `dplyr::mutate()`.

# It is a good rule to never depend on the tidyverse meta-package inside
# of one's package.

# The `library(tidyverse)` call is gone and instead we declare the use
# of `dplyr` in the `Imports` field of `DESCRIPTION`
# We can do this with `usethis::use_package("dplyr")`.

# All of the user-facing functions have the `#' @export` tag in their
# roxygen documentation, meaning that `devtools::document()` adds these
# functions correctly to the `NAMESPACE` file.

# Note that `f_to_c()` is only used internally, inside `celsify_temp()`.

# This version of the package can be installed, used, AND it passes the
# `R CMD CHECK` with one warning and one note:
echo_dir <- "C:/Users/matth/OneDrive/Dokumente/R-pkgs/echo"
devtools::install(pkg = echo_dir)
library(echo)

# Exported functions:
echo::celsify_temp()
echo::localize_beach()
echo::outfile_path()

# Not exported, internal objects:
echo:::f_to_c()
echo:::lookup_table
echo:::now
echo:::timestamp()
echo:::.__NAMESPACE__.
echo:::.__NAMESPACE__.$dynlibs
echo:::.__NAMESPACE__.$exports
echo:::.__NAMESPACE__.$exports$celsify_temp
echo:::.__NAMESPACE__.$exports$localize_beach
echo:::.__NAMESPACE__.$exports$outfile_path
echo:::.__S3MethodsTable__.
echo:::.packageName # "echo"


# To see the `R CMD check` output, use
devtools::check(pkg = echo_dir)
# We get 1 warning and 2 notes

# The WARNING states that we did not include documentation entries for
# the three exported functions.

# The first NOTE states that we did not use a standard license specification
# in our `DESCRIPTION FILE`

# We can fix this with `usethis::use_mit_license()`


# The second NOTE states that the function `celsify_temp()` does not show
# a visible binding for the global variables 'english' and 'temp'.

# This is a peculiarity of using `dplyr` and unquoted variable names inside
# of a package, where the use of bare variable names like `english` and `temp`
# looks suspicious.

# You can add either of these lines to any file below `echo/R/` to eliminate this note:

# option 1 (then you should also put the package "utils" in `Imports`)
utils::globalVariables(names = c("english", "temp"))

# option 2
english <- temp <- NULL
# This is a shortcut for writing
english <- NULL
temp <- NULL

# This is similar to the base R case where instead of
# writing directly `df$english[dv$name == "beach"] <- "US`,
# we would first declare `df$english <- NULL`.

# After making the changes in `echo/R/cleaning-helpers.R`,
# and calling `devtools::document()`, and checking that `devtools::check()`
# does not show the warning anymore, we can try again:
echo_dir <- "C:/Users/matth/OneDrive/Dokumente/R-pkgs/echo"
devtools::install(pkg = echo_dir)
library(echo)
devtools::check(pkg = echo_dir)
# The approach with utils::globalVariables() works too, but the check
# will complain again.
# The NOTE reads
# checking dependencies in R code ... NOTE
# namespace in Imports field not imported from 'utils'
#   All declared imports should be used.


# 5.6 Foxtrot: buld time vs. run time ----

# The `echo` package works, which is great, but group members notice something
# odd about the timestamps:
Sys.time()

echo::outfile_path(infile = "INFILE.csv")

# The datetime in the timestamped filename does not reflec tthe time reported
# by the system.

# In fact, the timestamp enver changes at all.

# Recall how we form the file-path for output files:
now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub("(.*)([. ]csv$"), "\\1_clean\\2", infile)
}

# We have caputred `now <- Sys.time()` outside of the definition of `outfile_path()`.
# In the context of a package, this is devastating since `now <- Sys.time()`
# is executed **when the package is built** and then never again.

# The code *inside  your functions* is run whenever it is called, but the code
# outside of the functions is only called when the package is being built.

# There are two ways to fix this:

# always timestamp as "now"
outfile_path <- function(infile) {
  ts <- timestamp(Sys.time())
  paste0(ts, "_", sub("(.*)([. ]csv$"), "\\1_clean\\2", infile)
}

# or allow the user to provide a time, but default to "now"
outfile_path <- function(infile, time = Sys.time()) {
  ts <- timestamp(time)
  paste0(ts, "_", sub("(.*)([.]csv$)", "\\1_clean\\2", infile))
}

usethis::create_package(path = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/foxtrot")

# We have to declare `usethis::use_mit_license()` and `usethis::use_package("dplyr")`
# then call `devtools::check()` and see that we get zero errors and zero notes.

devtools::install(pkg = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/foxtrot")
library(foxtrot)

Sys.time()
foxtrot::outfile_path("INFILE.csv")
# Now the two timestamps are identical!


## 5.7 Golf: side effects ----

# The tiemstamps now reflect the current time, but there is still a
# source of possible errors.
# Since we format() Sys.time() with the qualifier "%B", this adds the full
# name of the current month, which may be different depending on the
# language settings of the machine.
# The same applies to the local time zone.


# It is safer to always form timestamps with respect to a fixed locale
# and time zone, presumably the non-geographic choices represented
# by "Computer World", meaning `LC_TIME = "C"` and `tz = "UTC"`.

# You can force a certain locale via `Sys.setlocale8)` and force
# a certain time zone by setting the TZ environment varialbe.

# UTC stands for Coordinated Universal time.

# Here is our first attempt to improve the function `golf::timestamp()`:
timestamp <- function(time = Sys.time()) {
  Sys.setlocale(category = "LC_TIME", locale = "C")
  Sys.setenv(TZ = "UTC")
  format(time, "%Y-%B-%d_%H-%M-%S")
}

# Note that we do not need to change the language since Computer Time
# is English by default.

# However, there is one issue:
# Using functions like `Sys.setlocale()` and `Sys.setenv()`
# makes persistent changes to the user's R session, which is very unwelcome.

# The "withr" package allows us to keep the changes local to the timestamp() function:

timestamp <- function(time = Sys.time()) {
  withr::local_locale(c("LC_TIME" = "C"))
  withr::local_timezone("UTC")
  format(time, "%Y-%B-%d_%H-%M-%S")
}

# The time zone can also be changed inside of format.POSIXct():
timestamp <- function(time = Sys.time()) {
  withr::local_locale(c("LC_TIME" = "C"))
  format(time, "%Y-%B-%d_%H-%M-%S", tz = "UTC")
}

# We can also put the format() call inside of withr::with_locale():
timestamp <- function(time = Sys.time()) {
  withr::with_locale(
    new = c("LC_TIME" = "C"),
    code = format(time, "%Y-%B-%d_%H-%M-%S", tz = "UTC")
  )
}


# It is best to keep the scope of such changes as narrow as possible.
# The `tz` argument inside of `format.POSIXct()` is the most surgical
# way to deal with the timezone.

# We make the temporary locale modification with the "withr" package,
# that provides a flexible toolkit for temporary state changes.

# This, and `base::on.exit()` are discussed in Chapter 6.
# You need to include "withr" in the DESCRIPTION.
usethis::create_package(path = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/golf")

# After making the changes, and calling `usethis::use_mit_license()`,
# `usethis::use_package("dplyr")`, `usethis::use_package("withr")`,
# and `devtools::document()`, we call
devtools::install(pkg = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/golf")
library(golf)

golf:::timestamp
Sys.time()
golf:::timestamp()
golf::outfile_path("INFILE.csv")

# END
