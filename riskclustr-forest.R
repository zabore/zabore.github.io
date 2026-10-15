# Regenerate images/riskclustr.png from the package's simulated data.
# Run from the project root. Requires: riskclustr, ggplot2, dplyr, tidyr, tibble
library(riskclustr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(tibble)

mod1 <- eh_test_subtype(
  label = "subtype",
  M = 4,
  factors = list("x1", "x2", "x3"),
  data = subtype_data
)

to_long <- function(x, value) {
  as.data.frame(x) |>
    rownames_to_column("factor") |>
    pivot_longer(-factor, names_to = "subtype", values_to = value)
}

# Heterogeneity p-values, formatted for the panel headers
pvals <-
  tibble(
    factor = rownames(mod1$eh_pval),
    p = mod1$eh_pval[["p_het"]]
  ) |>
  mutate(
    p_label = ifelse(p < 0.001, "p-het < 0.001", sprintf("p-het = %.3f", p))
  )

# Subtype-specific ORs with 95% CIs: beta +/- 1.96 * SE on the log scale
plot_dat <-
  to_long(mod1$beta, "beta") |>
  left_join(to_long(mod1$beta_se, "se"), by = c("factor", "subtype")) |>
  left_join(pvals, by = "factor") |>
  mutate(
    or = exp(beta),
    lo = exp(beta - 1.96 * se),
    hi = exp(beta + 1.96 * se),
    subtype = factor(paste("Subtype", subtype), levels = paste("Subtype", 4:1)),
    facet = paste0("Risk factor ", factor, "\n", p_label)
  )

p <-
  ggplot(plot_dat, aes(x = or, y = subtype, color = subtype)) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = lo, xmax = hi), linewidth = 0.9) +
  scale_x_log10(breaks = c(1, 2, 5, 10, 20)) +
  scale_color_manual(values = c("#8e5ea2", "#2e8b57", "#d9822b", "#1b6ca8")) +
  facet_wrap(~facet) +
  labs(
    x = "Odds ratio (log scale)", y = NULL,
    title = "Etiologic heterogeneity: risk factor effects differ across disease subtypes"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 11),
    strip.text = element_text(face = "bold")
  )

dir.create("images", showWarnings = FALSE)
ggsave("images/riskclustr.png", p, width = 9, height = 3.4, dpi = 200, bg = "white")
