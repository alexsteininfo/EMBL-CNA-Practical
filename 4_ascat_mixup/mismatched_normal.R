###############################################################################
# Part 4: Tumour paired with the wrong normal
#
# We take one tumour from the Part 1 example data and pair it twice:
#   1. with its own normal (correct), and
#   2. with the normal of another patient (a "sample swap").
# Then we run ASCAT on both pairs and compare.
#
# Run this script line by line and answer the questions in the comments.
# The questions are also in 4_ascat_mixup/QUESTIONS.md.
#
# All paths are relative to the repository root (see getwd()).
###############################################################################

library(ASCAT)

data_dir    <- "0_data/ascat_data"     # the original input files from Part 1
pair_dir    <- "4_ascat_mixup/data"      # the matched and mismatched input files
results_dir <- "4_ascat_mixup/results"   # ASCAT plots and tables for this part
dir.create(pair_dir,    showWarnings = FALSE)
dir.create(results_dir, showWarnings = FALSE)

# Each step writes its plots to its own subfolder of results_dir
plot_dirs <- c(raw_after  = "1_raw_after_correction",
               segmented  = "2_segmentation",
               fit        = "3_ascat_fit",
               genotypes  = "4_genotype_check")
plot_dirs[] <- file.path(results_dir, plot_dirs)
for (d in plot_dirs) dir.create(d, recursive = TRUE, showWarnings = FALSE)

tumour_sample <- "S1"   # the tumour we analyse
wrong_normal  <- "S2"   # the normal from a different patient


# ---- Step 1: Before running anything ---------------------------------------
#
# Q: ASCAT uses the normal sample to decide which SNPs are heterozygous.
#    Which SNPs will it pick if the normal comes from another person?
#    What do you expect to happen to the BAF segmentation and to the fit?


# ---- Step 2: Build the matched and the mismatched pair ---------------------

read_ascat_file <- function(path) {
  read.table(path, header = TRUE, sep = "\t", row.names = 1, check.names = FALSE)
}

pair_names <- c(paste0(tumour_sample, "_matched"),
                paste0(tumour_sample, "_with_", wrong_normal, "_normal"))

for (track in c("LogR", "BAF")) {
  tumour <- read_ascat_file(file.path(data_dir, paste0("Tumor_",    track, ".txt")))
  normal <- read_ascat_file(file.path(data_dir, paste0("Germline_", track, ".txt")))

  # The tumour is the same in both pairs; only the normal differs.
  tumour_out <- data.frame(tumour[, 1:2], tumour[[tumour_sample]], tumour[[tumour_sample]])
  normal_out <- data.frame(normal[, 1:2], normal[[tumour_sample]], normal[[wrong_normal]])
  colnames(tumour_out)[3:4] <- colnames(normal_out)[3:4] <- pair_names

  write.table(tumour_out, file.path(pair_dir, paste0("Tumor_",    track, ".txt")),
              sep = "\t", quote = FALSE, col.names = NA)
  write.table(normal_out, file.path(pair_dir, paste0("Germline_", track, ".txt")),
              sep = "\t", quote = FALSE, col.names = NA)
}


# ---- Step 3: Run ASCAT on both pairs ---------------------------------------
#
# Same steps as in Part 1.

ascat.pairs <- ascat.loadData(
  Tumor_LogR_file    = file.path(pair_dir, "Tumor_LogR.txt"),
  Tumor_BAF_file     = file.path(pair_dir, "Tumor_BAF.txt"),
  Germline_LogR_file = file.path(pair_dir, "Germline_LogR.txt"),
  Germline_BAF_file  = file.path(pair_dir, "Germline_BAF.txt"),
  gender             = rep("XX", 2),
  genomeVersion      = "hg19"
)
ascat.pairs <- ascat.correctLogR(ascat.pairs,
                                 GCcontentfile    = file.path(data_dir, "GC_example.txt"),
                                 replictimingfile = file.path(data_dir, "RT_example.txt"))
