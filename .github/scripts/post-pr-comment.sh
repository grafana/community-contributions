#!/bin/bash
# Post initial categorization comment for external PRs
# Usage: post-pr-comment.sh <pr-number> <size> <type> <repository>

set -e

PR_NUMBER="$1"
SIZE="$2"
TYPE="$3"
REPO="$4"

if [ -z "$PR_NUMBER" ] || [ -z "$SIZE" ] || [ -z "$TYPE" ] || [ -z "$REPO" ]; then
  echo "Usage: $0 <pr-number> <size> <type> <repository>"
  exit 1
fi

# Map type for display
case "$TYPE" in
  docs)
    TYPE_EMOJI="📝"
    TYPE_NAME="Documentation"
    ;;
  bugfix)
    TYPE_EMOJI="🐛"
    TYPE_NAME="Bugfix"
    ;;
  feature)
    TYPE_EMOJI="✨"
    TYPE_NAME="Feature"
    ;;
  *)
    TYPE_EMOJI="📦"
    TYPE_NAME="$TYPE"
    ;;
esac

# Map size for display
case "$SIZE" in
  small)
    SIZE_EMOJI="🟢"
    ;;
  medium)
    SIZE_EMOJI="🟡"
    ;;
  large)
    SIZE_EMOJI="🔴"
    ;;
  *)
    SIZE_EMOJI="⚪"
    ;;
esac

# Generate comment based on size
if [ "$SIZE" = "large" ]; then
  # Large PR - different flow (alignment first)
  cat > /tmp/categorization-comment.md <<EOF
## ${TYPE_EMOJI} PR Categorized: ${TYPE_NAME} ${SIZE_EMOJI} (Size: ${SIZE})

Thanks for your contribution! This is a substantial PR, so we'll start with early alignment.

### What happens next

1. **Early alignment** - A squad member will review your approach first
2. **Once aligned** - We'll add the \`alignment-approved\` label
3. **Automated checks + code review** - CI runs and an automation reviews your code
4. **Final review** by a squad member (verifies all feedback is addressed)

### About the automated code review 🤖

An automation will review your code and leave inline comments for any issues it finds:
- **Fix directly in GitHub** - Click "Fix in Web" to resolve issues without leaving
- **Mark each comment as resolved** when you've addressed it
- ✅ **Once all comments are resolved, the code review is complete!**
- **Having issues?** Comment \`skip-automated-review\` and let us know what happened

### What you can do now

- **Add context** about your implementation approach
- **Be ready to discuss** the design with a squad member
- Wait for alignment before addressing detailed feedback

---

💡 See our [External PR Workflow Guide](../contribute/external-pr-workflow.md) for more details.

<!-- external-pr-categorization-comment -->
EOF
else
  # Small/Medium PR - standard flow
  cat > /tmp/categorization-comment.md <<EOF
## ${TYPE_EMOJI} PR Categorized: ${TYPE_NAME} ${SIZE_EMOJI} (Size: ${SIZE})

Thanks for your contribution! We've categorized your PR to provide the right level of validation.

### What happens next

1. **Automated checks** will run (we monitor existing CI/CD)
2. **Automated code review** will leave inline comments if issues are found
3. **You'll get a checklist** showing what's being validated
4. **A squad member** will verify all feedback is addressed and provide final approval

### About the automated code review 🤖

An automation will review your code and leave inline comments for any issues it finds:
- **Fix directly in GitHub** - Click "Fix in Web" to resolve issues without leaving
- **Mark each comment as resolved** when you've addressed it
- ✅ **Once all comments are resolved, the code review is complete!**
- **Having issues?** Comment \`skip-automated-review\` and let us know what happened

### What you can do

- **Push updates anytime** - validation updates automatically!
- Check your validation comment for specific todos
- Address automated feedback directly in the PR

---

💡 See our [External PR Workflow Guide](../contribute/external-pr-workflow.md) for more details.

<!-- external-pr-categorization-comment -->
EOF
fi

# Post comment using gh CLI
gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file /tmp/categorization-comment.md

echo "✅ Posted categorization comment to PR #$PR_NUMBER"
