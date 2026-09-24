# Part 4: Structural variant calling with GRIDSS and IGV

[← Back to overview](../README.md)

Copy-number callers look at how much DNA there is. SV callers look at **how the DNA is joined together**. [GRIDSS2](https://github.com/PapenfussLab/gridss) finds rearrangements from three types of evidence in aligned short reads:

- **Split reads:** one read whose two parts align to two different places in the genome.
- **Discordant read pairs:** the two reads of a pair align too far apart, on different chromosomes, or in the wrong orientation.
- **Assembly:** GRIDSS reassembles the reads around a candidate breakpoint to reconstruct the new DNA sequence.

GRIDSS can also report **single breakends**, where only one side of the breakpoint can be placed, for example because the other side falls in a repetitive region such as a centromere.

---

## Run GRIDSS

```bash
gridss \
  --jvmheap 10g \
  -r <reference.fa> \
  -o output.vcf \
  <sample.bam>
```

Replace `<reference.fa>` and `<sample.bam>` with the paths to the reference genome and the BAM file on the VM.

- How long does it take, and how much memory does it use? What would that mean for a whole genome?

## Inspect the calls in IGV

Open IGV and load:

1. The **same BAM file** you just gave to GRIDSS.
2. The VCF file GRIDSS produced (`output.vcf`).

Go to each SV call and look at the reads around it.

- What type of SV is it (deletion, duplication, inversion, translocation)?
- Which evidence supports it: split reads, discordant pairs, or both? How many reads?
- Do you believe the call? What would make you more or less confident?
- Can you find a call you think is **false**? What makes it look wrong?

> **IGV tips:** colour alignments by *insert size and pair orientation* to make discordant pairs stand out, and turn on *show soft-clipped bases* to see where split reads break.

---

[← Back to overview](../README.md)
