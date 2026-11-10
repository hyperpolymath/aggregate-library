# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell
#
# Build one operation record for vectors/<category>.json from a spec's
# interface signature and its executable test cases, and check every
# lambda and condition string against vectors/GRAMMAR.adoc.
#
# Called by scripts/export-vectors.sh as:
#   jq -n --arg sig SIG --arg src PATH --argjson ops OPNAMES
#         --argjson doc YAML_AS_JSON -f scripts/vectors.jq
# Any violation stops the export with an error naming the spec and vector.

# Remove leading and trailing whitespace from the input string.
def trim: gsub("^\\s+|\\s+$"; "");

# Split a type list at commas that are not inside [...].
def split_top_commas:
  explode
  | reduce .[] as $c ({d: 0, cur: [], out: []};
      if $c == 91 then .d += 1 | .cur += [$c]
      elif $c == 93 then .d -= 1 | .cur += [$c]
      elif $c == 44 and .d == 0 then .out += [.cur | implode] | .cur = []
      else .cur += [$c] end)
  | (.out + [.cur | implode]) | map(trim);

# Split "P1, P2 -> R" at the first "->" that is not inside [...].
def split_arrow:
  explode as $cs
  | (reduce range(0; $cs | length) as $i ({d: 0, at: null};
      if .at != null then .
      elif $cs[$i] == 91 then .d += 1
      elif $cs[$i] == 93 then .d -= 1
      elif .d == 0 and $cs[$i] == 45 and $cs[$i + 1] == 62 then .at = $i
      else . end)) as $r
  | if $r.at == null then error("no top-level -> in type") else . end
  | { params: ($cs[0:$r.at] | implode | split_top_commas),
      result: ($cs[$r.at + 2:] | implode | trim) };

