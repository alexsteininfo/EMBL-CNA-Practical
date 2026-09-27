# Part 3: How much noise can ASCAT tolerate?

[← Back to overview](../README.md)

Noise is the main thing that decides how good a copy-number profile is. Here you will add noise to a sample on purpose and find the point where ASCAT's fit breaks down.

You will need the results of [Part 1](../1_ascat_basics/README.md) (`1_ascat_basics/results/data/ASCAT_objects.Rdata`).

**Code:** [noise_experiment.R](noise_experiment.R). At the top of the script, choose your sample (`sample_name`, one of S1, S62 and S63) and the noise levels to test (`noise_sd`).

---

## The experiment

1. Pick **one** sample from Part 1 whose fit looks good.
2. Build a new set of ASCAT input files containing that sample several times over, one copy per noise level:
   - Tumour BAF, normal BAF and normal LogR: identical copies of the original sample.
   - **Tumour LogR only:** the original values **plus Gaussian noise**, with a larger standard deviation in each copy.
3. Run the full ASCAT pipeline from Part 1 on these files.
4. Compare the profiles, the purity/ploidy estimates and the QC metrics (e.g. MAPD) across noise levels.

The noisy input files are written to `3_ascat_noise/noisy_data/`. The plots go to `3_ascat_noise/results/`, one folder per step:

| Folder | Step |
|--------|------|
| `1_added_noise/` | Step 3: noisy LogR against the original |
| `2_raw_after_correction/` | Step 4: raw data after correction |
| `3_segmentation/` | Step 4: segmentation |
| `4_ascat_fit/` | Step 4: purity/ploidy fit, copy-number profiles, sunrise plots |

`noise_comparison.txt` (Step 5) stays at the top of `results/`.

## Questions

**[QUESTIONS.md](QUESTIONS.md)** lists all the questions, step by step. They are also in the script as comments.

---

**Next:** [Part 4: Tumour paired with the wrong normal](../4_ascat_mixup/README.md)
