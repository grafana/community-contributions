#!/bin/bash
# Script to post automated PR categorization comment
# Usage: post-pr-comment.sh <pr_number> <size> <type> <repo>

set -e

PR_NUMBER="$1"
SIZE="$2"
TYPE="$3"
REPO="$4"

# Create comment
cat > /tmp/pr-analysis-comment.md << 'EOF'
## 🤖 Automated PR Analysis

Thank you for your contribution to Grafana! Your PR has been automatically analyzed and categorized.

---

### 📊 PR Categorization

| Category | Value |
|----------|-------|
| **Size** | __SIZE__ |
| **Type** | __TYPE__ |

---

### ⚡ What happens next for __SIZE__ PRs:

**Automated Validation**
- Linting and code formatting checks
- Test verification
- PR requirements validation

**Review Process**
- AI review for code quality and security
- Human review by maintainers
- Feedback and iterations as needed

---

### 💡 Tips for Contributors

- Run tests locally before pushing
- Ensure code follows style guidelines  
- Keep descriptions clear and concise
- Respond promptly to feedback

---

### 📚 Resources

- [Contributing Guidelines](https://github.com/grafana/grafana/blob/main/contribute/create-pull-request.md)
- [Community Slack](https://grafana.com/slack)

---

*This analysis was generated automatically. Validation workflows will begin shortly.*
EOF

# Replace placeholders
sed -i "s/__SIZE__/$SIZE/g" /tmp/pr-analysis-comment.md
sed -i "s/__TYPE__/$TYPE/g" /tmp/pr-analysis-comment.md

# Post comment
gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file /tmp/pr-analysis-comment.md

echo "✅ Posted automated comment to PR #$PR_NUMBER"

