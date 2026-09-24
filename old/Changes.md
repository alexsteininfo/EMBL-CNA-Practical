# Variant calling: CNVs & SVs — Practical session (2026)

**Genome Bioinformatics 2026 (EMBL-EBI), Day 3**
Maxime Tarabichi — maxime.tarabichi@ulb.be

This repository contains the hands-on practical on copy-number aberration (CNA) and structural variant (SV) calling. Open it in VS Code on the course virtual machine and work through the parts in order.

---

## Learning goals

By the end of the practical you should be able to answer four questions:

1. **Copy number:** what signal are we measuring? (BAF + LogR → segmentation → allele-specific copy number)
2. **Uncertainty:** when does that signal become unreliable? (noise, bad samples, purity/ploidy ambiguity)
3. **Structural variants:** how does an SV caller detect a rearrangement from aligned reads? (split reads, discordant pairs, assembly)
4. **Evidence:** how do you check whether a call is real? (manual inspection in IGV)

The aim is to understand how CNA and SV callers work, not to memorise one tool. ASCAT and GRIDSS are the examples; the same principles apply to other callers.

---

## Structure (2 h)

| Part | Topic | Time |
|------|-------|------|
| 0 | Setup: open the repo in VS Code, check R and paths | ~5 min |
| 1 | Copy-number calling with ASCAT | ~50 min |
| 2 | Copy-number uncertainty: noise and mismatched samples | ~25 min |
| 3 | SV calling with GRIDSS2 and inspection in IGV | ~35 min |
| — | Wrap-up | ~5 min |
| Bonus | AI-assisted coding, ASCAT internals, ASCAT.sc | if time allows |

### Part 1 — Copy number (ASCAT)
Load data → plot raw BAF/LogR → GC and replication-timing correction → segmentation → purity/ploidy fitting → QC metrics → save objects.

### Part 2 — Copy-number uncertainty
- **Noise experiment:** add increasing Gaussian noise to the tumour LogR and find where the fit breaks. Which is more sensitive to noise, BAF or LogR, and why?
- **Mismatched tumour/normal (new):** run ASCAT on a tumour paired with a normal from a different patient. How can you detect this early?

### Part 3 — Structural variants (GRIDSS2 + IGV)
Run GRIDSS2 on a short-read BAM, then open the **same BAM and the resulting VCF** in IGV. For each call, identify the supporting evidence (split reads, discordant pairs) and decide whether you believe it.

### Bonus
- **AI-assisted coding:** after writing the noise experiment yourself, ask an AI assistant (e.g. GitHub Copilot in VS Code) to write it. Compare the two versions: does the AI's code run, does it modify the right track (tumour LogR only), and does it keep the files ASCAT-compatible? *Is the AI's code correct, and how do you know?*
- **ASCAT internals:** gamma parameter, refitting sample S63 with new purity/ploidy bounds, tumour-only mode.
- **Single-cell copy number:** a short ASCAT.sc demonstration.

---

## Summary of changes from the 2025 practical

### Structure
- The practical is reorganised from a sequence of tools into four questions: signal, uncertainty, SV detection, evidence.
- The core path is shorter, so the key concepts fit into 2 hours; advanced material is now clearly marked as bonus.

### Copy number
- **Kept:** the full ASCAT workflow and the noise experiment, which remains a central exercise.
- **New:** a mismatched tumour/normal exercise. This was promised in the 2025 introduction but had no corresponding exercise.
- **Moved to bonus:** the gamma exercise, refitting (S63) and tumour-only mode. These are interesting but ASCAT-specific rather than transferable to other callers.
- **Moved to bonus:** ASCAT.sc. It introduces many new concepts at once (single-cell data, phasing, binning) and is better as a short demonstration.
- **Fixed:** the LogR formula now has correct brackets: `LogR = log2( (Cr+Ca) / mean(Cr+Ca) )`.
- **Fixed:** the step 6 bonus asked to rerun `runAscat` with a different *penalty*, but penalty is a segmentation (`aspcf`) parameter. It now asks for different purity/ploidy bounds.

### Structural variants
- **Fixed:** in 2025, GRIDSS ran on a chr3 (3q29) BAM while the IGV exercise used a different sample and region (chr17, TP53), so students never inspected their own calls. GRIDSS calls and IGV inspection now use the same data.
- **New:** guiding questions for the GRIDSS/IGV part, matching the ASCAT part.
- **Removed:** long-read SV calling, which is covered in a separate session. *To decide with that session's teacher:* drop the short- vs long-read TP53 comparison, or keep it as a short bridge to their session.

### AI component (new, bonus)
- A short, structured exercise in which students first write code by hand, then compare it with AI-generated code. The point is that AI helps with boilerplate but cannot judge whether a copy-number fit or SV call is biologically correct.
- Use only the public course data with AI tools, never patient data.

### Environment
- The practical is now a GitHub repository opened in VS Code with the R extension, instead of a PDF.
- Relative paths replace hardcoded ones (e.g. `/media/penelopeCloud`).
- Large files (BAMs, references) stay on the VM, outside the repository.
- Tool versions are recorded below for reproducibility.

---

## Software (preinstalled on the VM)

| Tool | Source | Version |
|------|--------|---------|
| R | https://www.r-project.org/ | _fill in_ |
| ASCAT | https://github.com/VanLoo-lab/ascat | _fill in_ |
| ASCAT.sc | https://github.com/VanLoo-lab/ASCAT.sc | _fill in_ |
| GRIDSS2 | https://github.com/PapenfussLab/gridss | _fill in_ |
| IGV | https://igv.org/ | _fill in_ |
| mosdepth | https://github.com/brentp/mosdepth | _fill in_ |
| samtools | https://github.com/samtools/samtools | _fill in_ |
| VS Code + R extension | https://code.visualstudio.com/ | _fill in_ |

**Dependencies:**
- GRIDSS2 needs Java and BWA, and the reference FASTA must be BWA-indexed.
- The VS Code R extension needs the R packages `languageserver` and (recommended, for plots) `httpgd`.
- git, to clone this repository.

---

## Repository layout

```
.
├── README.md
├── 01_ascat/          # Part 1: copy-number calling
├── 02_uncertainty/    # Part 2: noise and mismatched-sample experiments
├── 03_gridss/         # Part 3: SV calling and IGV inspection
├── bonus/             # AI exercise, ASCAT internals, ASCAT.sc
└── data/              # small example files only; large files live on the VM
```

## Getting started

```bash
git clone <repository-url>
cd <repository-name>
code .
```

Then open `01_ascat/` and follow the instructions there.
