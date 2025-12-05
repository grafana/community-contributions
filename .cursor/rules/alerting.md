# Alerting Squad Review Rules

These rules apply when:
- PR has the `area/alerting` label, OR
- PR touches any of these file paths:
  - `pkg/services/ngalert/**`
  - `public/app/features/alerting/**`
  - `apps/alerting/**`

## Alerting-Specific Checks

When reviewing alerting code, pay special attention to:

### Alert Rule Validation
- Ensure alert rule configurations are properly validated
- Check for proper error handling in rule evaluation
- Verify timeout handling in alert queries

### Notification Channels
- Check for proper credential handling in notifiers
- Verify retry logic and error handling
- Ensure notification templates are properly escaped

### State Management
- Verify alert state transitions are correct
- Check for race conditions in state updates
- Ensure proper cleanup of stale alert states

### Performance
- Flag expensive queries that could affect alert evaluation
- Check for proper pagination in list operations
- Verify efficient use of database queries

## Contact

<!-- Disabled during pilot testing to avoid noise
For questions about alerting contributions: `@ grafana/alerting-squad` (remove space before @)
-->

