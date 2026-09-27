###############################################################################
# Part 2: ASCAT advanced
#
# Going deeper into how ASCAT works: the gamma parameter, the segmentation
# penalty, refitting a profile and tumour-only mode.
#
# Run 1_ascat_basics/ascat_basics.R first: this script starts from its saved
# results. Run this script line by line and answer the questions in the
# comments. The questions are also in 2_ascat_advanced/QUESTIONS.md.
#
# All paths are relative to the repository root (see getwd()).
###############################################################################

library(ASCAT)

basics_dir  <- "1_ascat_basics/results"     # input: the saved results of Part 1
results_dir <- "2_ascat_advanced/results"   # output: all plots and tables

load(file.path(basics_dir, "data", "ASCAT_objects.Rdata"))   # ascat.bc, ascat.output, QC
samples <- ascat.bc$samples

# Each step writes its plots to its own subfolder of results_dir
plot_dirs <- c(gamma1      = "1_gamma1",
               penalty700  = "2_penalty700",
               refit       = "3_refit",
               tumour_only = "4_tumour_only")
plot_dirs[] <- file.path(results_dir, plot_dirs)
for (d in plot_dirs) dir.create(d, recursive = TRUE, showWarnings = FALSE)

# When ASCAT cannot fit a sample, that sample is missing from some results.
# Looking values up by sample name gives NA for those samples instead.
by_sample <- function(values) unname(values[samples])


# ---- Step 1: The gamma parameter -------------------------------------------

ascat.output.gamma1 <- ascat.runAscat(ascat.bc, gamma = 1, img.dir = plot_dirs["gamma1"],
                                      write_segments = TRUE)

gamma_comparison <- data.frame(
  purity_default  = by_sample(ascat.output$purity),
  purity_gamma1   = by_sample(ascat.output.gamma1$purity),
  ploidy_default  = by_sample(ascat.output$ploidy),
  ploidy_gamma1   = by_sample(ascat.output.gamma1$ploidy),
  fit_default     = by_sample(ascat.output$goodnessOfFit),
  fit_gamma1      = by_sample(ascat.output.gamma1$goodnessOfFit),
  row.names       = samples
)
gamma_comparison
ascat.output.gamma1$failedarrays   # samples ASCAT could not fit with gamma = 1
# Q: What is the gamma parameter? (Hint: ?ascat.runAscat)
# Q: What value should you use for sequencing data?
# Q: Compare fit_default and fit_gamma1 for each sample. Is one value
#    better for all three? How can you tell?
# Q: What does that tell you about how these data were generated?


# ---- Step 2: The segmentation penalty --------------------------------------

ascat.bc.high.penalty <- ascat.aspcf(ascat.bc, penalty = 700, out.dir = plot_dirs["penalty700"])
ascat.plotSegmentedData(ascat.bc.high.penalty, img.dir = plot_dirs["penalty700"])
# Q: Compare the plots in 1_ascat_basics/results/3_segmentation/ with those
#    in 2_penalty700/. What does the penalty control?
# Q: What do you gain and what do you lose with a very high penalty?


# ---- Step 3: Refitting a profile -------------------------------------------
#
# Look at S63.ASCATprofile.png and S63.sunrise.png in
# 1_ascat_basics/results/4_ascat_fit/.
# Q: Is the chosen point (the cross) in the best (darkest blue) area of the
#    sunrise plot? Where else is there a good area?
# Q: Do you believe this solution? Why (not)?

QC["S63", c("purity", "ploidy", "goodness_of_fit")]

# Choose new purity and ploidy bounds that exclude the current solution and
# include the one you believe in, then refit. runAscat fits all samples; we
# only look at S63 afterwards.
ascat.output.refit <- ascat.runAscat(ascat.bc,
                                     min_ploidy = 1.5, max_ploidy = 5.5,   # change these
                                     min_purity = 0.1, max_purity = 1.05,  # and/or these
                                     img.dir = plot_dirs["refit"])

c(purity_before = ascat.output$purity["S63"], purity_after = ascat.output.refit$purity["S63"],
  ploidy_before = ascat.output$ploidy["S63"], ploidy_after = ascat.output.refit$ploidy["S63"])
# Q: Did the refit change anything? If not, which bounds do you have to
#    change so that ASCAT picks the other good area of the sunrise plot?
# Q: Compare S63.ASCATprofile.png in 1_ascat_basics/results/4_ascat_fit/
#    and 3_refit/. Which solution do you think is better?
# Q: How could you find out for sure which one is correct?
#    (Hint: what extra data or experiment would settle it?)


# ---- Step 4: Tumour-only mode ----------------------------------------------
#
# Without a matched normal, ASCAT has to guess which SNPs are heterozygous
# from the tumour alone. 'Custom10k' is the setting for these example data,
# which have 10,000 SNPs (see ?ascat.predictGermlineGenotypes for real arrays).

gg <- ascat.predictGermlineGenotypes(ascat.bc, platform = "Custom10k",
                                     img.dir = plot_dirs["tumour_only"])
ascat.bc.tumour.only <- ascat.aspcf(ascat.bc, ascat.gg = gg, penalty = 70,
                                    out.dir = plot_dirs["tumour_only"])
ascat.plotSegmentedData(ascat.bc.tumour.only, img.dir = plot_dirs["tumour_only"])
ascat.output.tumour.only <- ascat.runAscat(ascat.bc.tumour.only,
                                           img.dir = plot_dirs["tumour_only"])
# Q: Open the tumorSep*.png files in 4_tumour_only/. What do the colours show?
#    Which SNPs does ASCAT consider heterozygous?

tumour_only_comparison <- data.frame(
  purity_matched     = by_sample(ascat.output$purity),
  purity_tumour_only = by_sample(ascat.output.tumour.only$purity),
  ploidy_matched     = by_sample(ascat.output$ploidy),
  ploidy_tumour_only = by_sample(ascat.output.tumour.only$ploidy),
  row.names          = samples
)
tumour_only_comparison$ploidy_difference <-
  tumour_only_comparison$ploidy_tumour_only - tumour_only_comparison$ploidy_matched

# Samples sorted from the biggest to the smallest ploidy difference:
tumour_only_comparison[order(abs(tumour_only_comparison$ploidy_difference), decreasing = TRUE), ]

# Q: Do the results with and without the normal agree for these samples?
#    Compare the ASCATprofile.png files in 1_ascat_basics/results/4_ascat_fit/
#    and 4_tumour_only/.
# Q: In other samples, tumour-only mode sometimes finds a solution with
#    about double (or half) the ploidy of the matched run. Why are these two
#    solutions so hard to tell apart from the data alone?
