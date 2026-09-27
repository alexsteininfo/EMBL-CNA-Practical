# Part 2: ASCAT advanced

[← Back to overview](../README.md)

Here we go deeper into how ASCAT works: what its main parameters do, what to do when you don't believe a solution, and what changes when there is no matched normal.

You will need the results of [Part 1](../1_ascat_basics/README.md) (`1_ascat_basics/results/data/ASCAT_objects.Rdata`).

**Code:** [ascat_advanced.R](ascat_advanced.R) (Steps 1–4). Open the script and run it line by line with `Ctrl+Enter`.

## Output

Each step writes its plots to its own folder in `2_ascat_advanced/results/`. You will compare them with the Part 1 plots in `1_ascat_basics/results/`.

| Folder | Step |
|--------|------|
| `1_gamma1/` | Step 1, **the gamma parameter:** rerun the fit with `gamma = 1`. |
| `2_penalty700/` | Step 2, **segmentation penalty:** rerun the segmentation with a much higher `penalty`. |
| `3_refit/` | Step 3, **refitting a profile:** refit sample S63 with different purity and ploidy bounds. |
| `4_tumour_only/` | Step 4, **tumour-only mode:** run ASCAT without the matched normal. |

## Questions

**[QUESTIONS.md](QUESTIONS.md)** lists all the questions, step by step. They are also in the script as comments.

---

**Next:** [Part 3: How much noise can ASCAT tolerate?](../3_ascat_noise/README.md)
