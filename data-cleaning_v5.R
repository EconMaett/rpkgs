# data-cleaning_v5.R
library(tidyverse)
library(delta)

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat |> 
  delta:::localize_beach() |> 
  delta:::celsify_temp()

write_csv(dat, delta:::outfile_path(infile))
# END