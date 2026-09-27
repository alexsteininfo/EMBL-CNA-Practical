# Part 3: Questions

Answer these while you run [noise_experiment.R](noise_experiment.R) line by line. Folder names refer to `3_ascat_noise/results/`.

## Step 1: Before running anything

- The LogR of a typical copy-number change in Part 1 is only about ±0.3. At which of the noise levels in `noise_sd` do you expect the fit to break?
- We add noise to the tumour LogR only. Which parts of the ASCAT result do you expect to suffer most: segmentation, purity, ploidy or the allele-specific copy numbers?

## Step 3: Look at the added noise (`1_added_noise/`)

- Does the measured standard deviation match the one you asked for? Why not exactly?
- Compare the spread of the noise with the range of the original LogR (x-axis). From which noise level on is the noise larger than the signal?

## Step 4: Run ASCAT on the noisy data

- **Raw data (`2_raw_after_correction/`):** open the `*.tumour.png` files from low to high noise. Up to which noise level can you still see the copy-number changes in the LogR by eye? And in the BAF?
- **Segmentation (`3_segmentation/`):** what happens to the LogR segments (blue lines) as the noise grows? And to the BAF segments?
- **Fit:** did ASCAT fail to find a solution for any of the copies (`ascat.noise.output$failedarrays`)? Which one(s)? Is the failure where you expected it?

## Step 5: Compare the results across noise levels (`4_ascat_fit/`, `noise_comparison.txt`)

- Does the zero-noise copy give the same result as your Part 1 run? Why is that an important check?
- How does `tumour_mapd` change with the noise you added? Could you use MAPD to spot a noisy sample when you don't know how noisy it is?
- Look at purity and ploidy across the noise levels. Do they change as much as you expected?
- Open the `*.ASCATprofile.png` files for sd = 0 and for a high noise level. Would you trust the noisy profile, even where purity and ploidy look similar? Which QC value tells you something is wrong?
- At which noise level would you stop trusting the result? Would you choose the same level if you reran with another random seed?
- We only added noise to the LogR. Why do purity and ploidy survive so much of it? What would you expect if we added noise to the BAF instead? *(Hint: think about what each one measures, and which one we left untouched.)*
