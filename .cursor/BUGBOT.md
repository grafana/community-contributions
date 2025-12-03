# Bugbot Rules for External Contributions

This repository is a sandbox for testing external contributor PRs to Grafana.

## Auto-Review Control

<!-- IMPORTANT: Do not auto-review PRs. Only review when explicitly triggered by:
     1. Our validation workflows (after categorization for small/medium, after alignment for large)
     2. Engineer request via @cursor comment
-->
auto_review: false

## Review Focus

### Priority: Security Issues
Flag any potential security vulnerabilities:
- XSS vulnerabilities (unsanitized HTML, `dangerouslySetInnerHTML` without DOMPurify)
- SQL injection risks
- Path traversal vulnerabilities
- Hardcoded secrets or credentials
- Unsafe URL handling (missing validation, `javascript:` or `data:` URLs)
- Unsafe use of `eval()`, `exec()`, or `Function()` constructor

### Priority: Test Coverage
- New features should include tests
- Bug fixes should include regression tests
- Flag if changed code paths lack test coverage

### Priority: Breaking Changes
- Identify changes to public APIs
- Flag removed or renamed exports
- Note changes to function signatures

### Review: Code Quality
- Obvious bugs or logic errors
- Null/undefined handling issues
- Race conditions or async issues
- Memory leaks (missing cleanup, event listener removal)

## Skip These (Handled by CI/Linters)

Don't comment on:
- Code formatting and style (Prettier/ESLint handle this)
- Import ordering
- Trailing whitespace
- Line length
- TypeScript type annotations style
- Go formatting (gofmt handles this)
- Documentation grammar or formatting

## Tone Guidelines

- Be constructive and welcoming - these are external contributors
- Explain the "why" behind suggestions
- Provide code examples when suggesting fixes
- Acknowledge good patterns when you see them
- Keep comments concise and actionable

## PR Size Context

PRs are categorized by size:
- **Small** (< 50 lines): Quick fixes, focus on correctness
- **Medium** (50-300 lines): Standard review depth
- **Large** (300+ lines): Already went through human alignment, focus on critical issues only

