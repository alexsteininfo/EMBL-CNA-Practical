# Variant calling: copy-number aberrations & structural variants

**Genome Bioinformatics 2026 (EMBL-EBI), Day 3: practical session**

In this practical you will call **copy-number aberrations (CNAs)** in tumour samples with ASCAT, see how that call fails when the data are noisy or the samples are mismatched, and then call **structural variants (SVs)** with GRIDSS and check them by eye in IGV.

You don't need to be an experienced programmer. Most of the code is given to you. Your job is to run it, look closely at what comes out, and answer the questions. **The questions matter more than the code.**

---

## What you will learn

By the end of the practical you should be able to answer four questions:

1. **Signal:** what do we actually measure to call copy number? (BAF + LogR → segmentation → allele-specific copy number)
2. **Uncertainty:** when does that signal become unreliable? (noise, mismatched samples, purity/ploidy ambiguity)
3. **Structural variants:** how does an SV caller find a rearrangement in aligned reads? (split reads, discordant read pairs, assembly)
4. **Evidence:** how do you decide whether a call is real? (inspecting the reads yourself in IGV)

ASCAT and GRIDSS are just the examples here. Other callers, such as [Battenberg](https://github.com/Wedge-lab/battenberg) for copy number, work on the same principles, so what you learn today carries over to them.

---

## The practical, part by part

Work through the parts in order. Each folder has its own README with the instructions and questions.

| Part | Folder | What you do |
|------|--------|-------------|
| 1 | [1_ASCAT/](1_ASCAT/README.md) | Run the full ASCAT workflow: raw data → correction → segmentation → purity/ploidy fit → QC. |
| 2 | [2_NOISE/](2_NOISE/README.md) | Add increasing noise to a sample and find where the fit breaks. You design the experiment; an AI assistant writes the code, and you check it. |
| 3 | [3_MIXED_BAM/](3_MIXED_BAM/README.md) | Pair a tumour with a normal from another patient and learn to recognise the mismatch. |
| 4 | [4_GRIDDS/](4_GRIDDS/README.md) | Call SVs with GRIDSS and inspect the evidence for each call in IGV. |

Bonus exercises on ASCAT internals are at the end of [Part 1](1_ASCAT/README.md#bonus-if-you-have-time).

---

## Key concepts in brief

You will meet these terms throughout. Come back here whenever you need to.

| Term | What it means |
|------|---------------|
| **SNP** | A position in the genome where people commonly differ (e.g. some carry an A, others a G). ASCAT only looks at these positions. |
| **Heterozygous SNP** | A SNP where you inherited a different base from each parent. These are the informative ones: they let us tell the two parental copies apart. |
| **LogR** | How many reads cover a position compared to the genome average, on a log2 scale. More DNA gives a higher LogR. It tells you about **total** copy number. |
| **BAF** (B-allele frequency) | At a SNP, the fraction of reads carrying the alternative base. In normal cells a heterozygous SNP has BAF ≈ 0.5. If one parental copy is gained or lost, the BAF moves away from 0.5. It tells you about the **balance** between the two parental copies. |
| **Segmentation** | Grouping neighbouring SNPs into stretches (segments) that share the same copy number. |
| **Purity** | The fraction of cells in the sample that are tumour cells. The rest are normal cells that dilute the signal. |
| **Ploidy** | The average number of DNA copies across the tumour genome (≈2 for a normal diploid cell, often 3–4 in tumours). |
| **Allele-specific copy number** | The number of copies of **each** parental allele in a segment, e.g. 2+0 means two copies of one parent's chromosome and none of the other (copy-neutral loss of heterozygosity, LOH). |
| **Structural variant (SV)** | A rearrangement of the genome: deletion, duplication, inversion, or translocation. The point where the DNA is joined in a new way is the **breakpoint**. |

How LogR and BAF are computed from read counts. *Cr* and *Ca* are the numbers of reads carrying the reference and alternative base at a SNP:

```
BAF   = Ca / (Cr + Ca)
LogR  = log2( (Cr + Ca) / mean(Cr + Ca) )
LogR (tumour, corrected for normal) = LogR_tumour − LogR_normal
```

---

## Getting started

Everything you need (R, ASCAT, GRIDSS, IGV, samtools) is already installed on the course virtual machine.

```bash
git clone <repository-url>
cd <repository-name>
code .
```

This opens the repository in VS Code. Open the R files in each folder and run them **line by line**: put the cursor on a line and press `Ctrl+Enter` (`Cmd+Enter` on a Mac). Look at the objects you create as you go.

A first check in the R console:

```r
sessionInfo()      # Which version of R are you running?
```

> **Tip:** `str(x)` shows what is inside an object, `head(x)` shows its first rows, and `?functionName` opens the help page for a function.

Large files (BAMs, reference genomes) stay on the VM, outside this repository.

Then start with **[Part 1](1_ASCAT/README.md)**.

---

## Software

All tools are preinstalled on the VM. To install them on your own machine, follow the instructions on each project's page.

| Tool | Source | Version |
|------|--------|---------|
| R | https://www.r-project.org/ | _fill in_ |
| ASCAT | https://github.com/VanLoo-lab/ascat | _fill in_ |
| GRIDSS2 | https://github.com/PapenfussLab/gridss | _fill in_ |
| IGV | https://igv.org/ | _fill in_ |
| samtools | https://github.com/samtools/samtools | _fill in_ |
| VS Code + R extension | https://code.visualstudio.com/ | _fill in_ |

**Dependencies:**
- GRIDSS2 needs Java and BWA, and the reference FASTA must be BWA-indexed.
- The VS Code R extension needs the R packages `languageserver` and (recommended, for plots) `httpgd`.

---

## Credits

Based on the practical material by Maxime Tarabichi (maxime.tarabichi@ulb.be).
