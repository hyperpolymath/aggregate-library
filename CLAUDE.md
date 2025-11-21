# CLAUDE.md

This document provides context and guidance for AI assistants (Claude) working with the aggregate-library codebase.

## Project Overview

**aggregate-library** is a library project for aggregating functionality and data. This repository is designed to be modular, maintainable, and well-documented.

## Repository Structure

```
aggregate-library/
├── src/              # Source code
├── tests/            # Test files
├── docs/             # Documentation
├── examples/         # Usage examples
└── dist/             # Build output (git-ignored)
```

## Development Guidelines

### Code Quality Standards

1. **Type Safety**: Use TypeScript with strict mode enabled
2. **Testing**: Maintain high test coverage (aim for >80%)
3. **Documentation**: All public APIs must have JSDoc comments
4. **Linting**: Follow ESLint and Prettier configurations
5. **Commits**: Use conventional commit messages (feat:, fix:, docs:, etc.)

### Best Practices

- Write modular, reusable code
- Keep functions small and focused (single responsibility)
- Prefer composition over inheritance
- Write self-documenting code with clear variable names
- Add comments only when the "why" isn't obvious from the code

### Security Considerations

- Validate all inputs
- Avoid command injection vulnerabilities
- Sanitize user-provided data
- Don't expose sensitive information in logs or error messages
- Keep dependencies up to date

## Common Tasks

### Setting Up the Project

```bash
# Install dependencies
npm install

# Run tests
npm test

# Build the project
npm run build

# Lint code
npm run lint

# Format code
npm run format
```

### Testing Strategy

- **Unit Tests**: Test individual functions and modules in isolation
- **Integration Tests**: Test how components work together
- **End-to-End Tests**: Test complete workflows
- Use meaningful test descriptions that explain the expected behavior
- Follow AAA pattern: Arrange, Act, Assert

### Adding New Features

1. Create a new branch from main: `git checkout -b feature/your-feature-name`
2. Write tests first (TDD approach recommended)
3. Implement the feature
4. Ensure all tests pass
5. Update documentation
6. Submit a pull request

### Code Review Checklist

- [ ] Code follows project style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No security vulnerabilities introduced
- [ ] Breaking changes are clearly marked
- [ ] Performance impact considered

## Architecture Patterns

### Module Design

- Each module should have a clear, single purpose
- Export a clean, minimal API
- Keep internal implementation details private
- Use dependency injection for better testability

### Error Handling

- Use typed errors for different error conditions
- Provide helpful error messages
- Don't swallow errors silently
- Log errors appropriately

### Performance

- Avoid premature optimization
- Profile before optimizing
- Consider memory usage for large datasets
- Use async/await for I/O operations

## Documentation Requirements

### Code Documentation

- All exported functions, classes, and types must have JSDoc comments
- Include parameter descriptions, return types, and examples
- Document edge cases and error conditions

### README Updates

When adding features, update README.md with:
- Feature description
- Usage examples
- API documentation
- Migration guides (for breaking changes)

## Git Workflow

### Branch Naming

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or updates

### Commit Messages

Follow conventional commits:
```
type(scope): subject

body

footer
```

Types: feat, fix, docs, style, refactor, test, chore

### Before Committing

1. Run tests: `npm test`
2. Run linter: `npm run lint`
3. Check build: `npm run build`
4. Review your changes: `git diff`

## Helpful Context for Claude

### When Asked to Add Features

1. First, understand the existing codebase structure
2. Check for similar existing implementations
3. Plan the implementation with a todo list
4. Write tests before implementing
5. Keep changes minimal and focused
6. Update relevant documentation

### When Debugging

1. Read error messages carefully
2. Check test failures for clues
3. Use logging strategically
4. Verify assumptions with tests
5. Consider edge cases

### When Refactoring

1. Ensure tests exist and pass before refactoring
2. Make small, incremental changes
3. Run tests after each change
4. Keep the same external behavior
5. Document any API changes

## Technology Stack

This section should be updated as the project evolves:

- **Language**: TypeScript/JavaScript
- **Runtime**: Node.js
- **Testing**: Jest/Mocha/Vitest
- **Build Tool**: TypeScript compiler, Webpack, or Vite
- **Package Manager**: npm/yarn/pnpm

## Additional Resources

- Project README: See README.md for user-facing documentation
- Contributing Guide: See CONTRIBUTING.md for contribution guidelines
- API Documentation: Generated from JSDoc comments
- Issue Tracker: GitHub Issues

## Notes for Claude

- Always read existing code before making changes
- Use the TodoWrite tool for multi-step tasks
- Prefer editing existing files over creating new ones
- Run tests before marking tasks complete
- Ask for clarification when requirements are ambiguous
- Consider backward compatibility for library changes
- Update this file as you learn more about the project

---

Last updated: 2025-11-21
