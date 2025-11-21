#!/usr/bin/env bash
#
# copy-pr.sh - Manually copy a PR from grafana/grafana to tonypowa/grafana
#
# Usage:
#   ./scripts/copy-pr.sh <PR_NUMBER>
#
# Example:
#   ./scripts/copy-pr.sh 12345
#
# Requirements:
#   - gh CLI installed and authenticated
#   - PR_COPY_BOT_TOKEN or GITHUB_TOKEN set
#   - Run from repository root
#
# This script allows engineers to manually copy any PR from grafana/grafana
# for testing the categorization and review workflows. It uses the same
# code-copying logic as the automated workflow but triggers on-demand.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check for PR number argument
if [ -z "$1" ]; then
    log_error "PR number required"
    echo ""
    echo "Usage: $0 <PR_NUMBER>"
    echo "Example: $0 12345"
    exit 1
fi

PR_NUMBER="$1"

# Validate PR number is numeric
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    log_error "PR number must be numeric: $PR_NUMBER"
    exit 1
fi

log_info "Starting manual PR copy for grafana/grafana#${PR_NUMBER}"

# Detect GitHub token
if [ -n "$PR_COPY_BOT_TOKEN" ]; then
    export GH_TOKEN="$PR_COPY_BOT_TOKEN"
    log_info "Using PR_COPY_BOT_TOKEN"
elif [ -n "$GITHUB_TOKEN" ]; then
    export GH_TOKEN="$GITHUB_TOKEN"
    log_info "Using GITHUB_TOKEN"
else
    log_error "No GitHub token found. Set PR_COPY_BOT_TOKEN or GITHUB_TOKEN"
    exit 1
fi

# Check gh CLI is installed
if ! command -v gh &> /dev/null; then
    log_error "gh CLI is not installed. Install from: https://cli.github.com/"
    exit 1
fi

# Check we're in the right directory
if [ ! -d ".github" ]; then
    log_error "Must run from repository root (where .github/ exists)"
    exit 1
fi

# Test gh authentication
log_info "Testing GitHub authentication..."
if ! gh auth status &> /dev/null; then
    log_error "gh CLI authentication failed"
    exit 1
fi
log_success "Authenticated"

# Check if PR exists
log_info "Checking if PR #${PR_NUMBER} exists..."
if ! PR_CHECK=$(gh pr view "$PR_NUMBER" --repo grafana/grafana --json number 2>&1); then
    log_error "PR #${PR_NUMBER} not found in grafana/grafana"
    log_error "Error: $PR_CHECK"
    exit 1
fi
log_success "PR #${PR_NUMBER} found"

# Fetch PR details
log_info "Fetching PR details..."
PR_TITLE=$(gh pr view "$PR_NUMBER" --repo grafana/grafana --json title --jq '.title')
PR_BODY=$(gh pr view "$PR_NUMBER" --repo grafana/grafana --json body --jq '.body // ""')
PR_STATE=$(gh pr view "$PR_NUMBER" --repo grafana/grafana --json state --jq '.state')

log_info "Title: $PR_TITLE"
log_info "State: $PR_STATE"

# Load or create tracker
TRACKER_FILE=".github/pr-copy-tracker.json"
if [ ! -f "$TRACKER_FILE" ]; then
    log_warning "Tracker file not found, creating new one"
    echo '{"copied_prs":[],"last_check_timestamp":null}' > "$TRACKER_FILE"
fi

# Check if already copied
COPIED_PRS=$(jq -r '.copied_prs[]' "$TRACKER_FILE")
if echo "$COPIED_PRS" | grep -q "^${PR_NUMBER}$"; then
    log_warning "PR #${PR_NUMBER} already copied according to tracker"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Aborted by user"
        exit 0
    fi
fi

# Create branch name
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BRANCH_NAME="bot/copy-pr-${PR_NUMBER}-${TIMESTAMP}"

log_info "Creating branch: $BRANCH_NAME"

# Get current branch to return to later
ORIGINAL_BRANCH=$(git branch --show-current)

# Create and checkout new branch
git checkout -b "$BRANCH_NAME"
log_success "Branch created"

# Fetch PR diff
log_info "Fetching code changes from PR #${PR_NUMBER}..."
PATCH_FILE="/tmp/pr_${PR_NUMBER}_${TIMESTAMP}.patch"
if ! gh pr diff "$PR_NUMBER" --repo grafana/grafana > "$PATCH_FILE"; then
    log_error "Failed to fetch PR diff"
    git checkout "$ORIGINAL_BRANCH"
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
    exit 1
fi

# Check if PR modifies workflow files
if grep -q "^diff --git a/.github/workflows/" "$PATCH_FILE"; then
    log_error "PR #${PR_NUMBER} modifies workflow files"
    log_warning "Workflow changes require 'workflow' scope on PAT - skipping"
    git checkout "$ORIGINAL_BRANCH"
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
    rm -f "$PATCH_FILE"
    exit 1
