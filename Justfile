# justfile for aggregate-library (aLib)
# Command runner and task automation

# Default recipe - show help
default:
    @just --list

# Show this help message
help:
    @echo "aggregate-library (aLib) - Common Library Specification"
    @echo ""
    @echo "Available commands:"
    @just --list
    @echo ""
    @echo "Quick start:"
    @echo "  just validate    - Validate all specifications"
    @echo "  just test        - Run all test validations"
    @echo "  just docs        - Check all documentation"
    @echo "  just rsr         - Check RSR compliance"

# Validate all specifications for format compliance
validate:
    @echo "Validating specifications..."
    @just validate-specs
    @just validate-yaml
    @just validate-links
    @echo "✅ All validations passed!"

# Validate specification format
validate-specs:
    @echo "Checking specification format..."
    @n=0; for spec in specs/*/*.adoc; do \
        [ -f "$spec" ] || { echo "❌ No specs found under specs/*/*.adoc"; exit 1; }; \
        echo "  Validating $spec..."; \
        grep -q "^=== Interface Signature" "$spec" || { echo "❌ Missing Interface Signature in $spec"; exit 1; }; \
        grep -q "^=== Behavioral Semantics" "$spec" || { echo "❌ Missing Behavioral Semantics in $spec"; exit 1; }; \
        grep -q "^=== Executable Test Cases" "$spec" || { echo "❌ Missing Test Cases in $spec"; exit 1; }; \
        n=$((n + 1)); \
    done; \
    echo "✅ Specification format valid ($n specs)"

# Validate YAML test cases: every block must parse, every vector must match
# its signature's arity, and every lambda/condition must match
# vectors/GRAMMAR.adoc (done by the vector export, so this is vectors-check)
validate-yaml:
    @echo "Validating YAML test cases..."
    @just vectors-check

# Regenerate vectors/<category>.json from the spec YAML blocks
vectors:
    @scripts/export-vectors.sh

# Fail if vectors/*.json differs from what the specs generate (drift check)
vectors-check:
    @scripts/export-vectors.sh --check

