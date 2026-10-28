# Shifts inside columns, as they happen with a column serpentine planting:
# a place skipped in a column, the rest of that column shifted by one, the
# packet left over thrown into the border, the next column planted as planned.
# RCBD: 20 accessions x 4 blocks; field of 10 rows x 8 columns, block b is
# columns 2b-1 and 2b. Planting by column, serpentine, from the bottom left,
# with a left border column planted first (up): column 1 goes down, column 2
# up, and so on. In every trial three columns have a skip at a random place.
# Datasets for lmer(y ~ (1|germplasmName) + (1|blockNumber)):
#   true        what grew where; the skipped places have no value
#   shift       Shift Accessions with the left border, to the end of each column
#   wrong_way   Shift Accessions without the border: every column the other way
#   planned     not corrected
suppressMessages(library(lme4))
set.seed(20261028)
n_acc <- 20; rows <- 10; cols <- 8
col_of <- rep(1:cols, each = rows)
# the path of each column: column 1 goes down (rows 10..1) after the border, column 2 up, ...
path_rows <- function(c, flip = FALSE) { down <- (c %% 2 == 1) != flip; if (down) rows:1 else 1:rows }
plot_id <- function(c, r) (c - 1) * rows + r          # place of (column, row)
block_of <- (col_of + 1) %/% 2
row_of <- rep(1:rows, times = cols)

shift_labels <- function(labels, c, from_row, flip) {
  p <- plot_id(c, path_rows(c, flip))                 # places in the order of the (assumed) path
  k <- which(p == plot_id(c, from_row))
  out <- labels
  if (k < rows) out[p[(k + 1):rows]] <- labels[p[k:(rows - 1)]]
  out[p[k]] <- NA
  out
}

accuracy <- function(acc, y, g) {
  d <- data.frame(acc = acc, y = y, block = factor(block_of))[!is.na(y) & !is.na(acc), ]
  m <- suppressMessages(suppressWarnings(lmer(y ~ (1 | acc) + (1 | block), data = d)))
  blup <- ranef(m)$acc[, 1]; names(blup) <- rownames(ranef(m)$acc)
  if (sd(blup) < 1e-8) return(0)
  cor(blup, g[names(blup)])
}

n_sim <- as.integer(Sys.getenv("N_SIM", "300"))
res <- do.call(rbind, lapply(seq_len(n_sim), function(i) {
  acc_names <- sprintf("G%02d", 1:n_acc)
  planned <- character(rows * cols)
  for (b in 1:4) planned[block_of == b] <- sample(acc_names)
  g <- rnorm(n_acc); names(g) <- acc_names
  b_eff <- rnorm(4, 0, sqrt(0.5))
  skipped_cols <- sample(1:cols, 3)
  skip_rows <- sapply(skipped_cols, function(c) sample(path_rows(c)[1:(rows - 1)], 1))   # not the last place of the column
  grew <- planned; shift <- planned; wrong <- planned
  for (j in seq_along(skipped_cols)) {
    grew <- shift_labels(grew, skipped_cols[j], skip_rows[j], FALSE)
    shift <- shift_labels(shift, skipped_cols[j], skip_rows[j], FALSE)
    wrong <- shift_labels(wrong, skipped_cols[j], skip_rows[j], TRUE)
  }
  y <- ifelse(is.na(grew), NA, 10 + g[grew] + b_eff[block_of] + 0.15 * row_of + rnorm(rows * cols))
  stopifnot(identical(shift, grew))
  planned_obs <- ifelse(is.na(grew), NA, planned)
  data.frame(sim = i,
             true = accuracy(grew, y, g), shift = accuracy(shift, y, g),
             wrong_way = accuracy(wrong, y, g), planned = accuracy(planned_obs, y, g),
             moved = sum(grew != planned, na.rm = TRUE), wrong_labels = sum(wrong != grew, na.rm = TRUE))
}))
write.csv(res, "simulation_columns_results.csv", row.names = FALSE)
q <- function(x) sprintf("%.3f (%.3f-%.3f)", median(x), quantile(x, 0.1), quantile(x, 0.9))
s <- data.frame(dataset = c("true", "shift", "wrong_way", "planned"),
                accuracy_median = sapply(res[c("true", "shift", "wrong_way", "planned")], median),
                accuracy_q10 = sapply(res[c("true", "shift", "wrong_way", "planned")], quantile, 0.1),
                accuracy_q90 = sapply(res[c("true", "shift", "wrong_way", "planned")], quantile, 0.9))
write.csv(s, "simulation_columns_summary.csv", row.names = FALSE)
for (k in c("true", "shift", "wrong_way", "planned")) cat(sprintf("%-10s %s\n", k, q(res[[k]])))
cat("plots with another accession than planned, median:", median(res$moved), "of 80\n")
cat("plots left with a wrong accession by a shift the wrong way, median:", median(res$wrong_labels), "\n")
