@EndUserText.label: 'GL Transfer Confirmation Policy - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_confirm_policy
  as select from /fcbp/cc_glconf
{
  key confirmation_policy_id as ConfirmationPolicyId,
  key version                as Version,
      active_flag            as ActiveFlag,
      lifecycle_state        as LifecycleState,
      config_hash            as ConfigHash,
      confirmation_mode      as ConfirmationMode,
      status_query_required  as StatusQueryRequired,
      poll_interval_sec      as PollIntervalSeconds,
      max_poll_duration_sec  as MaxPollDurationSeconds,
      status_handle_type     as StatusHandleType,
      unknown_behavior       as UnknownConfirmationBehavior,
      safe_retry_after_negative_query as SafeRetryAfterNegativeQuery,
      changed_by             as ChangedBy,
      changed_at             as ChangedAt
}
