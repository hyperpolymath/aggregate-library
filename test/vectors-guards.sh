#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell
#
# Regression tests for the checks in scripts/vectors.jq. Each "reject" case
# feeds one bad spec record to the filter and requires it to fail with the
# named message; each "accept" case is a positive control that must pass, so a
# filter that rejects everything cannot make this suite green.
#
# Usage: test/vectors-guards.sh     (or: just vectors-test)
# Exit codes: 0 all cases behave, 1 a case misbehaved, 2 could not run.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
command -v jq >/dev/null 2>&1 || { printf 'vectors-guards: jq not found\n' >&2; exit 2; }

ops="$(for f in specs/*/*.adoc; do basename "$f" .adoc; done | sort -u | jq -R . | jq -s -c .)"
fold_sig='fold: Collection[A], B, Function[B, A -> B] -> B'
not_sig='not: Boolean -> Boolean'
add_sig='add: Number, Number -> Number'
len_sig='length: String -> Number'

pass=0
fail=0

# run SIG SRC DOC -> prints filter output (stdout+stderr), returns jq's status
run() {
  jq -n -c --arg sig "$1" --arg src "$2" --argjson ops "$ops" --argjson doc "$3" \
     -f scripts/vectors.jq 2>&1
}

# vec INPUT_JSON OUTPUT_JSON -> a one-vector test_cases document
vec() { printf '{"test_cases":[{"input":%s,"output":%s,"description":"t"}]}' "$1" "$2"; }

reject() { # NAME SIG SRC DOC EXPECTED_SUBSTRING
  local out
  if out="$(run "$2" "$3" "$4")"; then
    printf 'FAIL reject %s: accepted\n' "$1"; fail=$((fail + 1))
  elif [[ "$out" != *"$5"* ]]; then
    printf 'FAIL reject %s: wrong error: %s\n' "$1" "$out"; fail=$((fail + 1))
  else
    printf 'ok   reject %s: %s\n' "$1" "${out#jq: error (at <unknown>): }"; pass=$((pass + 1))
  fi
}

accept() { # NAME SIG SRC DOC
  local out
  if out="$(run "$2" "$3" "$4")"; then
    printf 'ok   accept %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL accept %s: %s\n' "$1" "$out"; fail=$((fail + 1))
  fi
}

fold_src=specs/collection/fold.adoc
not_src=specs/logical/not.adoc
add_src=specs/arithmetic/add.adoc
len_src=specs/string/length.adoc

# Signature name must match the file name.
reject sig-name-mismatch 'subtract: Number, Number -> Number' "$add_src" \
  "$(vec '[1, 2]' 3)" 'signature names "subtract" but the file is "add.adoc"'
accept sig-name-match "$add_sig" "$add_src" "$(vec '[1, 2]' 3)"

# Lambda parameters must alternate identifier and comma.
reject lambda-leading-comma "$fold_sig" "$fold_src" \
  "$(vec '[[1], 0, ", acc x => add(acc, x)"]' 1)" 'bad lambda parameter list'
reject lambda-double-comma "$fold_sig" "$fold_src" \
  "$(vec '[[1], 0, "acc,, x => add(acc, x)"]' 1)" 'bad lambda parameter list'
reject lambda-trailing-comma "$fold_sig" "$fold_src" \
  "$(vec '[[1], 0, "acc, x, => add(acc, x)"]' 1)" 'bad lambda parameter list'
reject lambda-missing-comma "$fold_sig" "$fold_src" \
  "$(vec '[[1], 0, "acc x => add(acc, x)"]' 1)" 'bad lambda parameter list'
accept lambda-well-formed "$fold_sig" "$fold_src" \
  "$(vec '[[1], 0, "acc, x => add(acc, x)"]' 1)"

# Boolean arguments: true, false or a condition string only.
reject boolean-null "$not_sig" "$not_src" "$(vec '[null]' true)" 'must be true, false or a condition string'
reject boolean-number "$not_sig" "$not_src" "$(vec '[1]' false)" 'must be true, false or a condition string'
accept boolean-literal "$not_sig" "$not_src" "$(vec '[true]' false)"
accept boolean-condition "$not_sig" "$not_src" "$(vec '["equal(1, 2)"]' true)"

# Values jq cannot write in JCS (RFC 8785) form.
reject number-small-fraction "$add_sig" "$add_src" "$(vec '[0.0000001, 0]' 0.0000001)" 'exponent form'
reject number-1e-5 "$add_sig" "$add_src" "$(vec '[0.00001, 0]' 0.00001)" 'exponent form'
reject number-large-int "$add_sig" "$add_src" \
  "$(vec '[100000000000000000000, 0]' 100000000000000000000)" 'I-JSON integer range'
reject number-2pow53 "$add_sig" "$add_src" "$(vec '[9007199254740992, 0]' 9007199254740992)" 'I-JSON integer range'
reject string-del "$len_sig" "$len_src" "$(vec '["a\u007f"]' 2)" 'contains U+007F'
accept number-safe-max "$add_sig" "$add_src" "$(vec '[9007199254740991, 0]' 9007199254740991)"
accept number-fractions "$add_sig" "$add_src" "$(vec '[2.5, 0.0001]' 2.5001)"
accept string-non-ascii "$len_sig" "$len_src" "$(vec '["é"]' 1)"

printf 'vectors-guards: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
