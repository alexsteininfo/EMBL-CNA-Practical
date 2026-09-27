# Part 5: Questions

Answer these while you run [run_gridss.sh](run_gridss.sh) and [list_calls.sh](list_calls.sh), and look at the calls in IGV. Folder names refer to `5_gridds/results/`.

## Step 1: Run GRIDSS (`1_gridss/`)

- How long did it take, and how much memory did it use? What would that mean for a whole genome at 30x coverage?
- Look at the files GRIDSS wrote to `1_gridss/`. Which one holds the SV calls, and what is in the others?

## Step 2: List the calls (`2_pass_calls/`)

- How many breakends are there in total, and how many PASS? What might the filtered ones be?
- Each SV is reported as two breakends. Use the ALT column to pair them up. How many SVs do the PASS breakends make? Are there single breakends?
- Which calls look most convincing from their QUAL score alone?

## Step 3: Inspect the calls in IGV

Load the BAM you gave to GRIDSS and `1_gridss/output.vcf`, then go to each region in `2_pass_calls/pass_calls.txt`.

- What type of SV is it (deletion, duplication, inversion, translocation)? Does that match what the ALT column told you?
- Which evidence supports it: split reads, discordant pairs, or both? How many reads?
- Does the QUAL score agree with how convincing the reads look?
- Load the matching **PacBio** BAM from `0_data/gridds_data/`. Do the long reads span the breakpoint and confirm the call?
- Load the **other** Illumina BAM (normal if you ran the tumour, or the other way round). Is the SV there too? Is it somatic or germline?
- Do you believe each call? What would make you more or less confident?
- Can you find a call you think is **false**? What makes it look wrong?
