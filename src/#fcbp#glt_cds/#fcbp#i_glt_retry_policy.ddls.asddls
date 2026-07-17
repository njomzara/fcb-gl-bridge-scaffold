@EndUserText.label: 'GL Transfer Retry Policy - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_retry_policy
  as select from /fcbp/cc_glretry
{
  key retry_policy_id  as RetryPolicyId,
  key version          as Version,
      active_flag      as ActiveFlag,
      lifecycle_state  as LifecycleState,
      valid_from       as ValidFrom,
      valid_to         as ValidTo,
      config_hash      as ConfigHash,
      max_attempts     as MaxAttempts,
      retryable_categories as RetryableCategories,
      initial_delay_sec as InitialDelaySeconds,
      max_delay_sec    as MaxDelaySeconds,
      backoff_model    as BackoffModel,
      jitter_policy    as JitterPolicy,
      exhaustion_behavior as ExhaustionBehavior,
      poll_before_retry as PollBeforeRetry,
      operator_action_rule as OperatorActionRule,
      changed_by       as ChangedBy,
      changed_at       as ChangedAt
}
