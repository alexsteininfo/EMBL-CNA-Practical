# Part 4: Structural variant calling with GRIDSS and IGV

[← Back to overview](../README.md)

Copy-number callers look at how much DNA there is. SV callers look at **how the DNA is joined together**. [GRIDSS2](https://github.com/PapenfussLab/gridss) finds rearrangements from three types of evidence in aligned short reads:

- **Split reads:** one read whose two parts align to two different places in the genome.
- **Discordant read pairs:** the two reads of a pair align too far apart, on different chromosomes, or in the wrong orientation.
- **Assembly:** GRIDSS reassembles the reads around a candidate breakpoint to reconstruct the new DNA sequence.

GRIDSS can also report **single breakends**, where only one side of the breakpoint can be placed, for example because the other side falls in a repetitive region such as a centromere.

---

## Run GRIDSS

The reference genome must be unpacked and indexed once before the first run (about 1 hour; see [0_data/README.md](../0_data/README.md#reference-genome-not-included)):

```bash
bash 4_gridss/prepare_reference.sh
```

**Code:** [run_gridss.sh](run_gridss.sh). It runs on the tumour Illumina BAM (`0_data/gridss_data/HCC1395_tumour_illumina.bam`); to use the normal instead, change `BAM=` at the top. In a terminal at the repository root:

```bash
bash 4_gridss/run_gridss.sh
```

The SV calls are written to `4_gridss/results/1_gridss/output.vcf`.

## Inspect the calls in IGV

First, get a list of the calls that passed GRIDSS's filters:

```bash
bash 4_gridss/list_calls.sh
```

It prints one line per breakend, with a region you can paste into the IGV search box, and saves the same table to `4_gridss/results/2_pass_calls/pass_calls.txt`.

Then open IGV and load:

1. The **same BAM file** you just gave to GRIDSS.
2. The VCF file GRIDSS produced (`4_gridss/results/1_gridss/output.vcf`).

Go to the two calls named in [QUESTIONS.md](QUESTIONS.md) (chr9, and chrX–chrY) and look at the reads around them. To check them further, also load the other Illumina BAM and, if you have time, the PacBio BAMs from `0_data/gridss_data/`.

> **IGV tips:** colour alignments by *insert size and pair orientation* to make discordant pairs stand out, and turn on *show soft-clipped bases* to see where split reads break.

## Questions

**[QUESTIONS.md](QUESTIONS.md)** lists all the questions, step by step.

---

[← Back to overview](../README.md)
