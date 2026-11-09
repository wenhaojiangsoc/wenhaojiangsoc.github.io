# One bootstrap draw of the wage model in demo.R.
# Slurm runs this script once per array task; each task saves one draw.

task <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
set.seed(task)

acs <- read.csv("data/acs_nc_2024.csv")
w <- subset(acs, agep >= 25 & agep <= 64 & wagp > 0 & wkhp >= 35)
w$college <- as.integer(w$schl >= 21)
w$female  <- as.integer(w$sex == 2)

boot <- w[sample(nrow(w), replace = TRUE), ]
fit  <- lm(log(wagp) ~ college + female + agep + I(agep^2), data = boot, weights = pwgtp)

saveRDS(coef(fit), sprintf("results/boot_%03d.rds", task))
