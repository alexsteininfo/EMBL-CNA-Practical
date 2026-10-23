# Part 4: Questions

Answer these while you run [run_gridss.sh](run_gridss.sh) and [list_calls.sh](list_calls.sh), and look at the calls in IGV. Folder names refer to `4_gridss/results/`.

## Step 1: Run GRIDSS (`1_gridss/`)

- How long did it take, and how much memory did it use? What would that mean for a whole genome at 30x coverage?

## Step 2: List the calls (`2_pass_calls/`)

- Each SV is reported as two breakends. Use the ALT column to pair up the PASS breakends. How many SVs do they make?

## Step 3: Inspect two calls in IGV

Load the BAM you gave to GRIDSS and `1_gridss/output.vcf`. Then look at two calls from `2_pass_calls/pass_calls.txt`: the one on **chr9**, and the one that joins **chrX and chrY**.

- What type of SV is each call (deletion, duplication, inversion, translocation)? Which evidence supports it: split reads, discordant pairs, or both?
- Load the **other** Illumina BAM (the normal, if you ran the tumour). Are the SVs there too? Are they somatic or germline?
- Do you believe both calls? If one looks **false**, what makes it look wrong?

## If you have time

- Load the tumour **PacBio** BAM from `0_data/gridss_data/`. Do the long reads span the breakpoints and confirm the calls?
- Go through the other PASS calls. What type of SV is each, and do you believe it?
