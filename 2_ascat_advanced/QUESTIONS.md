# Part 2: Questions

Answer these while you run [ascat_advanced.R](ascat_advanced.R) line by line. Folder names refer to `2_ascat_advanced/results/`; the Part 1 plots are in `1_ascat_basics/results/`.

## Step 1: The gamma parameter (`1_gamma1/`)

- What is the gamma parameter? (Hint: `?ascat.runAscat`)
- What value should you use for sequencing data?
- Compare `fit_default` and `fit_gamma1` for each sample. Is one value better for all three? How can you tell?
- What does that tell you about how these data were generated?

## Step 2: The segmentation penalty (`2_penalty700/`)

- Compare the plots in `1_ascat_basics/results/3_segmentation/` with those in `2_penalty700/`. What does the penalty control?
- What do you gain and what do you lose with a very high penalty?

## Step 3: Refitting a profile (`3_refit/`)

- Look at `S63.ASCATprofile.png` and `S63.sunrise.png` in `1_ascat_basics/results/4_ascat_fit/`. Is the chosen point (the cross) in the best (darkest blue) area of the sunrise plot? Where else is there a good area?
- Do you believe this solution? Why (not)?
- Did the refit change anything? If not, which bounds do you have to change so that ASCAT picks the other good area of the sunrise plot?
- Compare `S63.ASCATprofile.png` in `1_ascat_basics/results/4_ascat_fit/` and `3_refit/`. Which solution do you think is better?
- How could you find out for sure which one is correct? (Hint: what extra data or experiment would settle it?)

## Step 4: Tumour-only mode (`4_tumour_only/`)

- Open the `tumorSep*.png` files. What do the colours show? Which SNPs does ASCAT consider heterozygous?
- Do the results with and without the normal agree for these samples? Compare the `*.ASCATprofile.png` files in `1_ascat_basics/results/4_ascat_fit/` and `4_tumour_only/`.
- In other samples, tumour-only mode sometimes finds a solution with about double (or half) the ploidy of the matched run. Why are these two solutions so hard to tell apart from the data alone?
