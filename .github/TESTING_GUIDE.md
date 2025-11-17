# Testing Guide for Adaptive PR Workflow

This guide explains how to test the adaptive PR workflow system after implementation.

## Prerequisites for Testing

Before testing, ensure:
- [ ] All workflow files are committed to your fork
- [ ] GitHub Actions are enabled in repository settings
- [ ] You have access to create PRs from different accounts
- [ ] (Optional) Slack webhooks are configured for notifications

## Test Scenarios

### Test 1: Small PR - Happy Path

**Objective**: Verify small PR workflow with passing validation

**Steps**:
1. Create a new branch with a small change:
   ```bash
   git checkout -b test-small-pr
   echo "# Test" >> README.md
   git add README.md
   git commit -m "Docs: Add test line to README"
   git push origin test-small-pr
   ```

2. Open PR from a non-member account
   - Use GitHub's "Create Pull Request" from the branch
   - Or fork → create PR from fork

3. Fill out PR template selecting:
   - Type: 📝 Documentation
   - Size: 🟢 Small

**Expected Results**:
- [ ] PR labeled with `pr/external`
- [ ] PR labeled with `size:small` and `pr-category:docs`
- [ ] Bot comment explaining workflow
- [ ] Validation workflow runs
- [ ] All checks pass (or skip if no linters configured)
- [ ] Squad notification sent (if Slack configured)
- [ ] Status check shows ✅

**Timeline**: Should complete within 2-5 minutes

---

### Test 2: Medium PR - With Failing Tests

**Objective**: Verify medium PR handles validation failures

**Steps**:
1. Create a branch with moderate changes:
   ```bash
   git checkout -b test-medium-pr
   # Make changes to 5-8 files, 200-300 lines
   # Intentionally don't add tests
   git add .
   git commit -m "Feature: Add new dashboard component"
   git push origin test-medium-pr
   ```

2. Open PR selecting:
   - Type: ✨ Feature
   - Size: 🟡 Medium

**Expected Results**:
- [ ] PR labeled with `size:medium` and `pr-category:feature`
- [ ] Bot comment about comprehensive validation
- [ ] Validation runs
- [ ] Validation fails due to missing tests
- [ ] Bot comment lists specific failures
- [ ] Instructions provided to fix
- [ ] No squad notification (validation not passed)

**Fix and Re-test**:
1. Add test files
2. Push changes
3. Validation should re-run automatically
4. Should pass and notify squad

---

### Test 3: Large PR - Early Alignment

**Objective**: Verify large PR requests early human review

**Steps**:
1. Create branch with major changes:
   ```bash
   git checkout -b test-large-pr
   # Make changes to 15+ files, 600+ lines
   # Implement a significant feature
   git add .
   git commit -m "Feature: Complete dashboard redesign"
   git push origin test-large-pr
   ```

2. Open PR selecting:
   - Type: ✨ Feature
   - Size: 🔴 Large

**Expected Results**:
- [ ] PR labeled with `size:large`
- [ ] Bot comment requesting early alignment
- [ ] Label `awaiting-alignment` added
- [ ] Squad notified immediately
- [ ] NO automated validation runs yet
- [ ] Comment explains to wait for human review

**Continue Test**:
1. Have a maintainer add `alignment-approved` label
2. Validation should trigger automatically
3. Lighter validation (smoke tests only)
4. Second squad notification when complete

---

### Test 4: Category Conflict

**Objective**: Verify auto-detection overrides incorrect self-selection

**Steps**:
1. Create small change (< 50 lines)
2. In PR template, select:
   - Size: 🔴 Large (intentionally wrong)

**Expected Results**:
- [ ] Bot detects conflict
- [ ] Applies correct size (`size:small`)
- [ ] Comment warns about mismatch
- [ ] Explains auto-detection reasoning

---

### Test 5: Slack Notifications

**Objective**: Verify squad notifications work (requires Slack setup)

**Prerequisites**:
- Slack webhooks configured
- Secrets added to repository

**Steps**:
1. Create any PR that passes validation
2. Wait for squad notification

**Expected Results**:
- [ ] Slack message appears in correct channel
- [ ] Message includes:
  - PR link
  - Author
  - Category (size + type)
  - Validation status
  - "View PR" button
- [ ] Clicking button opens PR

---

### Test 6: Multiple Workflows (Stress Test)

**Objective**: Verify system handles multiple concurrent PRs

