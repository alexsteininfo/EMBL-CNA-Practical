# Part 4: Tumour paired with the wrong normal

[← Back to overview](../README.md)

In real projects, a tumour is sometimes paired with a normal sample from a **different patient**, for example after a sample swap in the lab or a labelling mistake. This happens more often than you would think, and you need to catch it early.

**Code:** [mismatched_normal.R](mismatched_normal.R). It takes one tumour from the Part 1 example data and pairs it twice: with its own normal, and with the normal of another patient. Then it runs ASCAT on both pairs, using the same steps as in [Part 1](../1_ascat_basics/README.md).

The plots go to `4_ascat_mixup/results/`, one folder per step: `1_raw_after_correction/`, `2_segmentation/`, `3_ascat_fit/` and `4_genotype_check/`.

## Questions

**[QUESTIONS.md](QUESTIONS.md)** lists all the questions, step by step. They are also in the script as comments. Answer the first one **before** you run the script.

---

**Next:** [Part 5: Structural variant calling with GRIDSS and IGV](../5_gridds/README.md)
