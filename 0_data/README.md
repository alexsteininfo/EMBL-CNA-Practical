# Input data

This folder holds the input data for the practical. All data are public and can be downloaded without registration or a data access agreement: simulated data (ASCAT) and commercially available reference cell lines (GRIDSS).

| Folder | Used in | Size |
|--------|---------|------|
| [ascat_data/](ascat_data/) | Parts 1–4 (ASCAT) | ~30 MB |
| [gridds_data/](gridds_data/) | Part 5 (GRIDSS + IGV) | ~13 MB |

---

## ascat_data

**Source:** the example data shipped with ASCAT, in the [ExampleData folder of the ASCAT GitHub repository](https://github.com/VanLoo-lab/ascat/tree/master/ExampleData).

**Contents:** 100 **simulated** tumour/normal pairs (samples `S1`–`S100`, all female), 10,000 SNPs on chromosomes 1–22 and X, genome build **hg19**.

| File | What it contains |
|------|------------------|
| `Tumor_LogR.txt` | LogR of each tumour sample at each SNP |
| `Tumor_BAF.txt` | B-allele frequency of each tumour sample at each SNP |
| `Germline_LogR.txt` | LogR of the matched normal samples |
| `Germline_BAF.txt` | B-allele frequency of the matched normal samples |
| `GC_example.txt` | GC content around each SNP, used to correct LogR |
| `RT_example.txt` | Replication timing at each SNP, used to correct LogR |

The four LogR/BAF files are tab-separated: one row per SNP (SNP ID, `chrs`, `pos`) and one column per sample. All six files cover the same SNPs in the same order.


---

## gridds_data

**Source:** the [SEQC2 Somatic Mutation Working Group](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/seqc/Somatic_Mutation_WG/) reference data on the NCBI FTP server (Fang et al. 2021, *Nat Biotechnol*; Talsania et al. 2022, *Genome Biol*). The samples are two commercially available cell lines from the same donor:

- **HCC1395:** breast cancer cell line (tumour)
- **HCC1395BL:** B-lymphocyte cell line (matched normal)

**How it was made:** the full BAMs are 65–115 GB each, so only the reads within ±5 kb of five somatic structural variants were extracted and downloaded. Regions with preidentified SVs were picked.

| File | Reads | Original file on the FTP server |
|------|-------|---------------------------------|
| `HCC1395_tumour_illumina.bam` | Illumina WGS, tumour | `data/WGS/WGS_EA_T_1.bwa.dedup.bam` |
| `HCC1395BL_normal_illumina.bam` | Illumina WGS, normal | `data/WGS/WGS_EA_N_1.bwa.dedup.bam` |
| `HCC1395_tumour_pacbio.bam` | PacBio, tumour | `analysis/SVs/BAMs/tumor.pacbio.PBMM2.bam` |
| `HCC1395BL_normal_pacbio.bam` | PacBio, normal | `analysis/SVs/BAMs/normal.pacbio.PBMM2.bam` |

Each BAM is sorted and has its index (`.bai`) next to it. Keep the two together.

- The **Illumina** BAMs are the input for GRIDSS. They were aligned with `bwa mem` to **GRCh38.d1.vd1**.
- The **PacBio** BAMs are for checking calls in IGV: long reads often span the whole breakpoint. They were aligned with minimap2 to hg38.

The list of SVs in the extracted regions is kept out of this folder on purpose. Finding them is the exercise.

### Reference genome (not included)

GRIDSS needs the exact reference the Illumina BAMs were aligned to: `GRCh38.d1.vd1.fa` from the [GDC reference files page](https://gdc.cancer.gov/about-data/gdc-data-processing/gdc-reference-files) (0.9 GB download, ~3.2 GB unpacked). Put the downloaded `GRCh38.d1.vd1.fa.tar.gz` in `reference/` at the repository root, then unpack and index it once with:

```bash
bash 5_gridds/prepare_reference.sh
```

This builds the FASTA index, the BWA index (about 1 hour) and the sequence dictionary next to the FASTA file. You can also download the GDC's pre-built BWA index (3.5 GB) into `reference/` instead; the script then skips the BWA step.

