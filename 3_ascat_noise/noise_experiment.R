###############################################################################
# Part 3: How much noise can ASCAT tolerate?
#
# We take one sample from Part 1, make several copies of it with increasing
# noise added to the tumour LogR, run ASCAT on all copies and compare.
#
# Run this script line by line and answer the questions in the comments.
# The questions are also in 3_ascat_noise/QUESTIONS.md.
#
# All paths are relative to the repository root (see getwd()).
###############################################################################

library(ASCAT)

data_dir    <- "0_data/ascat_data"     # the original input files from Part 1
noisy_dir   <- "3_ascat_noise/noisy_data"    # the noisy input files are written here
results_dir <- "3_ascat_noise/results"       # ASCAT plots and tables for this part
dir.create(noisy_dir,   showWarnings = FALSE)
dir.create(results_dir, showWarnings = FALSE)

# Each step writes its plots to its own subfolder of results_dir
plot_dirs <- c(noise      = "1_added_noise",
               raw_after  = "2_raw_after_correction",
               segmented  = "3_segmentation",
               fit        = "4_ascat_fit")
plot_dirs[] <- file.path(results_dir, plot_dirs)
for (d in plot_dirs) dir.create(d, recursive = TRUE, showWarnings = FALSE)

# Choose ONE of the three Part 1 samples with a good fit (look at its ASCAT
# profile and sunrise plot in 1_ascat_basics/results/4_ascat_fit/), and the noise
# levels you want to test.
sample_name <- "S1"                           # change to your choice
noise_sd    <- c(0, 0.25, 0.5, 1, 1.5, 2, 3)  # standard deviations of the added noise; keep 0 first


# ---- Step 1: Before running anything ---------------------------------------
#
# Q: The LogR of a typical copy-number change in Part 1 is only about +-0.3.
#    At which of the noise levels above do you expect the fit to break?
# Q: We add noise to the tumour LogR only. Which parts of the ASCAT result
#    do you expect to suffer most: segmentation, purity, ploidy or the
#    allele-specific copy numbers?


# ---- Step 2: Make the noisy input files ------------------------------------
#
# One sample column per noise level. Only the tumour LogR gets noise; the
# tumour BAF and both normal tracks are exact copies of the original sample.

read_ascat_file <- function(path) {
  read.table(path, header = TRUE, sep = "\t", row.names = 1, check.names = FALSE)
}

files      <- c("Tumor_LogR.txt", "Tumor_BAF.txt", "Germline_LogR.txt", "Germline_BAF.txt")
copy_names <- paste0(sample_name, "_sd", noise_sd)

set.seed(42)   # the same random noise every time you run the script
for (f in files) {
  original <- read_ascat_file(file.path(data_dir, f))
  noisy    <- original[, 1:2]                     # chromosome and position
  for (i in seq_along(noise_sd)) {
    values <- original[[sample_name]]
    if (f == "Tumor_LogR.txt") {
      values <- values + rnorm(length(values), mean = 0, sd = noise_sd[i])
    }
    noisy[[copy_names[i]]] <- values
  }
  write.table(noisy, file.path(noisy_dir, f), sep = "\t", quote = FALSE, col.names = NA)
}


# ---- Step 3: Look at the added noise ---------------------------------------

original_logr <- read_ascat_file(file.path(data_dir,  "Tumor_LogR.txt"))[[sample_name]]
noisy_logr    <- read_ascat_file(file.path(noisy_dir, "Tumor_LogR.txt"))[, copy_names]

added_noise <- noisy_logr - original_logr
data.frame(requested_sd = noise_sd,
           measured_sd  = round(apply(added_noise, 2, sd, na.rm = TRUE), 3))

png(file.path(plot_dirs["noise"], paste0(sample_name, ".noisy_vs_original_LogR.png")),
    width = 2400, height = 400, res = 150)
