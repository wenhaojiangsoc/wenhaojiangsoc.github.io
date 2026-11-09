# Combine the bootstrap draws saved by boot.R into standard errors.

files <- list.files("results", pattern = "^boot_.*\\.rds$", full.names = TRUE)
draws <- do.call(rbind, lapply(files, readRDS))

cat("Bootstrap draws:", nrow(draws), "\n")
print(round(cbind(mean = colMeans(draws), se = apply(draws, 2, sd)), 4))
