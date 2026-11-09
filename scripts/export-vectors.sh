#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell
#
# Export the executable test vectors in specs/<category>/<op>.adoc to
# vectors/<category>.json, one file per category.
#
# Usage:
#   scripts/export-vectors.sh            regenerate vectors/*.json
#   scripts/export-vectors.sh --check    regenerate into a temporary
#                                        directory and fail if the result
#                                        differs from vectors/ (drift check)
#   scripts/export-vectors.sh --tools    only check that jq and yq are
#                                        present and supported
#
# The YAML block in each spec is the source of truth. The JSON is written
# I-JSON (RFC 7493) in JCS (RFC 8785) form: object keys sorted, no
# insignificant whitespace, numbers in their shortest round-trip form, one
# final newline. Every lambda and condition string is checked against the
# grammar in vectors/GRAMMAR.adoc; a violation stops the export.
#
# jq is not a JCS serialiser. The output is JCS only because scripts/vectors.jq
# rejects every value jq would write differently: numbers jq puts in exponent
# form (|n| < 1e-4 fractions, |n| > 2^53 - 1), NaN, and strings containing
# U+007F. A spec that needs one of those fails the export loudly; it is never
# written in a wrong "canonical" form. When the ijson-jcs CLI
# (hyperpolymath/ijson-jcs) is on PATH, every generated file is also checked
# against the estate on-disk rule (JCS bytes plus exactly one final LF), and a
# failure stops the export: with `ijson-jcs check --profile estate-file` where
# the installed tool supports it, else with its default `check` plus a final-LF
# check (see below).
#
# Needs jq >= 1.7 and a yq: mikefarah's Go yq (the estate's choice) or
# kislyuk's jq wrapper. Exit codes: 0 ok, 1 drift or invalid spec,
# 2 could not run (missing tool or file).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

mode=write
case "${1:-}" in
  "") ;;
  --check) mode=check ;;
  --tools) mode=tools ;;
  *) printf 'usage: %s [--check|--tools]\n' "$0" >&2; exit 2 ;;
esac

for tool in jq yq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'export-vectors: %s not found (need jq >= 1.7 and a supported yq)\n' "$tool" >&2
    exit 2
  fi
done

# jq >= 1.7: the filters use features (and number handling) of 1.7. A release
# build reports "jq-1.7.1"; a build from a checkout without release tags
# reports "jq-<branch>-<commit>", which names no release. For those, a
# behaviour probe decides instead: pick/1 is a builtin new in jq 1.7.
jq_version="$(jq --version 2>&1 | sed -n 's/^jq-\([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')"
if [ -n "$jq_version" ]; then
  read -r jq_major jq_minor <<<"$jq_version"
  if [ "$jq_major" -gt 1 ] || { [ "$jq_major" -eq 1 ] && [ "$jq_minor" -ge 7 ]; }; then
    jq_ok=1
  else
    jq_ok=0
  fi
elif [ "$(jq -n -c '{a: 1, b: 2} | pick(.a)' 2>/dev/null)" = '{"a":1}' ]; then
  jq_ok=1
else
  jq_ok=0
fi
if [ "$jq_ok" -ne 1 ]; then
  printf 'export-vectors: need jq >= 1.7, found "%s"\n' "$(jq --version 2>&1)" >&2
  exit 2
fi
if [ ! -d specs ] || [ ! -f scripts/vectors.jq ]; then
  printf 'export-vectors: run from an aggregate-library checkout\n' >&2
  exit 2
fi

# Convert YAML on stdin to JSON on stdout with whichever yq is installed.
if yq --version 2>&1 | grep -q mikefarah; then
  yaml_to_json() { yq -p yaml -o json -I 0 '.'; }
else
  yaml_to_json() { yq -c '.'; }
fi
# A supported yq is one that turns this probe into this JSON. Any other
# "yq" (an old mikefarah v3, an unrelated tool) stops here, before a spec
# is read, instead of failing later with a misleading parse error.
if [ "$(printf 'a: [1, "x"]\n' | yaml_to_json 2>/dev/null | jq -c . 2>/dev/null)" != '{"a":[1,"x"]}' ]; then
  printf 'export-vectors: unsupported yq "%s"; need mikefarah yq v4 or kislyuk yq\n' \
    "$(yq --version 2>&1 | head -n 1)" >&2
  exit 2
fi
if [ "$mode" = tools ]; then
  printf 'export-vectors: tools ok (%s; %s)\n' "$(jq --version)" "$(yq --version 2>&1 | head -n 1)"
  exit 0
fi

# The text inside the first literal block (....) after "=== Interface Signature".
signature_of() {
  awk '/^=== Interface Signature/ { s = 1; next }
       s && /^\.\.\.\.$/ { c++; if (c == 2) exit; next }
       s && c == 1 && NF { print; exit }' "$1"
}

# The body of the first [source,yaml] block.
yaml_of() {
  awk '/^\[source,yaml\]/ { s = 1; next }
       s && /^----$/ { c++; if (c == 2) exit; next }
       s && c == 1 { print }' "$1"
}

# Every operation name, for checking calls inside lambdas and conditions.
ops_json="$(for f in specs/*/*.adoc; do basename "$f" .adoc; done | sort -u | jq -R . | jq -s -c .)"

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

