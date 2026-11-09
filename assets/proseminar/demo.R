# Wages and college education among full-time workers in North Carolina
# Data: 2024 ACS 1-year PUMS, North Carolina person file (U.S. Census Bureau)

acs <- read.csv("data/acs_nc_2024.csv")

# Workers aged 25-64 with wages who usually work 35+ hours a week
w <- subset(acs, agep >= 25 & agep <= 64 & wagp > 0 & wkhp >= 35)
w$college <- as.integer(w$schl >= 21)   # bachelor's degree or more
w$female  <- as.integer(w$sex == 2)

fit <- lm(log(wagp) ~ college + female + agep + I(agep^2), data = w, weights = pwgtp)

cat("Workers in the sample:", nrow(w), "\n")
print(summary(fit))
