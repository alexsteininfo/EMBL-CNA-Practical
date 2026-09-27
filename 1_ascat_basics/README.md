# Part 1: ASCAT basics

We will run the full ASCAT workflow on the example data from the [ASCAT GitHub page](https://github.com/VanLoo-lab/ascat): simulated tumour/normal pairs.

If terms like BAF, LogR, purity or ploidy are new to you, check the [key concepts](../README.md#key-concepts-in-brief) in the main README.

**Code:** [ascat_basics.R](ascat_basics.R) (Steps 1–8). Open the script and run it line by line with `Ctrl+Enter`.

## Where the input data come from

In real projects you start from a BAM file and use [alleleCount](https://github.com/cancerit/alleleCount) to count reads at known SNP positions ([ASCAT reference files](https://github.com/VanLoo-lab/ascat/tree/master/ReferenceFiles/WGS)). From these counts you compute BAF and LogR. Today we skip that step and start from ready-made LogR/BAF files in [`0_data/ascat_data/`](../0_data/README.md). To keep things quick, the script only keeps **3 of the 100 samples** (S1, S62 and S63).

## Output

All paths in the scripts are relative to the repository root, which is where the R terminal in VS Code starts. If you get "file not found" errors, check with `getwd()`. Each step writes its plots to its own folder in `1_ascat_basics/results/`:

| Folder | Step |
|--------|------|
| `1_raw_before_correction/` | Step 3: raw LogR and BAF |
| `2_raw_after_correction/` | Step 4: raw data after GC and replication-timing correction |
| `3_segmentation/` | Step 5: segmentation |
| `4_ascat_fit/` | Step 6: purity/ploidy fit, copy-number profiles, sunrise plots |

The tables (`QC_metrics.txt` and the segmentation tables `*.PCFed.txt`) and the saved R objects (`ASCAT_objects.Rdata`) go to `results/data/`. **You will need `ASCAT_objects.Rdata` in Parts 2 and 3.**

## Questions

**[QUESTIONS.md](QUESTIONS.md)** lists all the questions, step by step. They are also in the script as comments.

---

**Next:** [Part 2: ASCAT advanced](../2_ascat_advanced/README.md)