par(mfrow = c(1, length(noise_sd)))
for (i in seq_along(noise_sd)) {
  plot(original_logr, noisy_logr[, i], pch = ".",
       xlab = "original LogR", ylab = "noisy LogR", main = paste("sd =", noise_sd[i]))
}
invisible(dev.off())
# Open 1_added_noise/*.png.
# Q: Does the measured standard deviation match the one you asked for?
#    Why not exactly?
# Q: Compare the spread of the noise with the range of the original LogR
#    (x-axis). From which noise level on is the noise larger than the signal?


# ---- Step 4: Run ASCAT on the noisy data -----------------------------------
#
# Same steps as in Part 1.

ascat.noise <- ascat.loadData(
  Tumor_LogR_file    = file.path(noisy_dir, "Tumor_LogR.txt"),
  Tumor_BAF_file     = file.path(noisy_dir, "Tumor_BAF.txt"),
  Germline_LogR_file = file.path(noisy_dir, "Germline_LogR.txt"),
  Germline_BAF_file  = file.path(noisy_dir, "Germline_BAF.txt"),
  gender             = rep("XX", length(noise_sd)),
  genomeVersion      = "hg19"
)
ascat.noise <- ascat.correctLogR(ascat.noise,
                                 GCcontentfile    = file.path(data_dir, "GC_example.txt"),
                                 replictimingfile = file.path(data_dir, "RT_example.txt"))
ascat.plotRawData(ascat.noise, img.dir = plot_dirs["raw_after"])
# Q: Open the *.tumour.png files in 2_raw_after_correction/ from low to high
#    noise. Up to which noise level can you still see the copy-number
#    changes in the LogR by eye? And in the BAF?

ascat.noise <- ascat.aspcf(ascat.noise, out.dir = results_dir)
ascat.plotSegmentedData(ascat.noise, img.dir = plot_dirs["segmented"])
# Q: Compare the *.ASPCF.png files in 3_segmentation/. What happens to the
#    LogR segments (blue lines) as the noise grows? And to the BAF segments?

ascat.noise.output <- ascat.runAscat(ascat.noise, img.dir = plot_dirs["fit"], write_segments = TRUE)
ascat.noise.output$failedarrays
# Q: Did ASCAT fail to find a solution for any of the copies? Which one(s)?
#    Is the failure where you expected it?

QC.noise <- ascat.metrics(ascat.noise, ascat.noise.output)


# ---- Step 5: Compare the results across noise levels -----------------------

comparison <- data.frame(
  noise_sd        = noise_sd,
  tumour_mapd     = QC.noise$tumour_mapd,
  purity          = QC.noise$purity,
  ploidy          = QC.noise$ploidy,
  goodness_of_fit = QC.noise$goodness_of_fit,
  n_segments      = QC.noise$n_segs,
  row.names       = rownames(QC.noise)
)
comparison
write.table(comparison, file.path(results_dir, "noise_comparison.txt"),
            sep = "\t", quote = FALSE, col.names = NA)

# Your original Part 1 result for the same sample, for reference:
load("1_ascat_basics/results/data/ASCAT_objects.Rdata")
QC[sample_name, c("tumour_mapd", "purity", "ploidy", "goodness_of_fit", "n_segs")]

# Q: Does the zero-noise copy give the same result as your Part 1 run?
#    Why is that an important check?
# Q: How does tumour_mapd change with the noise you added? Could you use
#    MAPD to spot a noisy sample when you don't know how noisy it is?
# Q: Look at purity and ploidy across the noise levels. Do they change as
#    much as you expected?
# Q: Now open the *.ASCATprofile.png files in 4_ascat_fit/ for sd = 0 and
#    for a high noise level. Would you trust the noisy profile, even where
#    purity and ploidy look similar? Which QC value tells you something
#    is wrong?
# Q: At which noise level would you stop trusting the result? Would you
#    choose the same level if you reran with another random seed?
# Q: We only added noise to the LogR. Why do purity and ploidy survive so
#    much of it? What would you expect if we added noise to the BAF instead?
#    (Hint: think about what each one measures, and which one we left untouched.)