fi

# Check if patch is empty
if [ ! -s "$PATCH_FILE" ]; then
    log_error "PR diff is empty - nothing to copy"
    git checkout "$ORIGINAL_BRANCH"
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
    rm -f "$PATCH_FILE"
    exit 1
fi

log_success "Fetched $(wc -l < "$PATCH_FILE") lines of changes"

# Apply patch
log_info "Applying changes..."
if ! git apply "$PATCH_FILE" 2>/dev/null; then
    log_warning "Patch apply had issues, attempting with --reject..."
    if ! git apply --reject "$PATCH_FILE" 2>/dev/null; then
        log_error "Failed to apply patch"
        git checkout "$ORIGINAL_BRANCH"
        git branch -D "$BRANCH_NAME" 2>/dev/null || true
        rm -f "$PATCH_FILE"
        exit 1
    fi
fi
log_success "Changes applied"

# Stage all changes
git add -A

# Check if there are changes to commit
if git diff --staged --quiet; then
    log_error "No changes to commit after applying patch"
    git checkout "$ORIGINAL_BRANCH"
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
    rm -f "$PATCH_FILE"
    exit 1
fi

# Commit changes
log_info "Committing changes..."
git commit -m "Copy of PR ${PR_NUMBER}" -m "Original: https://github.com/grafana/grafana/pull/${PR_NUMBER}"
log_success "Changes committed"

# Push branch
log_info "Pushing branch to origin..."
if ! git push origin "$BRANCH_NAME"; then
    log_error "Failed to push branch"
    git checkout "$ORIGINAL_BRANCH"
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
    rm -f "$PATCH_FILE"
    exit 1
fi
log_success "Branch pushed"

# Sanitize PR body to break issue references
log_info "Preparing PR description..."
SANITIZED_BODY=$(echo "$PR_BODY" | \
    sed 's/<!--.*-->//g' | \
    sed -E 's/#([0-9]+)/# \1/g' | \
    sed -E 's/\/(issues|pull)\//\/\1\/ /g')

# Create PR description file
PR_DESC_FILE="/tmp/pr_description_${PR_NUMBER}_${TIMESTAMP}.txt"
cat > "$PR_DESC_FILE" << EOF
$SANITIZED_BODY

---

**Automated test copy from upstream**

Original PR: https://github.com/grafana/grafana/pull/ ${PR_NUMBER}

This PR was manually copied using \`scripts/copy-pr.sh\` for testing the external PR categorization and review workflows.
EOF

# Get current repo (should be the fork, not upstream)
CURRENT_REPO=$(git remote get-url origin | sed -E 's|.*github\.com[:/]||' | sed 's|\.git$||')

# Create PR in the FORK, not upstream
log_info "Creating PR in $CURRENT_REPO..."
if NEW_PR_URL=$(gh pr create \
    --repo "$CURRENT_REPO" \
    --base main \
    --head "$BRANCH_NAME" \
    --title "$PR_TITLE" \
    --body-file "$PR_DESC_FILE" 2>&1); then
    
    log_success "PR created: $NEW_PR_URL"
    
    # Update tracker
    log_info "Updating tracker..."
    jq --arg pr "$PR_NUMBER" '.copied_prs += [$pr | tonumber] | .copied_prs |= (unique | sort)' \
        "$TRACKER_FILE" > "${TRACKER_FILE}.tmp"
    mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
    
    # Update timestamp
    jq --arg ts "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" '.last_check_timestamp = $ts' \
        "$TRACKER_FILE" > "${TRACKER_FILE}.tmp"
    mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
    
    log_success "Tracker updated"
    
    # Commit tracker update
    git checkout "$ORIGINAL_BRANCH"
    git add "$TRACKER_FILE"
    if ! git diff --staged --quiet; then
        git commit -m "Bot: Update PR copy tracker (manual copy of #${PR_NUMBER})"
        git push origin "$ORIGINAL_BRANCH"
        log_success "Tracker committed to $ORIGINAL_BRANCH"
    fi
    
else
    log_error "Failed to create PR: $NEW_PR_URL"
    git checkout "$ORIGINAL_BRANCH"
    rm -f "$PATCH_FILE" "$PR_DESC_FILE"
    exit 1
fi

# Cleanup
rm -f "$PATCH_FILE" "$PR_DESC_FILE"

echo ""
log_success "✨ Successfully copied PR #${PR_NUMBER}!"
log_info "New PR: $NEW_PR_URL"
log_info "Branch: $BRANCH_NAME"
echo ""
log_info "The categorization workflow should trigger automatically for this PR."