**Steps**:
1. Open 3-5 PRs simultaneously:
   - Mix of small, medium, large
   - Different types (docs, feature, bugfix)

**Expected Results**:
- [ ] All PRs categorized correctly
- [ ] No workflow collisions
- [ ] Each PR gets appropriate validation
- [ ] All notifications sent correctly
- [ ] No duplicate comments

---

## Manual Testing Checklist

After automated tests, manually verify:

### Categorization System
- [ ] Small PRs (< 100 lines) categorized correctly
- [ ] Medium PRs (100-500 lines) categorized correctly
- [ ] Large PRs (> 500 lines) categorized correctly
- [ ] Docs PRs identified by file paths
- [ ] Feature PRs identified correctly
- [ ] Bugfix PRs identified correctly

### Validation Workflows
- [ ] Small: Lightweight checks only
- [ ] Medium: Comprehensive validation
- [ ] Large: Early alignment before validation
- [ ] Test verification works
- [ ] Linting checks work (if configured)
- [ ] PR requirements checker works

### User Experience
- [ ] PR template is clear
- [ ] Bot comments are helpful
- [ ] Error messages are actionable
- [ ] Workflow transitions are smooth
- [ ] No confusing or duplicate messages

### Squad Notifications
- [ ] Correct squad identified
- [ ] Notifications sent at right time
- [ ] Message format is clear
- [ ] Links work correctly

## Integration Testing

### Test with Real External Contributors

1. Announce testing period in community channels
2. Invite external contributors to submit test PRs
3. Monitor their experience
4. Collect feedback via:
   - GitHub comments
   - Slack messages
   - Survey (Google Form)

### Feedback Questions

Ask contributors:
- Was the categorization accurate?
- Were bot messages helpful?
- Was the process clear?
- How long did review take?
- Any confusion or frustration?
- Suggestions for improvement?

## Performance Testing

### Metrics to Monitor

Track these metrics after deployment:

**Volume**:
- Total external PRs
- PRs per category
- PRs per type

**Quality**:
- % passing initial validation
- % requiring fixes
- Average iterations to pass

**Timing**:
- Time to categorization
- Time to validation complete
- Time to first human review
- Time to merge

**Squad Response**:
- Notification delivery success rate
- Squad response time after notification
- Response time by category

## Troubleshooting Tests

### Workflow Doesn't Run

Check:
- GitHub Actions enabled?
- Correct trigger (`pull_request_target`)?
- PR from external account?
- Workflow file syntax valid?

Debug:
```bash
# Validate workflow syntax
act -l  # if using 'act' locally
# Or check Actions tab for errors
```

### Categorization Wrong

Check:
- Changed files count
- Lines changed count
- Labels already applied
- File paths match patterns

Debug: Look at workflow logs in Actions tab

### Validation Fails

Check:
- Are dependencies installed?
- Do tests exist?
- Is code formatted correctly?
- Are all tools available?

Debug: Run commands locally:
```bash
yarn lint  # for frontend
go test ./...  # for backend
```

### Notifications Not Sent

Check:
- Webhook secret configured?
- Secret name matches squad-mapping.json?
- Webhook URL valid?
- Channel exists?

Debug: Test webhook manually:
```bash
curl -X POST YOUR_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"text": "Test message"}'
```

## Rollback Plan

If critical issues found during testing:

1. **Immediate**: Disable workflow
   ```yaml
   # Add to top of external-pr-automation.yml
   on:
     workflow_dispatch:  # Manual trigger only
   ```

2. **Quick Fix**: Fix issue and re-enable

3. **Major Issues**: Revert to previous state
   ```bash
   git revert <commit-hash>
   git push
   ```

4. **Communication**: Notify contributors of any issues

## Success Criteria

Consider testing successful when:

- [ ] All automated tests pass
- [ ] Manual testing checklist complete
- [ ] Real PRs processed successfully
- [ ] Positive contributor feedback
- [ ] No critical bugs found
- [ ] Squad satisfaction with notifications
- [ ] Metrics showing improvement over baseline

## Next Steps After Testing

1. Document any issues found
2. Make necessary adjustments
3. Run final verification
4. Announce to community
5. Monitor closely after launch
6. Collect feedback
7. Iterate based on learnings

---

**Who Should Test**:
- Maintainers (you)
- Friendly external contributors
- Each squad representative

**When to Test**:
- After initial implementation
- After any major changes
- Quarterly for regression testing

