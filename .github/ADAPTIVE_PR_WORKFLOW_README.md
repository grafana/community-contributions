# Adaptive PR Workflow - Setup & Configuration

This document explains how the adaptive PR workflow system is configured and how to set it up on your fork or the main repository.

## Overview

The adaptive PR workflow automatically categorizes external PRs by size and type, then applies appropriate validation and routing. It implements **Proposal 4** from the Community Contributions design document.

## Architecture

### Workflow Structure

```
external-pr-automation.yml (Main Orchestrator)
├── categorize-external-pr.yml
│   └── actions/categorize-pr
├── validate-small-pr.yml
│   ├── actions/detect-areas
│   ├── actions/check-requirements
│   ├── actions/verify-tests
│   └── actions/notify-squad
├── validate-medium-pr.yml
│   └── (same actions as small)
├── validate-large-pr.yml
│   └── (same actions + early alignment)
└── cursor-bugbot.yml
```

### Key Components

1. **PR Template** (`.github/PULL_REQUEST_TEMPLATE.md`)
   - Contributor self-selection interface
   - Explains expected workflow per category

2. **Categorization** (`.github/workflows/categorize-external-pr.yml`)
   - Detects size (lines + files changed)
   - Detects type (from labels or file paths)
   - Posts explanatory comment

3. **Validation Workflows** (`.github/workflows/validate-*-pr.yml`)
   - Small: Lightweight checks
   - Medium: Comprehensive validation
   - Large: Early alignment + focused validation

4. **Shared Actions** (`.github/actions/`)
   - `categorize-pr`: Auto-detect size & type
   - `detect-areas`: Identify affected code areas
   - `verify-tests`: Check test coverage
   - `check-requirements`: Validate PR requirements
   - `notify-squad`: Send Slack notifications

5. **Configuration Files**
   - `squad-mapping.json`: Squad/channel mappings
   - `bugbot-config.yml`: AI review rules

## Setup Instructions

### Prerequisites

- GitHub repository with Actions enabled
- Slack workspace (for notifications)
- Cursor Bugbot API access (optional, for AI review)

### Step 1: Copy Files to Your Repository

All necessary files are already in place in this repository:

```
.github/
├── PULL_REQUEST_TEMPLATE.md
├── workflows/
│   ├── external-pr-automation.yml
│   ├── categorize-external-pr.yml
│   ├── validate-small-pr.yml
│   ├── validate-medium-pr.yml
│   ├── validate-large-pr.yml
│   └── cursor-bugbot.yml
├── actions/
│   ├── categorize-pr/action.yml
│   ├── detect-areas/action.yml
│   ├── verify-tests/action.yml
│   ├── check-requirements/action.yml
│   └── notify-squad/action.yml
├── squad-mapping.json
└── bugbot-config.yml
```

### Step 2: Configure Squad Mappings

Edit `.github/squad-mapping.json` to match your team structure:

```json
{
  "squads": [
    {
      "name": "your-squad-name",
      "slack_channel": "#your-channel",
      "slack_webhook_secret": "SLACK_WEBHOOK_YOUR_SQUAD",
      "file_patterns": ["path/to/your/code/**/*"],
      "labels": ["area/your-area"]
    }
  ],
  "default_squad": {
    "name": "triage",
    "slack_channel": "#external-pr-triage",
    "slack_webhook_secret": "SLACK_WEBHOOK_DEFAULT"
  }
}
```

### Step 3: Create Slack Webhooks

For each squad:

1. Go to your Slack workspace settings
2. Create an Incoming Webhook for the squad's channel
3. Copy the webhook URL
4. Add as a GitHub repository secret (see Step 4)

### Step 4: Configure GitHub Secrets

Add these secrets to your repository (Settings → Secrets and variables → Actions):

**Required for Slack Notifications:**
- `SLACK_WEBHOOK_DEFAULT` - Default/triage channel webhook
- `SLACK_WEBHOOK_FRONTEND` - Frontend squad channel webhook
- `SLACK_WEBHOOK_BACKEND` - Backend squad channel webhook
- `SLACK_WEBHOOK_ALERTING` - Alerting squad channel webhook
- ...add one for each squad in squad-mapping.json

