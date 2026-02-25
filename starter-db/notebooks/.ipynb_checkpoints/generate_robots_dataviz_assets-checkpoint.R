#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
infile <- if (length(args) >= 1) args[[1]] else "data/robots_missions.csv"
outdir <- if (length(args) >= 2) args[[2]] else "slides/assets/dataviz_robots"

if (!file.exists(infile)) {
  stop(sprintf("Input file not found: %s", infile))
}

if (!dir.exists(outdir)) {
  dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
}

df <- read.csv(infile, stringsAsFactors = FALSE)

num_cols <- c("mission_duration_s", "downtime_s", "battery_pct", "speed_mps", "temperature_c", "incident_label")
for (col in num_cols) {
  if (col %in% names(df)) {
    df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
  }
}

df$timestamp <- as.POSIXct(df$timestamp, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
df <- df[!duplicated(df), ]
df <- df[!is.na(df$timestamp) & !is.na(df$mission_duration_s) & !is.na(df$downtime_s) & !is.na(df$battery_pct), ]
df <- df[df$mission_duration_s > 0 & df$downtime_s >= 0 & df$battery_pct >= 0 & df$battery_pct <= 100, ]

df$hour <- as.integer(format(df$timestamp, "%H"))
df$is_error <- ifelse(is.na(df$error_code) | df$error_code == "", 0, 1)

save_png <- function(filename, expr) {
  png(file.path(outdir, filename), width = 1400, height = 850, res = 130)
  par(mar = c(5, 5, 4, 2) + 0.1)
  eval.parent(substitute(expr))
  dev.off()
}

# 1) Missions by hour
missions <- aggregate(robot_id ~ hour, data = df, FUN = length)
missions <- missions[order(missions$hour), ]
save_png("missions_by_hour.png", {
  plot(
    missions$hour, missions$robot_id,
    type = "b", pch = 19, col = "#1f77b4",
    xlab = "Heure", ylab = "Nombre de missions",
    main = "Missions par heure"
  )
  grid()
})

# 2) Battery distribution
save_png("battery_distribution.png", {
  hist(
    df$battery_pct,
    breaks = 25,
    col = "#1f77b4",
    border = "white",
    xlab = "Batterie (%)",
    main = "Distribution du niveau de batterie"
  )
  grid()
})

# 3) Error rate by zone
zone_err <- aggregate(is_error ~ zone, data = df, FUN = mean)
zone_err <- zone_err[order(zone_err$is_error, decreasing = TRUE), ]
save_png("error_rate_by_zone.png", {
  barplot(
    zone_err$is_error,
    names.arg = zone_err$zone,
    col = "#d62728",
    xlab = "Zone",
    ylab = "Taux d'erreur",
    main = "Taux d'erreur moyen par zone"
  )
  grid(nx = NA, ny = NULL)
})

# 3bis) Downtime boxplot by robot type
by_type <- split(df$downtime_s, df$robot_type)
whisker_high <- sapply(by_type, function(x) boxplot.stats(x)$stats[5])
out_count <- sapply(by_type, function(x) length(boxplot.stats(x)$out))
n_count <- sapply(by_type, length)
ylim_top <- max(whisker_high) * 1.05
subtitle <- paste(
  sprintf(
    "%s: %d/%d (%.1f%%)",
    names(n_count), out_count, n_count, 100 * out_count / n_count
  ),
  collapse = " | "
)

save_png("downtime_boxplot_by_robot_type.png", {
  boxplot(
    downtime_s ~ robot_type, data = df,
    col = "#9ecae1",
    xlab = "Type de robot", ylab = "Downtime (s)",
    main = "Distribution du downtime par type de robot (coeur de distribution)",
    outline = FALSE,
    ylim = c(0, ylim_top)
  )
  mtext("Outliers hors cadre (regle 1.5*IQR) pour la lisibilite", side = 3, line = 0.2, cex = 0.8)
  mtext(subtitle, side = 3, line = -0.8, cex = 0.65)
  grid(nx = NA, ny = NULL)
})

# 3ter) Boxplot reading guide (annotated)
# Exemple didactique avec peu d'outliers pour une lecture claire du boxplot
set.seed(7)
guide_x <- c(rnorm(140, mean = 95, sd = 18), 175, 182)
guide_x <- guide_x[is.finite(guide_x)]

bp <- boxplot(guide_x, plot = FALSE)
s <- bp$stats

save_png("boxplot_reading_guide.png", {
  boxplot(
    guide_x,
    col = "#c6dbef",
    border = "#2171b5",
    ylab = "Downtime (s)",
    main = "Comment lire un boxplot (exemple: downtime)"
  )
  grid(nx = NA, ny = NULL)

  text(1.25, s[3], "Mediane (Q2)", pos = 4, cex = 0.9, col = "#08306b")
  text(1.25, s[2], "Q1 (25%)", pos = 4, cex = 0.9, col = "#08306b")
  text(1.25, s[4], "Q3 (75%)", pos = 4, cex = 0.9, col = "#08306b")
  text(1.25, s[1], "Moustache basse", pos = 4, cex = 0.9, col = "#67000d")
  text(1.25, s[5], "Moustache haute", pos = 4, cex = 0.9, col = "#67000d")

  if (length(bp$out) > 0) {
    text(0.75, max(bp$out), "Outliers", pos = 2, cex = 0.9, col = "#cb181d")
  }
})

# 4) Correlation matrix heatmap
corr_cols <- c("battery_pct", "speed_mps", "temperature_c", "mission_duration_s", "downtime_s")
corr_mat <- cor(df[, corr_cols], use = "complete.obs")
save_png("correlation_heatmap.png", {
  pal <- colorRampPalette(c("#2b83ba", "#f7f7f7", "#d7191c"))(100)
  image(
    1:ncol(corr_mat), 1:nrow(corr_mat), t(corr_mat[nrow(corr_mat):1, ]),
    col = pal, zlim = c(-1, 1),
    axes = FALSE, xlab = "", ylab = "",
    main = "Matrice de correlation"
  )
  axis(1, at = 1:ncol(corr_mat), labels = colnames(corr_mat), las = 2, cex.axis = 0.8)
  axis(2, at = 1:nrow(corr_mat), labels = rev(rownames(corr_mat)), las = 2, cex.axis = 0.8)
  for (i in seq_len(nrow(corr_mat))) {
    for (j in seq_len(ncol(corr_mat))) {
      text(j, nrow(corr_mat) - i + 1, sprintf("%.2f", corr_mat[i, j]), cex = 0.8)
    }
  }
})

# 5) Error heatmap by zone/hour
err_heat <- tapply(df$is_error, list(df$zone, df$hour), mean)
err_heat[is.na(err_heat)] <- 0
zones <- rownames(err_heat)
hours <- as.integer(colnames(err_heat))
save_png("error_heatmap_zone_hour.png", {
  pal <- colorRampPalette(c("#fff5f0", "#fb6a4a", "#67000d"))(100)
  image(
    x = seq_along(hours), y = seq_along(zones), z = t(err_heat),
    col = pal, axes = FALSE,
    xlab = "Heure", ylab = "Zone",
    main = "Taux d'erreur par zone et par heure"
  )
  axis(1, at = seq_along(hours), labels = hours, las = 2, cex.axis = 0.7)
  axis(2, at = seq_along(zones), labels = zones, las = 2)
})

# 6) Control chart (15min)
bucket <- as.POSIXct(floor(as.numeric(df$timestamp) / 900) * 900, origin = "1970-01-01", tz = "UTC")
ts_df <- data.frame(bucket = bucket, is_error = df$is_error)
ts <- aggregate(is_error ~ bucket, data = ts_df, FUN = mean)
ts <- ts[order(ts$bucket), ]
n <- nrow(ts)
mu <- rep(NA_real_, n)
sigma <- rep(NA_real_, n)

for (i in seq_len(n)) {
  start <- max(1, i - 15)
  window <- ts$is_error[start:i]
  if (length(window) >= 8) {
    mu[i] <- mean(window, na.rm = TRUE)
    sigma[i] <- sd(window, na.rm = TRUE)
  }
}

upper <- mu + 3 * sigma
alert <- ts$is_error > upper & !is.na(upper)
save_png("control_chart_error_rate.png", {
  plot(ts$bucket, ts$is_error, type = "l", lwd = 2, col = "#1f77b4",
       xlab = "Temps", ylab = "Taux d'erreur",
       main = "Carte de controle du taux d'erreur (15 min)")
  lines(ts$bucket, mu, lwd = 2, col = "#2ca02c")
  lines(ts$bucket, upper, lwd = 2, lty = 2, col = "#d62728")
  points(ts$bucket[alert], ts$is_error[alert], pch = 19, col = "#d62728")
  legend("topleft",
         legend = c("error_rate", "moyenne mobile", "limite haute 3 sigma", "alerte"),
         col = c("#1f77b4", "#2ca02c", "#d62728", "#d62728"),
         lty = c(1, 1, 2, NA), pch = c(NA, NA, NA, 19), bty = "n")
  grid()
})

# 7) Anomaly score scatter
feat <- c("downtime_s", "mission_duration_s", "battery_pct", "temperature_c")
z <- scale(df[, feat])
score <- sqrt(rowSums(z^2))
threshold <- as.numeric(quantile(score, 0.99, na.rm = TRUE))
is_anomaly <- score >= threshold

save_png("anomaly_scatter.png", {
  cols <- ifelse(is_anomaly, "#d62728", "#1f77b4")
  plot(
    df$mission_duration_s, df$downtime_s,
    col = cols, pch = 19, cex = 0.7,
    xlab = "Duree mission (s)", ylab = "Downtime (s)",
    main = "Points anormaux selon score multivariable"
  )
  legend("topleft", legend = c("normal", "anomalie"), col = c("#1f77b4", "#d62728"), pch = 19, bty = "n")
  grid()
})

# 8) Baseline ratio boxplot
baseline <- aggregate(downtime_s ~ robot_id + hour, data = df, FUN = median)
names(baseline)[names(baseline) == "downtime_s"] <- "downtime_baseline"
df2 <- merge(df, baseline, by = c("robot_id", "hour"), all.x = TRUE)
df2$downtime_ratio <- df2$downtime_s / (df2$downtime_baseline + 1)

save_png("baseline_ratio_boxplot.png", {
  boxplot(
    downtime_ratio ~ robot_type, data = df2,
    col = "#9ecae1",
    xlab = "Type de robot", ylab = "Ratio vs baseline",
    main = "Ecart au baseline de downtime (par type robot)"
  )
  abline(h = 2, col = "#d62728", lty = 2, lwd = 2)
  grid(nx = NA, ny = NULL)
})

# 9) Confusion matrix image
incident <- if ("incident_label" %in% names(df)) ifelse(is.na(df$incident_label), 0, as.integer(df$incident_label)) else rep(0L, nrow(df))
pred <- ifelse(is_anomaly, 1L, 0L)
cm <- table(factor(incident, levels = c(0, 1)), factor(pred, levels = c(0, 1)))

save_png("confusion_matrix.png", {
  mat <- matrix(as.numeric(cm), nrow = 2, byrow = TRUE)
  pal <- colorRampPalette(c("#eff3ff", "#084594"))(100)
  image(1:2, 1:2, t(mat[2:1, ]), col = pal, axes = FALSE, xlab = "", ylab = "", main = "Matrice de confusion")
  axis(1, at = 1:2, labels = c("Pred 0", "Pred 1"))
  axis(2, at = 1:2, labels = c("Reel 1", "Reel 0"), las = 2)
  text(1, 2, mat[1, 1], cex = 1.2)
  text(2, 2, mat[1, 2], cex = 1.2)
  text(1, 1, mat[2, 1], cex = 1.2)
  text(2, 1, mat[2, 2], cex = 1.2)
})

cat(sprintf("OK: assets generated in %s\n", outdir))
