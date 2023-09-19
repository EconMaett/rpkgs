# data-cleaning_v1.R
infile <- "swim.csv"
(dat <- read.csv(file = infile))

dat$english[dat$where == "beach"] <- "US"
dat$english[dat$where == "coast"] <- "US"
dat$english[dat$where == "seashore"] <- "UK"
dat$english[dat$where == "seaside"] <- "UK"

dat$temp[dat$english == "US"] <- (dat$temp[dat$english == "US"] - 32) * 5 / 9

now <- Sys.time()
timestamp <- format(now, "%Y-%B-%d_%H-%M-%S")
(outfile <- paste0(timestamp, "_", sub(pattern = "(.*)([.]csv$)", replacement = "\\1_clean\\2", x = infile)))
write.csv(dat, file = outfile, quote = FALSE, row.names = FALSE)