**Optional for AI Review:**
- `CURSOR_BUGBOT_TOKEN` - Cursor Bugbot API token

**Note:** Workflow will function without these secrets, but will skip the corresponding features.

### Step 5: Test the Workflow

1. Create a test PR from a non-member account (or remove yourself as a collaborator temporarily)
2. Observe the workflow:
   - PR should be labeled `pr/external`
   - Size and type labels should be applied
   - Validation workflow should run
   - Comment should explain the process
3. Check GitHub Actions tab for workflow execution
4. Verify Slack notifications if configured

### Step 6: Adjust Thresholds (Optional)

Edit `.github/actions/categorize-pr/action.yml` to adjust size thresholds:

```yaml
# Current thresholds:
# Small: < 100 lines, 1-3 files
# Medium: 100-500 lines, 4-10 files
# Large: > 500 lines, > 10 files
```

## Configuration Options

### Customizing Validation Rules

Edit validation workflows to adjust:
- Which linting tools run
- Test coverage requirements
- Commit message format rules
- Required PR fields

### Customizing AI Review

Edit `.github/bugbot-config.yml`:
- Focus areas per category
- Max comments per review
- Security checks
- Language-specific rules

### Customizing Notifications

Edit `.github/actions/notify-squad/action.yml`:
- Message format
- Included information
- Slack blocks layout

## Monitoring & Metrics

### Suggested Metrics to Track

- Time from PR submission to first review
- % of PRs passing automated validation
- Squad response times after notification
- External contributor satisfaction (surveys)
- PRs merged vs. closed
- Average time-to-merge per category

### Viewing Workflow Runs

- GitHub → Actions tab → Select workflow
- Filter by PR number or workflow run
- Check logs for detailed execution info

## Troubleshooting

### Workflow Not Triggering

**Problem:** Workflow doesn't run on external PRs

**Solutions:**
- Verify `pull_request_target` trigger is used (not `pull_request`)
- Check if PR author has MEMBER or OWNER association
- Ensure GitHub Actions are enabled for the repository

### Categorization Not Working

**Problem:** PR not categorized or wrong category

**Solutions:**
- Check workflow logs in Actions tab
- Verify `gh` CLI commands are working
- Ensure PR has sufficient permissions to add labels

### Slack Notifications Not Sending

**Problem:** No Slack messages received

**Solutions:**
- Verify webhook secret names match squad-mapping.json
- Check webhook URLs are valid
- Test webhook manually with curl
- Check workflow logs for error messages

### AI Review Not Running

**Problem:** Cursor Bugbot review skipped

**Solutions:**
- Verify `CURSOR_BUGBOT_TOKEN` secret is set
- Check Bugbot API status
- Review workflow logs for API errors
- Workflow will continue without AI review if token is missing

### Tests Failing

**Problem:** Validation fails on test verification

**Solutions:**
- Ensure test files follow naming conventions
- Check that tests actually exist for changed code
- Review skip patterns in verify-tests action
- Contributors can fix by adding missing tests

## Maintenance

### Regular Tasks

- **Weekly**: Review workflow execution metrics
- **Monthly**: Check for workflow improvements based on feedback
- **Quarterly**: Survey external contributors for satisfaction
- **As Needed**: Update squad mappings when teams change

### Updating the System

1. Test changes on a fork first
2. Update one workflow at a time
3. Monitor for issues after deployment
4. Document changes in this file

## Support

For issues or questions:
- **Contributors**: See [external-pr-workflow.md](../contribute/external-pr-workflow.md)
- **Maintainers**: Create an issue with `workflow-automation` label
- **Internal**: Ask in `#grafana-automation` Slack channel

## Future Enhancements

Planned improvements:
- Integration with additional AI review tools
- More granular categorization (complexity scoring)
- Automatic PR splitting suggestions for large PRs
- Dashboard for workflow metrics
- Bot commands for manual overrides

---

**Version:** 1.0  
**Last Updated:** 2025-01-14  
**Maintained By:** Platform Team


