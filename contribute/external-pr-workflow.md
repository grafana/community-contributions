# External PR Workflow Guide

Welcome to Grafana! This guide explains our adaptive PR workflow designed to provide the best experience for external contributors while ensuring code quality.

## Table of Contents

- [Overview](#overview)
- [PR Categorization](#pr-categorization)
- [Workflow by Category](#workflow-by-category)
- [What to Expect](#what-to-expect)
- [Tips for Success](#tips-for-success)
- [FAQ](#faq)

## Overview

Our workflow automatically categorizes your PR based on **size** and **type**, then applies the appropriate level of validation and review. This ensures:

- 🟢 **Small PRs** get fast turnaround with lightweight checks
- 🟡 **Medium PRs** receive comprehensive validation
- 🔴 **Large PRs** get early human alignment to avoid wasted effort

## PR Categorization

### Size Categories

Your PR will be automatically categorized by size:

| Category | Criteria | Description |
|----------|----------|-------------|
| 🟢 **Small** | < 100 lines, 1-3 files | Quick fixes, typos, minor changes |
| 🟡 **Medium** | 100-500 lines, 4-10 files | Moderate features, refactors |
| 🔴 **Large** | > 500 lines, > 10 files | Major features, architectural changes |

### Type Categories

Your PR is also categorized by type:

| Type | Description | Examples |
|------|-------------|----------|
| 📝 **Docs** | Documentation changes | README updates, doc fixes |
| 🐛 **Bugfix** | Fixes for existing issues | Bug fixes, error corrections |
| 🔨 **Refactor** | Code reorganization | Restructuring without new features |
| ✨ **Feature** | New functionality | New capabilities, enhancements |

### Self-Selection

In the PR template, you can indicate your own categorization. Our automation will verify it and may adjust if needed based on actual changes.

## Workflow by Category

### 🟢 Small PRs

**Goal**: Fast turnaround for simple changes

**Automated Steps**:
1. ✅ Basic linting and formatting checks
2. ✅ Verify tests exist for changed code
3. ✅ Run test suite
4. 🤖 Lightweight AI code review (critical issues only)
5. ✅ Check PR description and requirements

**Human Review**: Final approval only

**Expected Timeline**: Hours to 1-2 days

---

### 🟡 Medium PRs

**Goal**: Thorough validation without slowing you down

**Automated Steps**:
1. ✅ Comprehensive linting and type checking
2. ✅ Verify test coverage for all changes
3. ✅ Run full test suite
4. 🤖 Thorough AI code review
5. ✅ Check all contribution requirements

**Human Review**: Required before merge

**Routing**: Automatically assigned to relevant squad

**Expected Timeline**: 2-5 days

---

### 🔴 Large PRs

**Goal**: Early alignment to ensure effort is well-directed

**Process**:

**Phase 1: Early Alignment (BEFORE extensive automation)**
1. 🚦 Squad notified immediately
2. 👥 Human reviewer checks approach and architecture
3. 💬 Discussion with contributor about implementation
4. ✅ Squad adds `alignment-approved` label when ready

**Phase 2: Automated Validation (AFTER alignment)**
1. ✅ Basic validation checks
2. ✅ Smoke tests
3. 🤖 Lightweight AI review (architectural focus)

**Phase 3: Detailed Review**
1. 👥 In-depth human code review
2. 🎯 Focus on implementation details
3. ✅ Final approval

**Expected Timeline**: 1-2 weeks

**Why this approach?** We want to ensure your effort is aligned with project goals before you invest significant time. It's frustrating to build something large only to find it doesn't fit!

## What to Expect

### After Submitting Your PR

1. **Instant**: Bot adds `pr/external` label
2. **Within 1 minute**: PR is categorized (size + type labels applied)
3. **Within 2 minutes**: You receive a comment explaining the workflow
4. **Within 5 minutes**: Automated validation begins

### Notifications You'll Receive

- 📊 Categorization results with expected workflow
- ✅ Validation status (pass/fail) with specific guidance
- 🤖 AI review feedback (if any issues found)
- 💬 Human reviewer comments and questions
- ✅ Approval and merge notifications

### Squad Notifications

When your PR is ready for human review, the relevant squad is automatically notified via Slack. They'll see:
- Your PR details and category
- Validation status
- AI review summary
- Direct link to review

## Tips for Success

### Before Submitting

- ✅ **Run tests locally**: Ensure all tests pass
- ✅ **Follow style guides**: Run linters locally
- ✅ **Write good descriptions**: Explain your changes clearly
- ✅ **Reference issues**: Link to the issue you're addressing
- ✅ **Add tests**: Include tests for new code

### For Large PRs

- 💡 **Open early**: Submit as draft or discuss in an issue first
- 💡 **Break it down**: Consider splitting into smaller PRs if possible
- 💡 **Document your approach**: Include design notes in PR description
- 💡 **Be responsive**: Reply promptly to alignment feedback

### Writing Good PR Descriptions

Include:
- **What**: What does this PR do?
- **Why**: Why is this change needed?
- **How**: How does it work? (for non-trivial changes)
- **Testing**: How did you test it?
- **Links**: Related issues, docs, discussions

### Commit Message Format

Follow the format: `Area: Description`

Examples:
- `Dashboard: Fix panel rendering bug`
- `Docs: Update contribution guidelines`
- `Alerting: Add support for Slack notifications`

## FAQ

### Why was my PR categorized differently than I selected?

Our automation analyzes actual changes (lines, files, complexity). If there's a mismatch, the auto-detected category takes precedence, but we'll explain why.

### Can I change the category?

If you believe the categorization is incorrect, comment on your PR explaining why. A maintainer can adjust it.

### My Large PR didn't get immediate alignment feedback

Squads are notified, but response times depend on their availability. If you don't hear back within 2-3 business days, feel free to ping in the PR.

### What if I don't have tests?

For new features and bug fixes, tests are required. The automation will flag missing tests and block merging until they're added.

### What if automated checks fail?

The bot will comment with specific guidance. Fix the issues and push - validation runs automatically on each update.

### Can I skip certain checks?

No. All external PRs go through the same validation for quality assurance. However, maintainers can override if there's a good reason.

### How long before my PR is merged?

It varies:
- **Small PRs**: Hours to 2 days
- **Medium PRs**: 2-5 days
- **Large PRs**: 1-2 weeks or more

Response times depend on squad capacity and PR quality.

### My PR has been open for a while with no response

- Check if validation passed
- Ensure you've addressed all automated feedback
- If waiting > 1 week with no feedback, comment asking for status
- Consider joining our community Slack for discussions

## Getting Help

- **Contributing Guide**: [create-pull-request.md](./create-pull-request.md)
- **Style Guides**: [style-guides/](./style-guides/)
- **Community Slack**: [grafana.com/slack](https://grafana.com/slack)
- **Forum**: [community.grafana.com](https://community.grafana.com)

## For Maintainers

See the [Maintainer Guide](./maintainer-external-pr-guide.md) for information on:
- Squad notification configuration
- Manual workflow overrides
- Handling special cases
- Metrics and monitoring

---

Thank you for contributing to Grafana! We appreciate your effort and look forward to your contribution. 🎉


