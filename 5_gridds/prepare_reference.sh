#!/usr/bin/env bash
###############################################################################
# Part 5, step 0: prepare the reference genome for GRIDSS (once-off)
#
# Run from the repository root:   bash 5_gridds/prepare_reference.sh
#
# GRIDSS needs the exact reference the Illumina BAMs were aligned to
# (GRCh38.d1.vd1, see 0_data/README.md), unpacked and indexed. This script:
#   1. unpacks GRCh38.d1.vd1.fa.tar.gz
#   2. builds the FASTA index        (samtools faidx, a few seconds)
#   3. builds the BWA index          (bwa index, about 1 hour, ~5 GB memory)
#   4. builds the sequence dictionary (samtools dict, a few seconds)
# Steps whose output already exists are skipped, so you can safely rerun
# the script after an interruption.
###############################################################################

set -euo pipefail

REF_DIR="${REF_DIR:-reference}"
REFERENCE="${REF_DIR}/GRCh38.d1.vd1.fa"
ARCHIVE="${REFERENCE}.tar.gz"

for tool in tar samtools bwa; do
  command -v "${tool}" > /dev/null || { echo "Error: ${tool} not found on PATH" >&2; exit 1; }
done

# 1. Unpack. The archive holds a single file, GRCh38.d1.vd1.fa (~3.2 GB).
if [[ ! -s "${REFERENCE}" ]]; then
  echo "Unpacking ${ARCHIVE}"
  tar -xzf "${ARCHIVE}" -C "${REF_DIR}"
fi

# 2. FASTA index (.fai): lets tools jump to any position in the genome.
if [[ ! -s "${REFERENCE}.fai" ]]; then
  echo "Building FASTA index"
  samtools faidx "${REFERENCE}"
fi

# 3. BWA index (.amb .ann .bwt .pac .sa): GRIDSS uses bwa to realign reads.
# bwa writes .sa last, so an interrupted run is detected and restarted.
if [[ ! -s "${REFERENCE}.sa" ]]; then
  echo "Building BWA index (about 1 hour)"
  time bwa index "${REFERENCE}"
fi

# 4. Sequence dictionary (.dict): the names and lengths of all chromosomes.
# GRIDSS looks for it as GRCh38.d1.vd1.fa.dict.
if [[ ! -s "${REFERENCE}.dict" ]]; then
  echo "Building sequence dictionary"
  samtools dict "${REFERENCE}" -o "${REFERENCE}.dict"
fi

echo "Done. Reference ready for GRIDSS: ${REFERENCE}"
