# data-cleaning_v3.R
library(tidyverse)
source(file = "cleaning-helpers.R")

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

(dat <- dat |>
  localize_beach() |>
  celsify_temp())

write_csv(dat, file = outfile_path(infile))
# END
