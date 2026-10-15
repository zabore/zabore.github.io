# Regenerate images/ipcw-km.png (single-event Kaplan-Meier comparison)
# using the same code as the ipcw README. Run from the project root.
# Requires: ipcw, survival, ggsurvfit, dplyr, ggplot2
# install.packages(c("survival", "ggsurvfit", "dplyr", "ggplot2"))
# install.packages("pak"); pak::pak("zabore/ipcw")
library(ipcw)
library(survival)
library(ggsurvfit)
library(dplyr)
library(ggplot2)

set.seed(67)
dat <- sim_data_se(n = 500)

# Unadjusted (naive) Kaplan-Meier, ignoring dependent censoring
naive_fit <- survfit(Surv(t, delta) ~ x, data = dat)

# Convert to counting-process (long) format and compute IPCW
dat_long <- get_ipcw_wgt_se(dat)

# IPCW-adjusted Kaplan-Meier
ipcw_fit <-
  survfit(
    Surv(tstart, tstop, delta) ~ x,
    data = dat_long,
    weights = wgt,
    timefix = FALSE
  )

tidy_naive <- tidy_survfit(naive_fit) |> mutate(group = "Unadjusted")
tidy_ipcw <- tidy_survfit(ipcw_fit) |> mutate(group = "Adjusted")

p <-
  bind_rows(tidy_naive, tidy_ipcw) |>
  ggplot(aes(x = time, y = estimate, color = strata, linetype = group)) +
  geom_step(linewidth = 0.9) +
  scale_color_manual(name = NULL, values = c("#0078bf", "#f7c612")) +
  scale_linetype_manual(name = NULL, values = c("solid", "dashed")) +
  theme_bw(base_size = 13) +
  theme(
    legend.position = "bottom",
    legend.box = "vertical"
  ) +
  labs(x = "Time", y = "Survival probability")

dir.create("images", showWarnings = FALSE)
ggsave("images/ipcw-km.png", p, width = 6, height = 4.5, dpi = 200, bg = "white")
