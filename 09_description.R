# Chapter 09 - `DESCRIPTION` ----

# `DESCRIPTION` and `NAMESPACE` are files that provide metadata about the package.

# The `DESCRIPTION` file provides overall metadata such as
# the package name or which other packages it depends on.

# `NAMESPACE` specifies which functions your package makes available to the user
# and optionally imports functions form other packages.


## 9.1 `DESCRIPTION` file ---


# RStudio and "devtools" consider any directory containing a `DESCRIPTION`
# file to be a package.

# `usethis::create_package("mypackage")` adds a bare-bones `DESCRIPTION` file.


# Customize the default content of the new `DESCRIPTION` files by setting
# the global option `usethis.description` to a named list.
usethis::edit_r_profile()

# The `DESCRIPTION` file uses a file format called "DCF", or
# "Debian Control Format".

# Each line consists of a **field** name and a "value", separated by
# a colon (`:`).
# When values span multiple lines, they need to be **indented**

# If you need to work programmatically with a `DESCRIPTION` file,
# use the "desc" package, which uses "usethis" under-the-hood.



## 9.2 `Title` and `Description`: What does your package do? ----

# - `Title` is a one line description, shown in a package listing.
#   It should be plain text (no markup), capitalized like a title, and 
#   NOT end in a period.
#   In listings it will be truncated to 65 characters.

# - `Description` is more detailed than the title and can contain multiple
#   sentences as long as they remain on one paragraph.
#   For multiple lines, no line can be wider than 80 characters.
#   Subsequent lines need to be indented with 4 spaces.

# Put the names of R packages, software, and APIs inside single quotes.
# Use acronyms in the `Description` but not in the `Title`.
# Don't include the package name in `Title`, since it is often prefixed
# with the package name.
# Do not start with "A package for ..." or "This package does...".
# -> Change this on all your repositories!


## 9.3 Author: who are you? ----

# Use the `Authors@R` field to identify the package author that should
# be contacted in case something goes wrong.

# This field is special because it contains executable R code rather than plain text.

# There are multiple ways to define the author:

# Authors@R:
utils::person(
  given = "Matthias", 
  family = "Spichiger", 
  email = "matthias.spichgiger@bluewin.ch", 
  role = c("aut", "cre"), 
  comment = c(ORCID = "0000-0003-0368-5175")
)
# "Matthias Spichiger <matthias.spichgiger@bluewin.ch> [aut, cre] (<https://orcid.org/0000-0003-0368-5175>)"

# Note that in some cultures, the family name is stated before the given name.

# For a non-person entity, use the "given" argument and fill it with
# "R Core Team" or "Posit Software, PBC" and omit the "family" argument.

# The "email" address will be posted on CRAN.
# It needs to be a personal email address.

# The "role" argument contains three letter codes for important roles:

# - `cre`: The creator or maintainer of the package.
# - `aut`: The authros who made significant contributions to the package.
# - `ctb`: contributors, those who made smaller contributions, like patches.
# - `cph`: copyright holder. Typically used for companies.
# - `fnd`: funder, people or organizations that provided financial support.

# The optional `commend` argument can include your personal ORCID identifier.
# `utils::person()` will automatically generate your URI:
# URI: https://orcid.org/0000-0003-0368-5175

# You can list multile authors by combining them within `c()`:
c(
  person("Hadley", "Wickham", email = "hadley@posit.co", role = "cre"),
  person("Jennifer", "Bryan", email = "jenny@posit.co", role = "aut"),
  person("Posit Software, PBC", role = c("cph", "fnd"))
)
# [1] "Hadley Wickham <hadley@posit.co> [cre]"
# [2] "Jennifer Bryan <jenny@posit.co> [aut]" 
# [3] "Posit Software, PBC [cph, fnd]"

# Every package must have at least one author (`aut`) and one maintainer (`cre`).
# The maintainer(`cre`) must provide an email address.

# These fields are then used to generate the `citation("pkgname")`
# citation.
# Only people listed as authors are included in the auto-generated citation.
citation(package = "tidyverse")


## 9.4 `URL` and `BugReports` ----

# Use the `URL` field to advertise the package's website AND
# public source repository (like GitHub).
# Separate multiple URLs with a comma.
# `BugReports` is the URL for GitHub issues.

# If you use `usethis::use_github()` to connect your local package
# to a remote GitHub repository, it will automatically populate
# `URL` and `BugReports` for you.

# If it is already connected to a remote GitHub repository,
# usethis::use_github_links() can add these links to `DESCRIPTION`.


## 9.5 The `License` field ----

# This field is mandatory. You can add it with 
# `usethis::use_mit_license()` for example.
# It is a machine-readable field.


## 9.6 `Imports`, `Suggests`, and friends ----

# Imports lists packages needed by the users at runtime and they
# will be installed or updated when they install your package with
# `install.packages()`.

# Never add the tidyverse package, but instead add individual packages
# like "dplyr" or "lubridate" with `usethis::use_package()`.

# Suggests lists optional packages that are useful in concert with your package.
# use `usethis::use_package("ggplot2, type = "Suggests")`.


### 9.6.1 Minimum  versions ----

# exact version with usethis::use_package("dplyr", min_version = "1.0.0")
# currently installed version with usethis::use_package("splyr", min_version = TRUE).

# You should always specify a minimum version
# Imports: dplyr (>= 1.0.0) rather than an exact version
# Imports: dplyr (== 1.0.0).


### 9.6.2 `Depends` and `LinkingTo` ----

# `Depends` is used to state a minimum version of R itself,
# like `Depends: R (>= 4.0.0)`.

# `LinkingTo` is used if you use C or C++ code from another package.

# `Enhances` lists packages that are "enhanced" by your package.


### 9.7 Other fields ----

# - `Version` contains the version of your package.

# - `LazyData: true` is automatically added if you add data to your package
#   with `usethis::use_data()`. It ensures your data file is only loaded when used.

# - `Encoding: UTF-8` is the most common character encoding.

# - `Collate` controls the order in which R files are sourced.
#   This matters only if your code has side-effects, usually when
#   you are using S4.
#   This field is generated by "roxygen2" through the `#' @include` roxygen tag.
?roxygen2::update_collate

# - `VignetteBuilder` lists any package that your package needs as a vignette engine.
#   usually lists the "knitr" package.

# - `SystemRequirements` describes dependencies external to R.
#   You want to describe such additional installation details in your `README`.
#   Usually used for packages with compiled code, where it declares the
#   C++ standard, the GNU make, etc.

# An example is
# SystemRequirements: C++17
# SystemRequirements: GNU make
# SystemRequirements: TensorFlow (https://www.tensorflow.org/).

# - The `Date` field is now discouraged, because it needs to be updated manually.
#   It will be populated when you submit to CRAN.


## 9.8 Custom fields ----

# If you plan to submit to CRAN, any custom field should start with
# `Config/*`.

# `usethis::create_package()` adds two more fields:
# Roxygen: list(markdown = TRUE)
# RoxygenNote: 7.2.1

# END