# Parse a signature string into {name, params, result}, with trimmed type
# strings. A missing top-level arrow raises an error; a non-matching name
# prefix produces no output.
def parse_signature:
  (capture("^(?<name>[a-z_]+):\\s*(?<rest>.+)$")
    // error("signature is not \"name: params -> result\""))
  | . as $m
  | ($m.rest | split_arrow) + { name: $m.name };

# Number of parameters of a "Function[P1, ..., Pn -> R]" type.
def function_arity:
  capture("^Function\\[(?<inner>.*)\\]$").inner | split_arrow | .params | length;

# Tokens of the expression language; error if any character is unmatched.
def tokens:
  . as $s
  | [match("\\s*(=>|[A-Za-z_][A-Za-z0-9_]*|-?[0-9]+(?:\\.[0-9]+)?|\"[^\"\\\\]*\"|[(),])\\s*"; "g")] as $ms
  | if ($ms | map(.string) | join("")) != $s
    then error("unrecognised character in \"\($s)\"") else . end
  | $ms | map(.captures[0].string);

# Whether the input string has identifier syntax; reserved names also match.
def is_ident: test("^[A-Za-z_][A-Za-z0-9_]*$");

# expr over {t: tokens, i: position}; $env = bound parameter names.
# Return the state with i advanced past one expression. Raise an error for
# invalid syntax, unbound names or calls outside $ops (known operation names).
# Call arity and result types are not checked; trailing tokens are left unread.
def expr($env; $ops):
  def args:
    if .t[.i] == "," then .i += 1 | expr($env; $ops) | args
    elif .t[.i] == ")" then .i += 1
    else error("expected \",\" or \")\" at token \(.i)") end;
  .t[.i] as $tok
  | if $tok == null then error("expression ends early")
    elif $tok == "true" or $tok == "false" then .i += 1
    elif ($tok | test("^-?[0-9]")) or ($tok | startswith("\"")) then .i += 1
    elif ($tok | is_ident) then
      if .t[.i + 1] == "(" then
        if any($ops[]; . == $tok) then . else error("unknown operation \($tok)") end
        | .i += 2
        | if .t[.i] == ")" then .i += 1 else expr($env; $ops) | args end
      elif any($env[]; . == $tok) then .i += 1
      else error("unbound identifier \($tok)") end
    else error("unexpected token \($tok)") end;

# Validate the whole input expression string with no bound identifiers and
# $ops as the allowed call names. Return parser state on success; lexical,
# expression and trailing-token errors propagate without evaluating it.
def check_condition($ops):
  tokens as $t
  | {t: $t, i: 0} | expr([]; $ops)
  | if .i != ($t | length) then error("trailing tokens in condition") else . end;

# The parameter list before "=>" must alternate identifier, ",", identifier,
# ...: it starts and ends with an identifier and never has two commas or two
# identifiers in a row (so ", acc x" and "acc,, x" are rejected).
# $arity is the required parameter count; $ops lists allowed call names, which
# cannot be parameter names. Return parser state after the whole lambda body;
# raise an error for invalid parameters or arity, or propagate parsing errors.
def check_lambda($arity; $ops):
  tokens as $t
  | ([$t | indices("=>")[]] | first // error("lambda has no =>")) as $p
  | $t[0:$p] as $pl
  | [$pl | to_entries[] | select(.key % 2 == 0) | .value] as $params
  | if ($pl | length) % 2 != 1
       or any($pl | to_entries[]; (.key % 2 == 1) != (.value == ","))
       or any($params[]; (is_ident | not) or . == "true" or . == "false" or (. as $x | any($ops[]; . == $x)))
    then error("bad lambda parameter list") else . end
  | if ($params | length) != $arity
    then error("lambda takes \($params | length) parameter(s); the signature needs \($arity)") else . end
  | {t: $t, i: ($p + 1)} | expr($params; $ops)
  | if .i != ($t | length) then error("trailing tokens in lambda body") else . end;

# Check one argument against its declared parameter type.
# Function arguments must be lambda strings; Boolean arguments must be Boolean
# values or condition strings. Other types pass through without validation.
# Return parser state for strings that are checked, otherwise the input value;
# type mismatches and expression validation errors propagate to the caller.
def check_arg($ty; $ops):
  if ($ty | startswith("Function[")) then
    if type != "string" then error("a Function argument must be a lambda string")
    else check_lambda($ty | function_arity; $ops) end
  elif $ty == "Boolean" and type == "string" then check_condition($ops)
  elif $ty == "Boolean" and type != "boolean"
  then error("a Boolean argument must be true, false or a condition string, not \(tojson)")
  else . end;

# Every number and string in a vector must be one the exporter writes in JCS
# (RFC 8785) form, because jq, which writes the JSON, is not a JCS serialiser:
# - Numbers: jq writes the shortest round-trip digits, as JCS does, but
#   switches to exponent form (1e-05, 1e+20) far earlier than ECMAScript
#   Number::toString (which JCS uses) does, and it cannot hold integers beyond
#   2^53 - 1, which I-JSON (RFC 7493) also excludes.
# - Strings: jq escapes U+007F (DEL) as \u007f; JCS writes it raw.
# Rather than write a wrong canonical form, reject such values; the
# hyperpolymath/ijson-jcs tool is the authority if a vector ever needs one. In
# practice: integers need |n| <= 2^53 - 1, a fraction needs |n| >= 1e-4, and
# a string must not contain U+007F.
def check_jcs:
  . as $v
  | [$v | .. | numbers] | map(
    if isnan then error("number NaN is not I-JSON")
    elif fabs > 9007199254740991
    then error("number \(.) is outside the I-JSON integer range +/-(2^53 - 1)")
    elif (. + 0 | tojson | test("[eE]"))
    then error("number \(. + 0 | tojson) would be written in exponent form, which is not its JCS form; the exporter cannot canonicalise it")
    else . end)
  | [$v | .. | strings | select(test("\u007f"))]
  | if length > 0
    then error("string \(.[0] | tojson) contains U+007F, which jq does not write in JCS form")
    else . end;

($sig | parse_signature) as $s
| ($src | split("/") | last | rtrimstr(".adoc")) as $stem
| (if $s.name != $stem
   then error("\($src): signature names \"\($s.name)\" but the file is \"\($stem).adoc\"")
   else . end)
| ($doc.test_cases // error("\($src): no test_cases")) as $tc
| (if ($tc | length) == 0 then error("\($src): no vectors") else . end)
| ($tc[0].input | if type == "object" then keys_unsorted else null end) as $names
| (reduce range(0; $tc | length) as $n (null;
    $tc[$n] as $v
    | try (
        if ($v | has("input") and has("output") and has("description")) | not
        then error("needs input, output and description") else . end
        | ($v | check_jcs)
        | if ($v.input | type) == "array" then
            if $names != null then error("input shape differs from vector 1") else . end
            | if ($v.input | length) != ($s.params | length)
              then error("\($v.input | length) argument(s); the signature has \($s.params | length)") else . end
            | [range(0; $s.params | length) as $i | $v.input[$i] | check_arg($s.params[$i]; $ops)]
          elif ($v.input | type) == "object" then
            if ($v.input | keys_unsorted) != $names
            then error("keyed input must use the keys of vector 1, in order") else . end
            | if ($names | length) != ($s.params | length)
              then error("\($names | length) key(s); the signature has \($s.params | length) parameter(s)") else . end
            | [range(0; $s.params | length) as $i | $v.input[$names[$i]] | check_arg($s.params[$i]; $ops)]
          else error("input must be a list or a mapping") end
      )
      catch error("\($src) vector \($n + 1): \(.)")))
| {
    name: $s.name,
    signature: $sig,
    parameters: [range(0; $s.params | length) as $i
                 | {type: $s.params[$i]} + (if $names == null then {} else {name: $names[$i]} end)],
    result: $s.result,
    source: $src,
    vectors: $tc
  }
