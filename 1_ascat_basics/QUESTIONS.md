# Part 1: Questions

Answer these while you run [ascat_basics.R](ascat_basics.R) line by line. Folder names refer to `1_ascat_basics/results/`.

## Before you start

- Which version of R are you running?

## Step 1: Load the library

- Which version of ASCAT are you running?
- Which other packages are loaded with it?

## Step 2: Load the data

- What does each input file contain?
- Are the samples male or female? Where in the code did we tell ASCAT?
- How many SNPs are in these data, and on which chromosomes? How many would ASCAT use for whole-genome sequencing?

## Step 3: Plot the raw data (`1_raw_before_correction/`)

- What does each panel show? What is the difference between the `*.tumour.png` and the `*.germline.png` plot of the same sample?
- In the BAF panels, why are there bands at 0 and 1 as well as around 0.5? Which SNPs are in each band?
- Where can you already see gains, losses, or LOH by eye?
- The changes in S62 are much smaller than in S1. What could cause that?

## Step 4: Correct LogR for GC content and replication timing (`2_raw_after_correction/`)

- Compare the plots in `1_raw_before_correction/` and `2_raw_after_correction/`. What changed? Did the BAF change as well? Why (not)?
- Why would GC content or replication timing affect the number of reads?

## Step 5: Segmentation (`3_segmentation/`)

- The blue lines are the segments. How similar or different are the three profiles?
- In S1, find a segment where the BAF splits into two bands away from 0.5. What does that tell you about the two parental copies there? What does the LogR do in the same segment?
- Why does the BAF panel show fewer SNPs than the LogR panel?
- Can you spot samples that look problematic? What is wrong with them, and how might you fix it? (If you can't tell yet, come back after Step 7.)

## Step 6: Fit purity and ploidy (`4_ascat_fit/`)

- What does each element of `ascat.output` represent? And the files written to `4_ascat_fit/`?
- Open a sunrise plot (`*.sunrise.png`). What do its axes show, and what does the chosen point mean? Is there more than one good area?
- Open the `*.ASCATprofile.png` files. What do the red and blue lines show? Find a region with LOH and, if there is one, a homozygous deletion.
- For each sample: what purity and ploidy did ASCAT find? Are these values plausible for a tumour sample? Do the copy-number profiles make sense to you?

## Step 7: Quality metrics

- What kind of object is `QC`? Did the function write anything to disk?
- Look at `tumour_mapd` (noise in the tumour LogR) and `homdel_fraction` (fraction of the genome with homozygous deletion). Which samples stand out, and why might that be?
- Compare `GC_correction_before` with `GC_correction_after`. What do these numbers measure, and does it fit what you saw in Step 4?
- Which sample has the lowest `goodness_of_fit`? Does a high goodness of fit alone prove that a solution is correct?