status=0
for dir in specs/*/; do
  category="$(basename "$dir")"
  records=()
  for spec in "$dir"*.adoc; do
    sig="$(signature_of "$spec")"
    if [ -z "$sig" ]; then
      printf 'export-vectors: %s: no interface signature\n' "$spec" >&2
      status=1
      continue
    fi
    if ! doc="$(yaml_of "$spec" | yaml_to_json)" || [ -z "$doc" ]; then
      printf 'export-vectors: %s: test-case YAML does not parse\n' "$spec" >&2
      status=1
      continue
    fi
    if ! rec="$(jq -n -c --arg sig "$sig" --arg src "$spec" --argjson ops "$ops_json" \
                  --argjson doc "$doc" -f scripts/vectors.jq 2>&1)"; then
      printf 'export-vectors: %s: %s\n' "$spec" "$rec" >&2
      status=1
      continue
    fi
    records+=("$rec")
  done
  # JCS form. jq -S sorts keys by code point, which equals the JCS UTF-16
  # order for these ASCII keys; "+ 0" rewrites each number in shortest
  # round-trip form (4.0 -> 4, -0 -> 0), as JCS requires. jq escapes strings
  # as JCS does except for U+007F, and prints some numbers in exponent form;
  # scripts/vectors.jq rejects both cases before this point (see the header).
  printf '%s\n' "${records[@]}" \
    | jq -s -S -c --arg c "$category" \
        '{category: $c, format: "alib-vectors-1", operations: .}
         | walk(if type == "number" then . + 0 else . end)' \
    >"$out/$category.json"
done

if [ "$status" -ne 0 ]; then
  printf 'export-vectors: specs are invalid; nothing written\n' >&2
  exit 1
fi

# Independent JCS check when the estate tool is available. `--profile` is newer
# than the first ijson-jcs releases, which reject it as an unknown option with
# exit 2, the same code as an invalid file. So probe the installed tool on a
# known-good file first, instead of reading a usage error as "not JCS". An older
# tool gets its default (tolerant) `check`, which accepts JCS bytes with or
# without one final LF; requiring the final LF as well gives the estate-file
# rule.
if command -v ijson-jcs >/dev/null 2>&1; then
  probe="$out/.probe"
  printf '{}\n' >"$probe"
  if ijson-jcs check --profile estate-file "$probe" >/dev/null 2>&1; then
    jcs_check=(ijson-jcs check --profile estate-file)
    lf_check=0
  elif ijson-jcs check "$probe" >/dev/null 2>&1; then
    jcs_check=(ijson-jcs check)
    lf_check=1
  else
    printf 'export-vectors: the ijson-jcs on PATH (%s) does not accept "check FILE"; update it from hyperpolymath/ijson-jcs or take it off PATH\n' \
      "$(ijson-jcs --version 2>&1 | head -n 1)" >&2
    exit 2
  fi
  rm -f "$probe"
  if ! "${jcs_check[@]}" "$out"/*.json >&2; then
    printf 'export-vectors: generated JSON is not JCS (%s); nothing written\n' "${jcs_check[*]}" >&2
    exit 1
  fi
  if [ "$lf_check" -eq 1 ]; then
    for f in "$out"/*.json; do
      # $(...) drops a final LF, so this is empty only when the last byte is LF.
      if [ -n "$(tail -c 1 "$f")" ]; then
        printf 'export-vectors: %s does not end in a line feed; nothing written\n' "$(basename "$f")" >&2
        exit 1
      fi
    done
  fi
else
  printf 'export-vectors: note: ijson-jcs not on PATH; JCS form rests on the scripts/vectors.jq guards\n' >&2
fi

count="$(cat "$out"/*.json | jq -s '[.[].operations[]] | length')"
nvec="$(cat "$out"/*.json | jq -s '[.[].operations[].vectors[]] | length')"

if [ "$mode" = write ]; then
  mkdir -p vectors
  rm -f vectors/*.json
  cp "$out"/*.json vectors/
  printf 'export-vectors: wrote %s operations, %s vectors to vectors/\n' "$count" "$nvec"
  exit 0
fi

if [ ! -d vectors ]; then
  printf 'export-vectors: vectors/ is missing; run scripts/export-vectors.sh\n' >&2
  exit 1
fi
stale=0
for name in $( (ls "$out"; ls vectors) | grep '\.json$' | sort -u); do
  if [ ! -f "$out/$name" ]; then
    printf 'export-vectors: vectors/%s has no spec category\n' "$name" >&2
    stale=1
  elif [ ! -f "vectors/$name" ]; then
    printf 'export-vectors: vectors/%s is missing\n' "$name" >&2
    stale=1
  elif ! cmp -s "$out/$name" "vectors/$name"; then
    # The files are one line each (JCS), so show the difference pretty-printed.
    printf 'export-vectors: vectors/%s differs from its specs:\n' "$name" >&2
    diff <(jq . "vectors/$name" 2>&1) <(jq . "$out/$name") >&2 || true
    stale=1
  fi
done
if [ "$stale" -ne 0 ]; then
  printf 'export-vectors: vectors/ is stale; run scripts/export-vectors.sh\n' >&2
  exit 1
fi
printf 'export-vectors: vectors/ matches specs/ (%s operations, %s vectors)\n' "$count" "$nvec"
