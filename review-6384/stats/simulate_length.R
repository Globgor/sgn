# Accuracy of the accession values against the length of a planting shift:
# from plot `start` to the end of the RCBD of simulate.R, every place got the
# packet planned for the place before it; plot `start` stayed empty.
# Datasets: planned (not corrected) and corrected (Shift Accessions; plot
# `start` not planted). Model: lmer(y ~ (1|germplasmName) + (1|replicate)).
suppressMessages(library(lme4))
set.seed(20261028)
n_acc <- 20; n_block <- 4
row <- ((1:80) - 1) %/% 10 + 1
block <- (row + 1) %/% 2

accuracy <- function(acc, y, g) {
  d <- data.frame(acc = acc, y = y, replicate = factor(block))[!is.na(y), ]
  m <- suppressMessages(suppressWarnings(lmer(y ~ (1 | acc) + (1 | replicate), data = d)))
  blup <- ranef(m)$acc[, 1]; names(blup) <- rownames(ranef(m)$acc)
  if (sd(blup) < 1e-8) return(0)
  cor(blup, g[names(blup)])
}

starts <- c(76, 66, 56, 46, 36, 26, 16, 6)
n_sim <- as.integer(Sys.getenv("N_SIM", "300"))
res <- do.call(rbind, lapply(starts, function(start) do.call(rbind, lapply(seq_len(n_sim), function(i) {
  acc_names <- sprintf("G%02d", 1:n_acc)
  planned <- unlist(lapply(1:n_block, function(b) sample(acc_names)))
  g <- rnorm(n_acc); names(g) <- acc_names
  b_eff <- rnorm(n_block, 0, sqrt(0.5))
  grew <- planned
  grew[(start + 1):80] <- planned[start:79]
  grew[start] <- NA
  y <- ifelse(is.na(grew), NA, 10 + g[grew] + b_eff[block] + 0.15 * row + rnorm(80))
  corrected <- planned
  corrected[(start + 1):80] <- planned[start:79]
  data.frame(shifted_plots = 80 - start, sim = i,
             corrected = accuracy(corrected, y, g),
             planned = accuracy(planned, y, g))
}))))
write.csv(res, "simulation_length_results.csv", row.names = FALSE)
s <- do.call(rbind, lapply(split(res, res$shifted_plots), function(d) data.frame(
  shifted_plots = d$shifted_plots[1],
  corrected_median = median(d$corrected), corrected_q10 = quantile(d$corrected, 0.1), corrected_q90 = quantile(d$corrected, 0.9),
  planned_median = median(d$planned), planned_q10 = quantile(d$planned, 0.1), planned_q90 = quantile(d$planned, 0.9))))
write.csv(s, "simulation_length_summary.csv", row.names = FALSE)
print(s, digits = 3, row.names = FALSE)
