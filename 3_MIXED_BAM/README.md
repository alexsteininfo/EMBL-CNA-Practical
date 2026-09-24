# Part 3: Tumour paired with the wrong normal

[← Back to overview](../README.md)

In real projects, a tumour is sometimes paired with a normal sample from a **different patient**, for example after a sample swap in the lab or a labelling mistake. This happens more often than you would think, and you need to catch it early.

Run ASCAT on a tumour sample paired with a normal from another individual, using the same steps as in [Part 1](../1_ASCAT/README.md).

---

## Questions

- Before running anything: what do you expect to happen to the **BAF**? Remember that ASCAT uses the normal sample to decide which SNPs are heterozygous.
- Look at the raw BAF and LogR plots. What looks different compared to a correctly matched pair?
- What does ASCAT's fit look like? Would you trust it?
- How could you detect a mismatch **before** running the full analysis?

---

**Next:** [Part 4: Structural variant calling with GRIDSS and IGV](../4_GRIDDS/README.md)
