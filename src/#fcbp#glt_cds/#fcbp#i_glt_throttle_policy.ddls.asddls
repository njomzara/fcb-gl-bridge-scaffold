@EndUserText.label: 'GL Transfer Throttle Policy - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_throttle_policy
  as select from /fcbp/cc_glthrot
{
  key throttle_policy_id as ThrottlePolicyId,
  key version            as Version,
      active_flag        as ActiveFlag,
      lifecycle_state    as LifecycleState,
      config_hash        as ConfigHash,
      max_parallel       as MaxParallel,
      max_per_run        as MaxPerRun,
      rate_limit         as RateLimit,
      dispatch_window    as DispatchWindow,
      retry_backlog_limit as RetryBacklogLimit,
      poll_backlog_limit as PollBacklogLimit,
      changed_by         as ChangedBy,
      changed_at         as ChangedAt
}
