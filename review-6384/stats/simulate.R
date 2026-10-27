# How a planting shift and plots that were not planted affect the trial
# analyses of Breedbase, and what the correction with Shift Accessions / Not
# Planted Plots gives back.
#
# RCBD: 20 accessions x 4 blocks = 80 plots, 8 rows x 10 columns; block b is
# rows 2b-1 and 2b. Plot numbers follow the planting order: by row,
# serpentine, from the bottom left corner.
# Field errors, as in the question:
#   - plot 55 was left empty on purpose (no space), and its seed packet was not used;
#   - at plot 26 a place was skipped by mistake: from there on, every place got the
#     packet planned for the place before it (past plot 55), the packet of plot 80
#     was left over;
#   - plot 43 was lost (nothing grew there).
# Values per plot: y = 10 + g(accession) + block + 0.15 * row + e,
#   g ~ N(0, 1), block ~ N(0, 0.5), e ~ N(0, 1): plot level H2 of the accessions = 0.5.
#
# Each simulated trial is analysed like Breedbase's heritability tool
# (R/heritability/h2_rscript.R): lmer(y ~ (1|germplasmName) + replicate),
# with replicate numeric, keeping accessions with more than one replicate
# left. Datasets:
#   true       - what really grew where; empty places have no value
#   corrected  - after Shift Accessions + Not Planted Plots: the same as true
#                (checked, not assumed: built from the planned plan with the same steps)
#   planned    - not corrected: the values are counted for the planned accessions
#   renumbered - accessions corrected, but the replicate renumbered per accession by
#                plot number (what PR #6384 does after a change), not the block
#   zero       - corrected, but the empty places recorded as 0 instead of no value

suppressMessages({ library(lme4) })
set.seed(20261027)

n_acc <- 20; n_block <- 4; n_row <- 8; n_col <- 10
plots <- data.frame(plot = 1:80)
plots$row <- (plots$plot - 1) %/% n_col + 1
pos <- (plots$plot - 1) %% n_col + 1
plots$col <- ifelse(plots$row %% 2 == 1, pos, n_col + 1 - pos)   # serpentine
plots$block <- (plots$row + 1) %/% 2

skip_at <- 26; no_space <- 55; lost <- 43

shift_plan <- function(planned) {
  # Shift Accessions from plot 26 to the end, one position, past plot 55 (not planted)
  grew <- planned
  path <- setdiff(skip_at:80, no_space)
  grew[path[-1]] <- planned[path[-length(path)]]
  grew[c(skip_at, no_space, lost)] <- NA          # Not planted
  grew
}

renumber <- function(acc, plot) {
  # replicate = n-th plot of the accession by plot number
  ave(plot, acc, FUN = function(p) rank(p))
}

# model "h2": the heritability tool, replicate as a number;
# model "mixed": the Mixed Models tool with replicate as a random factor
fit <- function(d, g_true, model) {
  d <- d[!is.na(d$y), ]
  if (model == "h2") {
    reps <- tapply(d$replicate, d$acc, function(r) length(unique(r)))
    d <- d[d$acc %in% names(reps)[reps > 1], ]
    m <- suppressMessages(suppressWarnings(lmer(y ~ (1 | acc) + replicate, data = d)))
  } else {
    d$replicate <- factor(d$replicate)
    m <- suppressMessages(suppressWarnings(lmer(y ~ (1 | acc) + (1 | replicate), data = d)))
  }
  vc <- as.data.frame(VarCorr(m))
  vg <- vc$vcov[vc$grp == "acc"]; ve <- vc$vcov[vc$grp == "Residual"]
  blup <- ranef(m)$acc[, 1]; names(blup) <- rownames(ranef(m)$acc)
  truth <- g_true[names(blup)]
  top_true <- names(sort(g_true, decreasing = TRUE))[1:5]
  top_est <- names(sort(blup, decreasing = TRUE))[1:5]
  # a fit without accession variance ranks nothing: accuracy 0
  singular <- sd(blup) < 1e-8
  c(h2 = vg / (vg + ve),
    accuracy = if (singular) 0 else cor(blup, truth),
    top5 = if (singular) 0 else length(intersect(top_true, top_est)),
    singular = singular)
}

one_trial <- function() {
  acc_names <- sprintf("G%02d", 1:n_acc)
  planned <- unlist(lapply(1:n_block, function(b) sample(acc_names)))
  g <- rnorm(n_acc, 0, 1); names(g) <- acc_names
  b_eff <- rnorm(n_block, 0, sqrt(0.5))

  grew <- planned
  path <- setdiff(skip_at:80, no_space)
  grew[path[-1]] <- planned[path[-length(path)]]
  grew[c(skip_at, no_space, lost)] <- NA

  y <- ifelse(is.na(grew), NA, 10 + g[grew] + b_eff[plots$block] + 0.15 * plots$row + rnorm(80, 0, 1))

  corrected <- shift_plan(planned)
  stopifnot(identical(corrected, grew))

  base <- data.frame(plot = plots$plot, block = plots$block, y = y)
  ds <- list(
    true       = transform(base, acc = grew, replicate = block),
    corrected  = transform(base, acc = corrected, replicate = block),
    planned    = transform(base, acc = planned, replicate = block),
    renumbered = transform(base, acc = corrected, replicate = renumber(corrected, plot)),
    zero       = transform(base, acc = ifelse(is.na(grew), planned, grew), replicate = block,
                           y = ifelse(is.na(grew), 0, y))
  )
  r <- ds$renumbered
  mismatch <- sum(r$replicate != r$block & !is.na(r$y))
  cbind(rbind(data.frame(model = "h2", dataset = names(ds), t(sapply(ds, fit, g_true = g, model = "h2")), row.names = NULL),
              data.frame(model = "mixed", dataset = names(ds), t(sapply(ds, fit, g_true = g, model = "mixed")), row.names = NULL)),
        rep_mismatch = mismatch)
}

n_sim <- as.integer(Sys.getenv("N_SIM", "500"))
res <- do.call(rbind, lapply(seq_len(n_sim), function(i) data.frame(sim = i, one_trial())))
write.csv(res, "simulation_results.csv", row.names = FALSE)

summary_table <- do.call(rbind, lapply(split(res, list(res$model, res$dataset)), function(d) data.frame(
  model = d$model[1], dataset = d$dataset[1],
  h2_median = median(d$h2), h2_q10 = quantile(d$h2, 0.1), h2_q90 = quantile(d$h2, 0.9),
  accuracy_median = median(d$accuracy), accuracy_q10 = quantile(d$accuracy, 0.1), accuracy_q90 = quantile(d$accuracy, 0.9),
  top5_mean = mean(d$top5), singular_share = mean(d$singular))))
summary_table <- summary_table[order(summary_table$model, match(summary_table$dataset, c("true", "corrected", "planned", "renumbered", "zero"))), ]
write.csv(summary_table, "simulation_summary.csv", row.names = FALSE)
print(summary_table, digits = 3, row.names = FALSE)
cat("\nidentical corrected and true fits in all simulations:",
    all(abs(res$h2[res$dataset == "true"] - res$h2[res$dataset == "corrected"]) < 1e-12), "\n")
cat("planted plots whose renumbered replicate is not their block, median (10%-90%):",
    median(res$rep_mismatch), "(", quantile(res$rep_mismatch, 0.1), "-", quantile(res$rep_mismatch, 0.9), ") of 77\n")
