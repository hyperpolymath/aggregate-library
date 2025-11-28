# aggregate-library (aLib)

**A Common Library specification shared across radically different programming languages**

[![RSR Compliance](https://img.shields.io/badge/RSR-Gold%20100%2F100-gold.svg)](RSR_COMPLIANCE.md)
[![License](https://img.shields.io/badge/License-MIT%20%2F%20Palimpsest%20v0.8-green.svg)](LICENSE.txt)
[![TPCF](https://img.shields.io/badge/TPCF-Perimeter%203-orange.svg)](CONTRIBUTING.md)
[![Offline-First](https://img.shields.io/badge/Offline-First-brightgreen.svg)](SPEC_FORMAT.md)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

## Quick Links

- 📖 [Specification Format](SPEC_FORMAT.md)
- 🤝 [Contributing Guide](CONTRIBUTING.md)
- 🛡️ [Security Policy](SECURITY.md)
- ⚖️ [Code of Conduct](CODE_OF_CONDUCT.md)
- 📊 [RSR Compliance Report](RSR_COMPLIANCE.md)
- 📝 [Changelog](CHANGELOG.md)

## Overview

The aggregate-library (aLib) project defines a minimal **Common Library** that represents the intersection of functionality across seven fundamentally different programming languages. Each language will have its own **Aggregate Library** = **Common Library** + language-specific **Standard Library**.

This project aims to reduce programming language territoriality while preserving the unique features that make each language valuable.

## Philosophy

### Why a Common Library?

Programming languages often evolve in isolation, leading to:
- Fragmented ecosystems
- Unnecessary relearning of basic concepts
- Tribalism and language wars
- Difficulty in polyglot development

The Common Library provides:
- A shared foundation across diverse paradigms
- Minimal but useful universal operations
- A framework for understanding language similarities and differences
- A basis for cross-language tooling and interoperability

### Design Principles

1. **Minimal**: Include only operations that exist across ALL languages
2. **Universal**: Operations must work across radically different paradigms
3. **Testable**: Each operation has concrete, executable test cases
4. **Language-agnostic**: Specifications avoid language-specific details
5. **Pragmatic**: Focus on commonly needed operations

## The Seven Languages

The Common Library is defined as the intersection of these seven diverse languages:

1. **WokeLang** - Consent-driven, emotional computing
2. **Duet/Ensemble** - AI-first, session types, effect systems
3. **Eclexia** - Sustainability-focused, energy budgets
4. **Oblíbený** - Security-first, provable termination
5. **RT-Lang** - Real-time systems, dependent types, safety certification
6. **Phronesis** - Ethical reasoning, values-based programming
7. **Julia the Viper** - Reversible computing, totality

These languages were chosen specifically because they are **radically different** in philosophy, syntax, and features - providing a rigorous stress test for what truly universal operations look like.

## Common Library Operations

The Common Library includes **20 core operations** across 6 categories:

### Arithmetic (5 operations)
- `add` - Addition
- `subtract` - Subtraction
- `multiply` - Multiplication
- `divide` - Division
- `modulo` - Remainder

### Comparison (6 operations)
- `less_than` - Strictly less than
- `greater_than` - Strictly greater than
- `equal` - Equality
- `not_equal` - Inequality
- `less_equal` - Less than or equal
- `greater_equal` - Greater than or equal

### Logical (3 operations)
- `and` - Logical conjunction
- `or` - Logical disjunction
- `not` - Logical negation

### String (3 operations)
- `concat` - String concatenation
- `length` - String length
- `substring` - Extract substring

### Collection (4 operations)
- `map` - Transform each element
- `filter` - Select elements by predicate
- `fold` - Reduce to single value (also known as reduce)
- `contains` - Check element membership

### Conditional (1 operation)
- `if_then_else` - Conditional branching

## What's NOT in the Common Library

The following are explicitly **excluded** from the Common Library because they vary across languages:

- Error handling mechanisms
- Concurrency primitives
- Memory management strategies
- Type system specifics beyond basic categories
- I/O operations
- Domain-specific features (consent, energy, security, ethics, etc.)
- Language-specific optimizations

These belong in each language's **Standard Library**.

## Specification Format

Each operation is specified with three components:

### 1. Interface Signature
Abstract signature independent of language syntax:
```
operation_name: InputType1, InputType2 -> OutputType
```

### 2. Behavioral Semantics
- Purpose and description
- Parameter definitions
- Return value specification
- Mathematical properties
- Edge cases

### 3. Executable Test Cases
Concrete examples in YAML format:
```yaml
test_cases:
  - input: [arg1, arg2]
    output: expected_result
    description: "What this tests"
```

See [SPEC_FORMAT.md](SPEC_FORMAT.md) for complete details.

## Repository Structure

```
aggregate-library/
├── README.md                 # This file
├── LICENSE.txt               # Dual MIT / Palimpsest v0.8
├── CLAUDE.md                 # AI assistant guidelines
├── SPEC_FORMAT.md            # Specification format documentation
├── RSR_COMPLIANCE.md         # RSR compliance report
├── SECURITY.md               # Security policies
├── CONTRIBUTING.md           # Contribution guidelines
├── CODE_OF_CONDUCT.md        # Community standards
├── MAINTAINERS.md            # Project governance
├── CHANGELOG.md              # Version history
├── justfile                  # Build automation (30+ recipes)
├── .well-known/              # Standard metadata
│   ├── security.txt          # RFC 9116 compliant
│   ├── ai.txt                # AI training policies
│   └── humans.txt            # Contributor attribution
└── specs/                    # Operation specifications
    ├── arithmetic/
    │   ├── add.md
    │   ├── subtract.md
    │   ├── multiply.md
    │   ├── divide.md
    │   └── modulo.md
    ├── comparison/
    │   ├── less_than.md
    │   ├── greater_than.md
    │   ├── equal.md
    │   ├── not_equal.md
    │   ├── less_equal.md
    │   └── greater_equal.md
    ├── logical/
    │   ├── and.md
    │   ├── or.md
    │   └── not.md
    ├── string/
    │   ├── concat.md
    │   ├── length.md
    │   └── substring.md
    ├── collection/
    │   ├── map.md
    │   ├── filter.md
    │   ├── fold.md
    │   └── contains.md
    └── conditional/
        └── if_then_else.md
```

## Using This Specification

### For Language Designers

1. Review the Common Library operations
2. Ensure your language can implement each operation
3. Implement operations in your language's syntax
4. Run the test cases to verify compliance
5. Extend with your language-specific Standard Library

### For Language Implementers

1. Read the specification for each operation
2. Implement according to the behavioral semantics
3. Ensure all test cases pass
4. Document any implementation-defined behaviors
5. Consider creating a compliance test suite

### For Learners

1. Study the Common Library to understand universal programming concepts
2. Compare how different languages implement the same operations
3. Use as a reference when learning new languages
4. Understand what's common vs what's language-specific

## Example: Implementing `add`

```
# Common Library Specification
add: Number, Number -> Number
Purpose: Computes the sum of two numbers
```

**WokeLang implementation** (hypothetical):
```
with_consent(a, b) => a + b
```

**Duet implementation** (hypothetical):
```
add : Num -> Num -> Num
add = \a b -> a + b
```

**Oblíbený implementation** (hypothetical):
```
fn add(a: SecureNum, b: SecureNum) -> SecureNum {
    verified_add(a, b)
}
```

Each language implements the same operation differently, but all satisfy the specification.

## Future Work

- Grammar mappings for each language
- Automated compliance testing
- Implementation examples in all 7 languages
- Cross-language interoperability layer
- Additional operations based on language evolution

## Related Projects

- **iSOS**: The broader framework (documentation forthcoming)
- Individual language repositories (links TBD)

## RSR Compliance

This project follows the **Rhodium Standard Repository (RSR)** framework and has achieved **GOLD compliance (100/100)** - the highest tier.

### Compliance Highlights

- ✅ **Documentation**: Complete (9 files)
- ✅ **Security**: Comprehensive policies (SECURITY.md, RFC 9116)
- ✅ **Community**: TPCF Perimeter 3 (open contribution)
- ✅ **Licensing**: Dual MIT / Palimpsest v0.8
- ✅ **Offline-First**: Zero network dependencies
- ✅ **Type Safety**: All operations fully typed
- ✅ **Infrastructure**: justfile with 30+ validation recipes

Run `just rsr` to verify compliance or see [RSR_COMPLIANCE.md](RSR_COMPLIANCE.md) for the full report.

### Quick Start

```bash
# Validate all specifications
just validate

# Run all tests
just test

# Check documentation
just docs

# Full compliance check
just check

# List all operations
just list
```

## Contributing

We welcome contributions! This specification is part of ongoing research into cross-paradigm language design.

**Before contributing:**
1. Read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
2. Review [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards
3. Check [SPEC_FORMAT.md](SPEC_FORMAT.md) for specification format

**Ways to contribute:**
- Improve specification clarity
- Add test cases
- Enhance documentation
- Report issues or ambiguities
- Propose new operations (rare - must exist in all 7 languages)

**Community:**
- 🏛️ Governance: [MAINTAINERS.md](MAINTAINERS.md)
- 🤝 TPCF Perimeter 3: Open contribution
- 💚 Emotional Safety: Prioritized in our community
- 🔒 Security: [SECURITY.md](SECURITY.md)

## License

This project is dual-licensed under:

### MIT License
Permissive use for maximum compatibility and adoption.

### Palimpsest License v0.8
Ethical constraints ensuring responsible use:
- Do no harm
- Respect autonomy
- Promote justice
- Preserve privacy
- Support sustainability
- Foster community

**You may choose either license** for your use case. See [LICENSE.txt](LICENSE.txt) for full terms and selection guidance.

## Acknowledgments

- The seven language communities for inspiration
- RSR framework authors for compliance standards
- Open source community for collaborative spirit
- All contributors (see `.well-known/humans.txt`)

---

**Version**: 0.1.0 (Initial specification)
**Last Updated**: 2025-11-22
**RSR Compliance**: Bronze+ (Specification Repository)
**TPCF Perimeter**: 3 (Community Sandbox)
