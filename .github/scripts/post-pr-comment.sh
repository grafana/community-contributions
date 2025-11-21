#!/bin/bash
# Script to post automated PR categorization comment
# Usage: post-pr-comment.sh <pr_number> <size> <type> <repo>

set -e

PR_NUMBER="$1"
SIZE="$2"
TYPE="$3"
REPO="$4"

# Start building the comment
cat > /tmp/pr-analysis-comment.md << 'EOF'
## Automated PR analysis

Thank you for your contribution to Grafana! We want to make it easier for both community contributors and engineers, so we're going to help you get your PR super ready before human review so your chances of getting it merged increase.

Your PR has been categorized based on its size and type:

| Category | Value |
|----------|-------|
| **Size** | __SIZE__ |
| **Type** | __TYPE__ |

EOF

# Add override message if applicable (only for large PRs with AI override)
if [ -n "$OVERRIDE_REASON" ] && [ "$OVERRIDE_REASON" != "" ]; then
  cat >> /tmp/pr-analysis-comment.md << EOF

> **Note:** This PR was originally labeled as \`type/$ORIGINAL_LABEL\` but appears to be a $AI_CLASSIFIED PR with documentation updates. Based on AI analysis and PR size, we've classified it as \`type/$AI_CLASSIFIED\` for appropriate validation. If you disagree, a maintainer can manually update the labels (see correction instructions below).

EOF
fi

# Add size-specific Review Process section
if [ "$SIZE" = "small" ]; then
  cat >> /tmp/pr-analysis-comment.md << 'EOF'
**Review process**
1. Automated validation (linting, code formatting, tests, requirements)
1. AI review
1. Human review for final approval

EOF
elif [ "$SIZE" = "medium" ]; then
  cat >> /tmp/pr-analysis-comment.md << 'EOF'
**Review process**
1. Automated validation (linting, code formatting, tests, requirements)
1. Comprehensive AI review (code quality, security, best practices)
1. Automatically routed to the relevant squad based on affected areas
1. Human review required before merge

EOF
elif [ "$SIZE" = "large" ]; then
  cat >> /tmp/pr-analysis-comment.md << 'EOF'
**Review process**
1. Early alignment checkpoint: A squad member reviews your approach first
1. Discussion about implementation strategy
1. Once aligned, comprehensive validation runs
1. Detailed human code review after alignment

⚠️ **Important for large PRs**: We want to ensure your effort is well-directed before you invest significant time. A maintainer will review the architectural approach and provide feedback. Once we add the `alignment-approved` label, automated validation will proceed.

EOF
fi

# Add common footer sections
cat >> /tmp/pr-analysis-comment.md << 'EOF'

**To correct this categorization**

If the size or type categorization seems incorrect, a maintainer can update it by adding the correct labels:
- **Type labels:** `type/bug`, `type/feature`, or `type/docs`
- **Size labels:** `size:small`, `size:medium`, or `size:large`

When labels are updated, the workflow will automatically re-run and trigger the appropriate validation steps for the new classification.

---

**Resources**
- [Contributing guidelines](https://github.com/grafana/grafana/blob/main/CONTRIBUTING.md)
- [Create a pull request](https://github.com/grafana/grafana/blob/main/contribute/create-pull-request.md)
- [Community forums](https://gra.fan/fromgithubtoforums)
- [Community Slack](https://slack.grafana.com/)

*This analysis was generated automatically. Validation workflows should begin shortly.*
EOF

# Replace placeholders
sed -i "s/__SIZE__/$SIZE/g" /tmp/pr-analysis-comment.md
sed -i "s/__TYPE__/$TYPE/g" /tmp/pr-analysis-comment.md

# Post comment
gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file /tmp/pr-analysis-comment.md

echo "✅ Posted automated comment to PR #$PR_NUMBER (size: $SIZE, type: $TYPE)"

