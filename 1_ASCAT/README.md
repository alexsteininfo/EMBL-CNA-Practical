# Part 1: Copy-number calling with ASCAT

[← Back to overview](../README.md)

We will run ASCAT on the example data from the [ASCAT GitHub page](https://github.com/VanLoo-lab/ascat): 100 simulated tumour/normal pairs.

If terms like BAF, LogR, purity or ploidy are new to you, first read the [key concepts](../README.md#key-concepts-in-brief) in the main README.

## Where the input data come from

In real projects you start from a BAM file and use [alleleCount](https://github.com/cancerit/alleleCount) to count reads at known SNP positions ([ASCAT reference files](https://github.com/VanLoo-lab/ascat/tree/master/ReferenceFiles/WGS)). From these counts you compute BAF and LogR. Today we skip that step and start from ready-made LogR/BAF files. If you want to try it later, see the [ASCAT example data page](https://github.com/VanLoo-lab/ascat/tree/master/ExampleData), section *"Processing targeted sequencing data"*.

## Get the data

From inside this folder (`1_ASCAT/`):

```bash
git clone https://github.com/VanLoo-lab/ascat.git
cp -r ascat/ExampleData .
```

Then, in R, set your working directory to `1_ASCAT/ExampleData` and work through the steps below. Each step has questions. Try to answer them before moving on.

---

## Step 1: Load the library

```r
library(ASCAT)
```

- Which version of ASCAT are you running?
- Which other packages are loaded with it?

## Step 2: Load the data

```r
ascat.bc <- ascat.loadData(
  Tumor_LogR_file    = "Tumor_LogR.txt",
  Tumor_BAF_file     = "Tumor_BAF.txt",
  Germline_LogR_file = "Germline_LogR.txt",
  Germline_BAF_file  = "Germline_BAF.txt",
  gender             = rep("XX", 100),
  genomeVersion      = "hg19"
)
str(ascat.bc)
```

- What does each input file contain?
- Are the samples male or female?
- How many SNPs are in these data? How many would ASCAT use for whole-genome sequencing?

## Step 3: Plot the raw data

```r
ascat.plotRawData(ascat.bc, img.prefix = "Before_correction_")
```

- Open a few of the PNG files. What does each panel show?
- Where can you already see gains, losses, or LOH by eye?

## Step 4: Correct the LogR for GC content and replication timing

```r
ascat.bc <- ascat.correctLogR(ascat.bc,
                              GCcontentfile    = "GC_example.txt",
                              replictimingfile = "RT_example.txt")
ascat.plotRawData(ascat.bc, img.prefix = "After_correction_")
```

- Compare the plots before and after the correction. What changed?
- Why would GC content or replication timing affect the number of reads?

## Step 5: Segmentation

```r
ascat.bc <- ascat.aspcf(ascat.bc)   # use penalty = 25 for targeted sequencing data
ascat.plotSegmentedData(ascat.bc)
```

- Look through several samples. How similar or different are their profiles?
- Can you spot samples that look problematic? What is wrong with them, and how might you fix it? (If you can't tell yet, come back to this question after Step 7.)

## Step 6: Fit purity and ploidy, and derive allele-specific copy number

```r
ascat.output <- ascat.runAscat(ascat.bc, write_segments = TRUE)   # use gamma = 1 for sequencing data
```

- Explore `ascat.output` and the files written to disk. What does each one represent?
- Open a *sunrise plot*. What do its axes show, and what does the chosen point mean?
- For a few samples: what purity and ploidy did ASCAT find? Do the copy-number profiles make sense to you?

## Step 7: Quality metrics

```r
QC <- ascat.metrics(ascat.bc, ascat.output)
head(QC)
write.table(QC, "QC_metrics.txt", sep = "\t", quote = FALSE, row.names = FALSE)
```

- What kind of object is `QC`?
- Look in particular at **MAPD** (a measure of noise in LogR) and the **fraction of the genome with homozygous deletion**. Which samples stand out, and why might that be?

## Step 8: Save your results

```r
save(ascat.bc, ascat.output, QC, file = "ASCAT_objects.Rdata")
```

Always save your R objects. You can reload them later with `load("ASCAT_objects.Rdata")` for reruns and troubleshooting, and **you will need them in [Part 2](../2_NOISE/README.md).**

---

## Bonus (if you have time)

These exercises go deeper into how ASCAT works.

- **The gamma parameter:** rerun `ascat.runAscat` with `gamma = 1` (and a different `img.prefix`). What is gamma? Which value fits these data better, and what does that tell you about the data?
- **Segmentation penalty:** rerun `ascat.aspcf` with a very different `penalty` (e.g. 700) and compare the segments.
- **Refitting a profile:** look at sample **S63**. Do you believe its solution? Refit it with different purity and ploidy bounds (arguments of `ascat.runAscat`). Which solution do you trust more, and how could you be sure?
- **Tumour-only mode:** run ASCAT without the matched normal, using `ascat.predictGermlineGenotypes()`. Compare with the matched run. Look at a high-purity sample with LOH (e.g. **S80**): what goes wrong, and why?

  ```r
  gg <- ascat.predictGermlineGenotypes(ascat.bc, platform = "AffySNP6")
  ascat.bc <- ascat.aspcf(ascat.bc, ascat.gg = gg, penalty = 70, out.prefix = "tumour-only")
  ascat.plotSegmentedData(ascat.bc, img.prefix = "tumour-only")
  ascat.output <- ascat.runAscat(ascat.bc, img.prefix = "tumour-only")
  ```

---

**Next:** [Part 2: How much noise can ASCAT tolerate?](../2_NOISE/README.md)