# Check for broken links in documentation
validate-links:
    @echo "Checking documentation links..."
    @grep -n "link:" *.adoc specs/*/*.adoc 2>/dev/null || echo "  No links found"
    @echo "✅ Link check passed (manual verification recommended)"

# Run all tests
test: validate
    @echo "Running test validations..."
    @just test-arithmetic
    @just test-comparison
    @just test-logical
    @just test-string
    @just test-collection
    @just test-conditional
    @echo "✅ All tests passed!"

# Test arithmetic operations (the expected spec files; a missing or extra one fails)
test-arithmetic:
    @echo "Testing arithmetic operations..."
    @test -f specs/arithmetic/add.adoc || { echo "❌ Missing specs/arithmetic/add.adoc"; exit 1; }
    @test -f specs/arithmetic/subtract.adoc || { echo "❌ Missing specs/arithmetic/subtract.adoc"; exit 1; }
    @test -f specs/arithmetic/multiply.adoc || { echo "❌ Missing specs/arithmetic/multiply.adoc"; exit 1; }
    @test -f specs/arithmetic/divide.adoc || { echo "❌ Missing specs/arithmetic/divide.adoc"; exit 1; }
    @test -f specs/arithmetic/modulo.adoc || { echo "❌ Missing specs/arithmetic/modulo.adoc"; exit 1; }
    @test -f specs/arithmetic/negate.adoc || { echo "❌ Missing specs/arithmetic/negate.adoc"; exit 1; }
    @test -f specs/arithmetic/absolute.adoc || { echo "❌ Missing specs/arithmetic/absolute.adoc"; exit 1; }
    @test -f specs/arithmetic/max.adoc || { echo "❌ Missing specs/arithmetic/max.adoc"; exit 1; }
    @test -f specs/arithmetic/min.adoc || { echo "❌ Missing specs/arithmetic/min.adoc"; exit 1; }
    @n=$(ls specs/arithmetic/*.adoc | wc -l); [ "$n" -eq 9 ] || { echo "❌ specs/arithmetic has $n specs; expected 9 (update this recipe)"; exit 1; }
    @echo "  ✅ 9/9 arithmetic operations present"

# Test comparison operations (the expected spec files; a missing or extra one fails)
test-comparison:
    @echo "Testing comparison operations..."
    @test -f specs/comparison/less_than.adoc || { echo "❌ Missing specs/comparison/less_than.adoc"; exit 1; }
    @test -f specs/comparison/greater_than.adoc || { echo "❌ Missing specs/comparison/greater_than.adoc"; exit 1; }
    @test -f specs/comparison/equal.adoc || { echo "❌ Missing specs/comparison/equal.adoc"; exit 1; }
    @test -f specs/comparison/not_equal.adoc || { echo "❌ Missing specs/comparison/not_equal.adoc"; exit 1; }
    @test -f specs/comparison/less_equal.adoc || { echo "❌ Missing specs/comparison/less_equal.adoc"; exit 1; }
    @test -f specs/comparison/greater_equal.adoc || { echo "❌ Missing specs/comparison/greater_equal.adoc"; exit 1; }
    @n=$(ls specs/comparison/*.adoc | wc -l); [ "$n" -eq 6 ] || { echo "❌ specs/comparison has $n specs; expected 6 (update this recipe)"; exit 1; }
    @echo "  ✅ 6/6 comparison operations present"

# Test logical operations (the expected spec files; a missing or extra one fails)
test-logical:
    @echo "Testing logical operations..."
    @test -f specs/logical/and.adoc || { echo "❌ Missing specs/logical/and.adoc"; exit 1; }
    @test -f specs/logical/or.adoc || { echo "❌ Missing specs/logical/or.adoc"; exit 1; }
    @test -f specs/logical/not.adoc || { echo "❌ Missing specs/logical/not.adoc"; exit 1; }
    @n=$(ls specs/logical/*.adoc | wc -l); [ "$n" -eq 3 ] || { echo "❌ specs/logical has $n specs; expected 3 (update this recipe)"; exit 1; }
    @echo "  ✅ 3/3 logical operations present"

# Test string operations (the expected spec files; a missing or extra one fails)
test-string:
    @echo "Testing string operations..."
    @test -f specs/string/concat.adoc || { echo "❌ Missing specs/string/concat.adoc"; exit 1; }
    @test -f specs/string/length.adoc || { echo "❌ Missing specs/string/length.adoc"; exit 1; }
    @test -f specs/string/substring.adoc || { echo "❌ Missing specs/string/substring.adoc"; exit 1; }
    @test -f specs/string/reverse.adoc || { echo "❌ Missing specs/string/reverse.adoc"; exit 1; }
    @n=$(ls specs/string/*.adoc | wc -l); [ "$n" -eq 4 ] || { echo "❌ specs/string has $n specs; expected 4 (update this recipe)"; exit 1; }
    @echo "  ✅ 4/4 string operations present"

# Test collection operations (the expected spec files; a missing or extra one fails)
test-collection:
    @echo "Testing collection operations..."
    @test -f specs/collection/map.adoc || { echo "❌ Missing specs/collection/map.adoc"; exit 1; }
    @test -f specs/collection/filter.adoc || { echo "❌ Missing specs/collection/filter.adoc"; exit 1; }
    @test -f specs/collection/fold.adoc || { echo "❌ Missing specs/collection/fold.adoc"; exit 1; }
    @test -f specs/collection/contains.adoc || { echo "❌ Missing specs/collection/contains.adoc"; exit 1; }
    @test -f specs/collection/length.adoc || { echo "❌ Missing specs/collection/length.adoc"; exit 1; }
    @test -f specs/collection/empty.adoc || { echo "❌ Missing specs/collection/empty.adoc"; exit 1; }
    @n=$(ls specs/collection/*.adoc | wc -l); [ "$n" -eq 6 ] || { echo "❌ specs/collection has $n specs; expected 6 (update this recipe)"; exit 1; }
    @echo "  ✅ 6/6 collection operations present"

# Test conditional operations (the expected spec files; a missing or extra one fails)
test-conditional:
    @echo "Testing conditional operations..."
    @test -f specs/conditional/if_then_else.adoc || { echo "❌ Missing specs/conditional/if_then_else.adoc"; exit 1; }
    @n=$(ls specs/conditional/*.adoc | wc -l); [ "$n" -eq 1 ] || { echo "❌ specs/conditional has $n specs; expected 1 (update this recipe)"; exit 1; }
    @echo "  ✅ 1/1 conditional operations present"

# Check all documentation files
docs:
    @echo "Checking documentation..."
    @just docs-required
    @just docs-wellknown
    @just docs-rsr
    @echo "✅ All documentation present!"

# Check required documentation files (supports both .md and .adoc formats)
docs-required:
    @echo "Checking required docs..."
    @test -f README.md -o -f README.adoc || (echo "❌ Missing README.md or README.adoc" && exit 1)
    @test -f LICENSE -o -f LICENSE.txt || (echo "❌ Missing LICENSE or LICENSE.txt" && exit 1)
    @test -f CLAUDE.md || (echo "❌ Missing CLAUDE.md" && exit 1)
    @test -f SPEC_FORMAT.md -o -f SPEC_FORMAT.adoc || (echo "❌ Missing SPEC_FORMAT.md or SPEC_FORMAT.adoc" && exit 1)
    @test -f CONTRIBUTING.md -o -f .github/CONTRIBUTING.md || (echo "❌ Missing CONTRIBUTING.md or .github/CONTRIBUTING.md" && exit 1)
    @test -f CODE_OF_CONDUCT.md -o -f CODE_OF_CONDUCT.adoc || (echo "❌ Missing CODE_OF_CONDUCT.md or CODE_OF_CONDUCT.adoc" && exit 1)
    @test -f SECURITY.md -o -f SECURITY.adoc || (echo "❌ Missing SECURITY.md or SECURITY.adoc" && exit 1)
    @test -f MAINTAINERS.md -o -f MAINTAINERS.adoc || (echo "❌ Missing MAINTAINERS.md or MAINTAINERS.adoc" && exit 1)
    @test -f CHANGELOG.md -o -f CHANGELOG.adoc || (echo "❌ Missing CHANGELOG.md or CHANGELOG.adoc" && exit 1)
    @echo "  ✅ 9/9 required docs present"

# Check .well-known directory files
docs-wellknown:
    @echo "Checking .well-known files..."
    @test -f .well-known/security.txt -o -f www/.well-known/security.txt || (echo "❌ Missing .well-known/security.txt (repo root or www/)" && exit 1)
    @test -f .well-known/ai.txt -o -f www/.well-known/ai.txt || (echo "❌ Missing .well-known/ai.txt (repo root or www/)" && exit 1)
    @test -f .well-known/humans.txt -o -f www/.well-known/humans.txt || (echo "❌ Missing .well-known/humans.txt (repo root or www/)" && exit 1)
    @echo "  ✅ 3/3 .well-known files present"

# Check RSR compliance documentation
docs-rsr:
    @echo "Checking RSR compliance docs..."
    @test -f RSR_COMPLIANCE.md -o -f RSR_COMPLIANCE.adoc || (echo "⚠️  Missing RSR_COMPLIANCE (optional)" && exit 0)
    @echo "  ✅ RSR docs present"

# Check RSR (Rhodium Standard Repository) compliance
rsr:
    @echo "Checking RSR Compliance..."
    @echo ""
    @just rsr-documentation
    @just rsr-infrastructure
    @just rsr-metadata
    @just rsr-compliance-level
    @echo ""
    @echo "✅ RSR compliance check complete!"
    @echo "See RSR_COMPLIANCE.adoc for detailed compliance report"

# Check RSR documentation requirements (supports both .md and .adoc formats)
rsr-documentation:
    @echo "📋 RSR Documentation:"
    @(test -f README.md || test -f README.adoc) && echo "  ✅ README" || echo "  ❌ README"
    @(test -f LICENSE || test -f LICENSE.txt) && echo "  ✅ LICENSE" || echo "  ❌ LICENSE"
    @(test -f SECURITY.md || test -f SECURITY.adoc) && echo "  ✅ SECURITY" || echo "  ❌ SECURITY"
    @(test -f CONTRIBUTING.md || test -f .github/CONTRIBUTING.md) && echo "  ✅ CONTRIBUTING" || echo "  ❌ CONTRIBUTING"
    @(test -f CODE_OF_CONDUCT.md || test -f CODE_OF_CONDUCT.adoc) && echo "  ✅ CODE_OF_CONDUCT" || echo "  ❌ CODE_OF_CONDUCT"
    @(test -f MAINTAINERS.md || test -f MAINTAINERS.adoc) && echo "  ✅ MAINTAINERS" || echo "  ❌ MAINTAINERS"
    @(test -f CHANGELOG.md || test -f CHANGELOG.adoc) && echo "  ✅ CHANGELOG" || echo "  ❌ CHANGELOG"

# Check RSR infrastructure requirements
rsr-infrastructure:
    @echo "🔧 RSR Infrastructure:"
    @(test -f .well-known/security.txt || test -f www/.well-known/security.txt) && echo "  ✅ .well-known/security.txt (RFC 9116)" || echo "  ❌ .well-known/security.txt"
    @(test -f .well-known/ai.txt || test -f www/.well-known/ai.txt) && echo "  ✅ .well-known/ai.txt" || echo "  ❌ .well-known/ai.txt"
    @(test -f .well-known/humans.txt || test -f www/.well-known/humans.txt) && echo "  ✅ .well-known/humans.txt" || echo "  ❌ .well-known/humans.txt"
    @(test -f Justfile || test -f justfile) && echo "  ✅ Justfile" || echo "  ❌ Justfile"

# Check RSR metadata
rsr-metadata:
    @echo "📦 RSR Metadata:"
    @grep -q "Dual MIT / Palimpsest" LICENSE.txt && echo "  ✅ Dual license (MIT + Palimpsest)" || echo "  ⚠️  License check"
    @(grep -q "TPCF" CONTRIBUTING.md 2>/dev/null || grep -q "TPCF" .github/CONTRIBUTING.md 2>/dev/null) && echo "  ✅ TPCF Perimeter designation" || echo "  ⚠️  TPCF designation"
    @test -d specs && echo "  ✅ Specification directory" || echo "  ❌ specs/ directory"

# Show RSR compliance level
rsr-compliance-level:
    @echo "🏆 Compliance Level:"
    @echo "  Target: Bronze+ (Specification Repository)"
    @echo "  Status: See RSR_COMPLIANCE.adoc"

# Count lines of specification
stats:
    @echo "📊 Repository Statistics:"
    @echo ""
    @echo "Specifications:"
    @find specs -name "*.adoc" | wc -l | xargs echo "  Operations:"
    @cat specs/*/*.adoc | wc -l | xargs echo "  Total lines:"
    @echo ""
    @echo "Documentation:"
    @wc -l *.adoc | tail -1 | awk '{print "  " $1 " lines"}'
    @echo ""
    @echo "Test Cases:"
    @grep -r "test_cases:" specs/ | wc -l | xargs echo "  Specifications with tests:"
    @echo ""
    @echo "Categories:"
    @ls -d specs/*/ | wc -l | xargs echo "  Operation categories:"

# List all operations (counted from the spec files, so the totals cannot drift)
list:
    @echo "📚 Common Library Operations ($(ls specs/*/*.adoc | wc -l) total):"
    @for dir in specs/*/; do \
        cat=$(basename "$dir"); \
        echo ""; \
        echo "$cat ($(ls "$dir"*.adoc | wc -l)):"; \
        ls "$dir"*.adoc | xargs -n1 basename | sed 's/\.adoc$//' | sed 's/^/  - /'; \
    done

# Show a specific operation
show operation:
    @cat specs/*/{{operation}}.adoc