ascat.plotRawData(ascat.pairs, img.dir = plot_dirs["raw_after"])
ascat.pairs <- ascat.aspcf(ascat.pairs, out.dir = results_dir)
ascat.plotSegmentedData(ascat.pairs, img.dir = plot_dirs["segmented"])
ascat.pairs.output <- ascat.runAscat(ascat.pairs, img.dir = plot_dirs["fit"], write_segments = TRUE)
QC.pairs <- ascat.metrics(ascat.pairs, ascat.pairs.output)

QC.pairs[, c("n_het_SNP", "n_segs", "purity", "ploidy", "goodness_of_fit", "LOH")]

# Open the PNG files in the subfolders of 4_ascat_mixup/results/ and compare
# the two pairs.
#
# Q: Compare the *.tumour.png plots of the two pairs in
#    1_raw_after_correction/. Why do they look the same?
#    Now compare the *.germline.png plots. What is different?
# Q: In 2_segmentation/, compare the BAF panels of the two pairs. ASCAT only
#    shows the SNPs it thinks are heterozygous. Which SNPs does it use in the
#    mismatched pair, and where do the BAF segments (blue lines) end up?
# Q: Why is the LogR segmentation hardly affected, while the BAF is?
# Q: Compare the two *.ASCATprofile.png and *.sunrise.png files in
#    3_ascat_fit/. How do purity and ploidy differ? Would you trust the
#    mismatched fit if you had never seen the matched one?
# Q: Compare the QC metrics above. Which ones would warn you, and which
#    would not? Why does n_het_SNP change at all, when the tumour is the same?


# ---- Step 4: Detecting a mismatch early ------------------------------------
#
# Q: How could you detect a mismatch BEFORE running the full analysis?
#    Think about it first, then run the code below.
#
# Idea: a tumour carries the same inherited genotypes as its own normal.
# Copy-number changes can turn a heterozygous SNP (A/B) into an apparently
# homozygous one (loss of heterozygosity), but they can never turn A/A into B/B.

call_genotype <- function(baf) {
  ifelse(baf < 0.15, "AA", ifelse(baf > 0.85, "BB", "AB"))
}

tumour_baf <- read_ascat_file(file.path(pair_dir, "Tumor_BAF.txt"))
normal_baf <- read_ascat_file(file.path(pair_dir, "Germline_BAF.txt"))

for (pair in pair_names) {
  gt_tumour <- call_genotype(tumour_baf[[pair]])
  gt_normal <- call_genotype(normal_baf[[pair]])
  cat("\n", pair, "\n", sep = "")
  cat("  genotype concordance:            ", round(mean(gt_tumour == gt_normal, na.rm = TRUE), 3), "\n")
  cat("  opposite homozygotes (AA vs BB): ",
      sum((gt_tumour == "AA" & gt_normal == "BB") | (gt_tumour == "BB" & gt_normal == "AA"), na.rm = TRUE), "\n")
  print(table(tumour = gt_tumour, normal = gt_normal))
}

# The same comparison as a picture: tumour BAF against normal BAF.
png(file.path(plot_dirs["genotypes"], paste0(tumour_sample, ".tumour_vs_normal_BAF.png")),
    width = 1600, height = 800, res = 150)
par(mfrow = c(1, 2))
for (pair in pair_names) {
  plot(normal_baf[[pair]], tumour_baf[[pair]], pch = ".",
       xlab = "normal BAF", ylab = "tumour BAF", main = pair)
}
invisible(dev.off())
# Open 4_genotype_check/*.png.

# Q: What concordance do you see for the matched and for the mismatched pair?
#    Why is the matched pair not at exactly 1?
# Q: Look at the genotype tables. In the matched pair, which cells are not
#    zero apart from the diagonal? What could cause them?
# Q: Why is the number of opposite homozygotes such a strong signal?
# Q: In the BAF-against-BAF plot, where do the points of the matched pair
#    lie? Which points in the mismatched plot give the swap away?
# Q: In practice, tools such as somalier or NGSCheckMate run this kind of
#    check on BAM or VCF files. At which point in a project would you run it?
