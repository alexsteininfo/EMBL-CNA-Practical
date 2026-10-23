#!/usr/bin/env bash
###############################################################################
# Part 4, step 2: list the GRIDSS calls you will inspect in IGV
#
# Run from the repository root:   bash 4_gridss/list_calls.sh
###############################################################################

set -euo pipefail

VCF="4_gridss/results/1_gridss/output.vcf"   # written by run_gridss.sh
OUT_DIR="4_gridss/results/2_pass_calls"
mkdir -p "${OUT_DIR}"

# How many breakends did GRIDSS report, and how many passed its filters?
echo "Breakends in total:   $(grep -vc '^#' "${VCF}")"
echo "Breakends with PASS:  $(grep -v '^#' "${VCF}" | awk '$7 == "PASS"' | wc -l)"
echo

# One line per PASS breakend. GRIDSS reports every SV as two breakends
# (one at each side of the junction); the ALT column tells you where the
# other side is. For example:
#   G[chr3:198000000[   the sequence continues at chr3:198,000,000
#   .G  or  G.          a single breakend: the other side could not be placed
#
# The REGION column is a +-500 bp window you can paste into the IGV search box.
# The table is also saved to 4_gridss/results/2_pass_calls/pass_calls.txt.
{
  printf "%-8s %-12s %-35s %8s  %s\n" CHROM POS ALT QUAL REGION
  grep -v '^#' "${VCF}" | awk '$7 == "PASS"' | \
    awk '{ start = ($2 > 500) ? $2 - 500 : 1;
           printf "%-8s %-12s %-35s %8.0f  %s:%d-%d\n", $1, $2, $5, $6, $1, start, $2 + 500 }'
} | tee "${OUT_DIR}/pass_calls.txt"

# Q: Each SV is reported as two breakends. Use the ALT column to pair up
#    the PASS breakends. How many SVs do they make?
#    Then check two of them in IGV (see 4_gridss/QUESTIONS.md).
