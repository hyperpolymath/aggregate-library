# aggregate-library (aLib)

**A Common Library specification shared across radically different programming languages**

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
├── CLAUDE.md                 # AI assistant guidelines
├── SPEC_FORMAT.md            # Specification format documentation
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

## Contributing

This specification is part of ongoing research into cross-paradigm language design. Feedback and contributions are welcome.

## License

TBD

---

**Version**: 0.1.0 (Initial specification)
**Last Updated**: 2025-11-22
