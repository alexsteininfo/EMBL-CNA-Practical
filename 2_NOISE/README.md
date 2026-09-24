# Part 2: How much noise can ASCAT tolerate?

[← Back to overview](../README.md)

Noise is the main thing that decides how good a copy-number profile is. Here you will add noise to a sample on purpose and find the point where ASCAT's fit breaks down.

This time **you design the experiment, and an AI assistant writes the code.** You are responsible for checking that the code does what you intended.

You will need the results of [Part 1](../1_ASCAT/README.md) (`ASCAT_objects.Rdata`) and its input files.

---

## The experiment

1. Pick **one** sample from Part 1 whose fit looks good.
2. Build a new set of ASCAT input files containing that sample several times over (e.g. 5 copies):
   - Tumour BAF, normal BAF and normal LogR: identical copies of the original sample.
   - **Tumour LogR only:** the original values **plus Gaussian noise**, with a larger standard deviation in each copy (R function: `rnorm`).
3. Run the full ASCAT pipeline from Part 1 on these files.
4. Compare the profiles, the purity/ploidy estimates and the QC metrics (e.g. MAPD) across noise levels.

## Working with the AI assistant

1. **Before you open the AI, write the plan down in your own words.** Which files are read, what changes, what must stay the same, and what the output should look like.
2. Give the AI your plan as the prompt. Ask it to write the R code.
3. **Check the code before you trust it.** Use this checklist:
   - [ ] Does it run without errors?
   - [ ] Does it add noise to the **tumour LogR only**, and leave the three other tracks untouched?
   - [ ] Are the output files still in the format ASCAT expects (same columns for chromosome and position, one column per sample, sensible sample names)?
   - [ ] Is the noise really increasing from one copy to the next? Check it with a quick plot or `sd()`.
   - [ ] Does the zero-noise copy give the same result as your original run from Part 1?

> Only use the public course data with AI tools. **Never paste patient data into an AI assistant.**

---

## Questions

- Design an experiment to find the noise level at which the fit starts to break. Then run it.
- What happens to the profile and to purity/ploidy when the fit breaks?
- Is ASCAT robust to noise in LogR?
- Which is more sensitive to noise, **BAF or LogR**? Why? *(Hint: think about what each one measures and how many SNPs contribute to each.)*
- Did the AI's code do what you asked? What, if anything, did you have to correct? How did you find out?

---

**Next:** [Part 3: Tumour paired with the wrong normal](../3_MIXED_BAM/README.md)
