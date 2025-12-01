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

# Generate comment
cat > /tmp/categorization-comment.md <<EOF
## ${TYPE_EMOJI} PR Categorized: ${TYPE_NAME} ${SIZE_EMOJI} (Size: ${SIZE})

Thanks for your contribution! We've categorized your PR to provide the right level of validation.

### What Happens Next

1. **Automated checks** will run (we monitor existing CI/CD, no duplicates!)
2. **You'll get a checklist** showing what's being validated
3. **Our AI companion** will provide friendly feedback on code quality and tests
4. **A human reviewer** will provide final approval

$(if [ "$SIZE" = "large" ]; then echo "
> **Note for Large PRs**: We'll start with an early alignment phase to ensure your approach fits with our goals before diving into detailed validation. This saves everyone time!
"; fi)

### What You Can Do

- **Push updates anytime** - validation updates automatically!
- Check your validation comment for specific todos
- Address any feedback from automated checks or AI review

---

💡 See our [External PR Workflow Guide](../contribute/external-pr-workflow.md) for more details.

<!-- external-pr-categorization-comment -->
EOF

# Post comment using gh CLI
gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file /tmp/categorization-comment.md

echo "✅ Posted categorization comment to PR #$PR_NUMBER"
