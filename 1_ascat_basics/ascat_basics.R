###############################################################################
# Part 1: ASCAT basics
#
# Run this script line by line (Ctrl+Enter in VS Code) and answer the
# questions in the comments. The questions are also in 1_ascat_basics/QUESTIONS.md.
#
# All paths are relative to the repository root. In VS Code, the R terminal
# starts there. Check with getwd() if you get "file not found" errors.
###############################################################################

data_dir    <- "0_data/ascat_data"   # input: LogR/BAF files from ASCAT
results_dir <- "1_ascat_basics/results"       # output: all plots and tables
out_data_dir <- file.path(results_dir, "data")  # output: tables and the saved R objects
dir.create(out_data_dir, recursive = TRUE, showWarnings = FALSE)

# Each step writes its plots to its own subfolder of results_dir
plot_dirs <- c(raw_before = "1_raw_before_correction",
               raw_after  = "2_raw_after_correction",
               segmented  = "3_segmentation",
               fit        = "4_ascat_fit")
plot_dirs[] <- file.path(results_dir, plot_dirs)
for (d in plot_dirs) dir.create(d, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(file.path(data_dir, "Tumor_LogR.txt"))) {
  stop("Example data not found in ", data_dir,
       ". See 0_data/README.md.")
}

sessionInfo()
# Q: Which version of R are you running?


# ---- Step 1: Load the library ----------------------------------------------

library(ASCAT)
packageVersion("ASCAT")
sessionInfo()
# Q: Which version of ASCAT are you running?
# Q: Which other packages are loaded with it?


# ---- Step 2: Load the data -------------------------------------------------

ascat.bc <- ascat.loadData(
  Tumor_LogR_file    = file.path(data_dir, "Tumor_LogR.txt"),
  Tumor_BAF_file     = file.path(data_dir, "Tumor_BAF.txt"),
  Germline_LogR_file = file.path(data_dir, "Germline_LogR.txt"),
  Germline_BAF_file  = file.path(data_dir, "Germline_BAF.txt"),
  gender             = rep("XX", 100),
  genomeVersion      = "hg19"
)

# The data contain 100 samples. To keep things quick, we only work with
# 3 example profiles and drop the other 97.
example_samples <- c("S1", "S62", "S63")
keep <- match(example_samples, ascat.bc$samples)
for (m in c("Tumor_LogR", "Tumor_BAF", "Germline_LogR", "Germline_BAF")) {
  ascat.bc[[m]] <- ascat.bc[[m]][, keep, drop = FALSE]
}
ascat.bc$samples <- ascat.bc$samples[keep]
ascat.bc$gender  <- ascat.bc$gender[keep]

str(ascat.bc)
# Q: What does each input file contain?
# Q: Are the samples male or female? Where in the code did we tell ASCAT?
# Q: How many SNPs are in these data, and on which chromosomes?
#    How many would ASCAT use for whole-genome sequencing?


# ---- Step 3: Plot the raw data ---------------------------------------------

ascat.plotRawData(ascat.bc, img.dir = plot_dirs["raw_before"])
# Open the PNG files in 1_ascat_basics/results/1_raw_before_correction/.
# Q: What does each panel show? What is the difference between the
#    *.tumour.png and the *.germline.png plot of the same sample?
# Q: In the BAF panels, why are there bands at 0 and 1 as well as around 0.5?
#    Which SNPs are in each band?
# Q: Where can you already see gains, losses, or LOH by eye?
# Q: The changes in S62 are much smaller than in S1. What could cause that?


# ---- Step 4: Correct LogR for GC content and replication timing ------------

ascat.bc <- ascat.correctLogR(ascat.bc,
                              GCcontentfile    = file.path(data_dir, "GC_example.txt"),
                              replictimingfile = file.path(data_dir, "RT_example.txt"))
ascat.plotRawData(ascat.bc, img.dir = plot_dirs["raw_after"])
# Q: Compare the plots in 1_raw_before_correction/ and 2_raw_after_correction/.
#    What changed? Did the BAF change as well? Why (not)?
# Q: Why would GC content or replication timing affect the number of reads?


# ---- Step 5: Segmentation --------------------------------------------------

ascat.bc <- ascat.aspcf(ascat.bc, out.dir = out_data_dir)   # use penalty = 25 for targeted sequencing data
ascat.plotSegmentedData(ascat.bc, img.dir = plot_dirs["segmented"])
# You may see warnings "NAs introduced by coercion". They come from inside
# ASCAT and don't affect the results, so you can ignore them here.
# Q: Look at the plots in 3_segmentation/. The blue lines are the segments.
#    How similar or different are the three profiles?
# Q: In S1, find a segment where the BAF splits into two bands away from 0.5.
#    What does that tell you about the two parental copies there?
#    What does the LogR do in the same segment?
# Q: Why does the BAF panel show fewer SNPs than the LogR panel?
# Q: Can you spot samples that look problematic? What is wrong with them,
#    and how might you fix it? (If you can't tell yet, come back after Step 7.)


# ---- Step 6: Fit purity and ploidy -----------------------------------------

ascat.output <- ascat.runAscat(ascat.bc, img.dir = plot_dirs["fit"],
                               write_segments = TRUE)   # use gamma = 1 for sequencing data

names(ascat.output)
head(ascat.output$segments)
ascat.output$purity
ascat.output$ploidy
# Q: What does each element of ascat.output represent?
#    And the files written to 1_ascat_basics/results/4_ascat_fit/?
# Q: Open a sunrise plot (4_ascat_fit/*.sunrise.png). What do its axes show,
#    and what does the chosen point mean? Is there more than one good area?
# Q: Open the *.ASCATprofile.png files. What do the red and blue lines show?
#    Find a region with LOH and, if there is one, a homozygous deletion.
# Q: For each sample: what purity and ploidy did ASCAT find?
#    Are these values plausible for a tumour sample?
#    Do the copy-number profiles make sense to you?


# ---- Step 7: Quality metrics -----------------------------------------------

QC <- ascat.metrics(ascat.bc, ascat.output)
head(QC)
# Q: What kind of object is QC? Did the function write anything to disk?

write.table(QC, file.path(out_data_dir, "QC_metrics.txt"),
            sep = "\t", quote = FALSE, col.names = NA)   # col.names = NA keeps the sample names

# Samples sorted from noisiest to least noisy:
QC[order(QC$tumour_mapd, decreasing = TRUE),
   c("tumour_mapd", "purity", "ploidy", "goodness_of_fit", "homdel_fraction")]

# Q: Look at 'tumour_mapd' (noise in the tumour LogR) and 'homdel_fraction'
#    (fraction of the genome with homozygous deletion).
#    Which samples stand out, and why might that be?
# Q: Compare 'GC_correction_before' with 'GC_correction_after'. What do these
#    numbers measure, and does it fit what you saw in Step 4?
# Q: Which sample has the lowest goodness_of_fit? Does a high goodness of
#    fit alone prove that a solution is correct?


# ---- Step 8: Save your results ---------------------------------------------

save(ascat.bc, ascat.output, QC, file = file.path(out_data_dir, "ASCAT_objects.Rdata"))
# You need this file in Parts 2 and 3.
# Reload it later with: load("1_ascat_basics/results/data/ASCAT_objects.Rdata")
