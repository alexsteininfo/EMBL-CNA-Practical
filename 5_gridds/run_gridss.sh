#!/usr/bin/env bash
###############################################################################
# Part 5, step 1: call structural variants with GRIDSS2
#
# Run from the repository root:   bash 5_gridds/run_gridss.sh
#
# By default GRIDSS runs on the tumour Illumina BAM. To run it on the matched
# normal instead, change BAM= below to HCC1395BL_normal_illumina.bam. All BAMs
# are in 0_data/gridds_data/ (see 0_data/README.md). The reference must be
# prepared once with 5_gridds/prepare_reference.sh.
###############################################################################

set -euo pipefail

BAM="0_data/gridds_data/HCC1395_tumour_illumina.bam"   # aligned short reads (sorted and indexed)
REFERENCE="reference/GRCh38.d1.vd1.fa"   # the genome the BAM was aligned to

OUT_DIR="5_gridds/results/1_gridss"   # step 1; list_calls.sh writes to 2_pass_calls/
THREADS=4

# ---- Find GRIDSS -------------------------------------------------------------
# On the course VM, gridss is already on the PATH. For a manual installation,
# GRIDSS_DIR is the folder that holds the gridss script and its jar.
GRIDSS_DIR="${GRIDSS_DIR:-${HOME}/tools/gridss-2.13.2}"
if ! command -v gridss > /dev/null && [[ -x "${GRIDSS_DIR}/gridss" ]]; then
  export PATH="${GRIDSS_DIR}:${PATH}"
fi
if ! command -v gridss > /dev/null; then
  echo "Error: gridss not found. Set GRIDSS_DIR to the folder that holds the gridss script." >&2
  exit 1
fi

# The gridss script needs to know where its jar is. It sits next to the script.
if [[ -z "${GRIDSS_JAR:-}" ]]; then
  gridss_script="$(command -v gridss)"
  gridss_script="$(readlink -f "${gridss_script}" 2> /dev/null || echo "${gridss_script}")"
  GRIDSS_JAR="$(ls "$(dirname "${gridss_script}")"/gridss-*-jar-with-dependencies.jar 2> /dev/null | head -n 1 || true)"
  export GRIDSS_JAR
fi
if [[ ! -f "${GRIDSS_JAR}" ]]; then
  echo "Error: GRIDSS jar not found. Set GRIDSS_JAR to the gridss-*-jar-with-dependencies.jar file." >&2
  exit 1
fi

# On macOS, the gridss script needs GNU getopt (brew install gnu-getopt).
for d in /opt/homebrew/opt/gnu-getopt/bin /usr/local/opt/gnu-getopt/bin; do
  if [[ -d "${d}" ]]; then export PATH="${d}:${PATH}"; break; fi
done

for tool in java bwa samtools Rscript; do
  command -v "${tool}" > /dev/null || { echo "Error: ${tool} not found on PATH" >&2; exit 1; }
done

# ---- Check the inputs --------------------------------------------------------
if [[ ! -s "${BAM}" ]]; then
  echo "Error: BAM file '${BAM}' not found. Check BAM= at the top of this script." >&2
  exit 1
fi

for suffix in fai sa dict; do
  if [[ ! -s "${REFERENCE}.${suffix}" ]]; then
    echo "Error: ${REFERENCE}.${suffix} not found. Run: bash 5_gridds/prepare_reference.sh" >&2
    exit 1
  fi
done

mkdir -p "${OUT_DIR}"

# 'time' reports how long GRIDSS takes. Watch the memory use in a second
# terminal with:  top   (press q to quit)
time gridss \
  --jvmheap 10g \
  --threads "${THREADS}" \
  --reference "${REFERENCE}" \
  --workingdir "${OUT_DIR}/working" \
  --assembly "${OUT_DIR}/assembly.bam" \
  --output "${OUT_DIR}/output.vcf" \
  "${BAM}"

echo "Done. SV calls: ${OUT_DIR}/output.vcf"
# Q: How long did it take, and how much memory did it use?
#    What would that mean for a whole genome at 30x coverage?