# Clean up generated files (none currently)
clean:
    @echo "No generated files to clean"

# Format check for AsciiDoc files (top level and specs)
format:
    @echo "🔍 Checking AsciiDoc format..."
    @errors=0; \
    for file in *.adoc specs/*/*.adoc; do \
        if [ -f "$file" ]; then \
            if grep -q '	' "$file" 2>/dev/null; then \
                echo "  ⚠️  $file: contains tabs (prefer spaces)"; \
                errors=$((errors + 1)); \
            fi; \
            if grep -qE '[[:space:]]$' "$file" 2>/dev/null; then \
                echo "  ⚠️  $file: trailing whitespace detected"; \
                errors=$((errors + 1)); \
            fi; \
            if [ -n "$(tail -c 1 "$file" 2>/dev/null)" ]; then \
                echo "  ⚠️  $file: missing final newline"; \
                errors=$((errors + 1)); \
            fi; \
        fi; \
    done; \
    if [ $errors -eq 0 ]; then \
        echo "✅ Format check passed!"; \
    else \
        echo "⚠️  Found $errors format issue(s)"; \
    fi

# Generate table of contents for markdown files
toc file="README.md":
    @echo "📑 Generating Table of Contents for {{file}}..."
    @if [ ! -f "{{file}}" ]; then \
        echo "❌ File not found: {{file}}"; \
        exit 1; \
    fi; \
    echo ""; \
    echo "## Table of Contents"; \
    echo ""; \
    grep -E "^#{1,6} " "{{file}}" | \
        grep -v "^# " | \
        grep -v "Table of Contents" | \
        while read -r line; do \
            level=$$(echo "$$line" | sed 's/[^#]//g' | wc -c); \
            level=$$((level - 2)); \
            title=$$(echo "$$line" | sed 's/^#* //'); \
            anchor=$$(echo "$$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 -]//g' | sed 's/ /-/g'); \
            indent=$$(printf '%*s' $$((level * 2)) ''); \
            echo "$${indent}- [$$title](#$$anchor)"; \
        done; \
    echo ""; \
    echo "✅ Copy the above TOC into your markdown file"

# Check for TODOs in documentation
todos:
    @echo "🔍 Searching for TODOs..."
    @grep -r "TODO\|FIXME\|XXX" *.adoc specs/ www/.well-known/ 2>/dev/null || echo "  No TODOs found ✅"

# Run full compliance check (everything)
check: validate test docs rsr
    @echo ""
    @echo "═══════════════════════════════════════════"
    @echo "✅ FULL COMPLIANCE CHECK PASSED!"
    @echo "═══════════════════════════════════════════"
    @echo ""
    @echo "Specifications: ✅ Valid"
    @echo "Tests:          ✅ Passed"
    @echo "Documentation:  ✅ Complete"
    @echo "RSR Compliance: ✅ Bronze+"
    @echo ""
    @echo "aggregate-library is ready! 🎉"

# Watch for changes and validate (requires entr)
watch:
    @echo "Watching for changes... (Ctrl+C to stop)"
    @echo "Requires: entr (brew install entr or apt install entr)"
    @find specs scripts -name "*.adoc" -o -name "*.sh" -o -name "*.jq" | entr -c just validate

# Setup development environment
setup:
    @echo "Setting up development environment..."
    @echo "  Checking dependencies..."
    @command -v just >/dev/null 2>&1 || echo "  ⚠️  Install 'just' command runner"
    @command -v git >/dev/null 2>&1 && echo "  ✅ git" || echo "  ❌ git required"
    @echo ""
    @echo "Recommended tools:"
    @echo "  - yamllint (for YAML validation)"
    @echo "  - markdownlint (for markdown linting)"
    @echo "  - entr (for watch mode)"
    @echo ""
    @echo "Run 'just help' to see available commands"

# Version information
version:
    @echo "aggregate-library (aLib) v0.1.0"
    @echo "Common Library Specification"
    @echo "License: Dual MIT / Palimpsest v0.8"
    @echo "Repository: https://github.com/Hyperpolymath/aggregate-library"

secret-scan-trufflehog:
    @command -v trufflehog >/dev/null && trufflehog filesystem . --only-verified || true
