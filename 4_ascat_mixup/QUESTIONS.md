# Part 4: Questions

Answer these while you run [mismatched_normal.R](mismatched_normal.R) line by line. Folder names refer to `4_ascat_mixup/results/`. Answer Step 1 **before** you run anything.

## Step 1: Before running anything

- ASCAT uses the normal sample to decide which SNPs are heterozygous. Which SNPs will it pick if the normal comes from another person? What do you expect to happen to the BAF segmentation and to the fit?

## Step 3: Run ASCAT on both pairs

- **Raw data (`1_raw_after_correction/`):** compare the `*.tumour.png` plots of the two pairs. Why do they look the same? Now compare the `*.germline.png` plots. What is different?
- **Segmentation (`2_segmentation/`):** compare the BAF panels of the two pairs. ASCAT only shows the SNPs it thinks are heterozygous. Which SNPs does it use in the mismatched pair, and where do the BAF segments (blue lines) end up?
- Why is the LogR segmentation hardly affected, while the BAF is?
- **Fit (`3_ascat_fit/`):** compare the two `*.ASCATprofile.png` and `*.sunrise.png` files. How do purity and ploidy differ? Would you trust the mismatched fit if you had never seen the matched one?
- **QC:** which metrics would warn you, and which would not? Why does `n_het_SNP` change at all, when the tumour is the same?

## Step 4: Detecting a mismatch early

- How could you detect a mismatch **before** running the full analysis? Think about it first, then run the code.
- What genotype concordance do you see for the matched and for the mismatched pair? Why is the matched pair not at exactly 1?
- Look at the genotype tables. In the matched pair, which cells are not zero apart from the diagonal? What could cause them?
- Why is the number of opposite homozygotes (AA vs BB) such a strong signal?
- In the BAF-against-BAF plot (`4_genotype_check/`), where do the points of the matched pair lie? Which points in the mismatched plot give the swap away?
- In practice, tools such as somalier or NGSCheckMate run this kind of check on BAM or VCF files. At which point in a project would you run it?
