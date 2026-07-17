@EndUserText.label: 'GL Transfer Policy Context - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_policy_context
  as select from /fcbp/glt_polctx
{
  key policy_context_id     as PolicyContextId,
      transfer_id           as TransferId,
      package_id            as PackageId,
      outbox_id             as OutboxId,
      target_id             as TargetId,
      target_profile_version as TargetProfileVersion,
      target_profile_hash   as TargetProfileHash,
      aggregation_profile_id as AggregationProfileId,
      aggregation_version   as AggregationVersion,
      aggregation_hash      as AggregationHash,
      split_profile_id      as SplitProfileId,
      split_version         as SplitVersion,
      split_hash            as SplitHash,
      validation_profile_id as ValidationProfileId,
      validation_version    as ValidationVersion,
      validation_hash       as ValidationHash,
      mapping_policy_id     as MappingPolicyId,
      mapping_version       as MappingVersion,
      mapping_hash          as MappingHash,
      retry_policy_id       as RetryPolicyId,
      retry_version         as RetryVersion,
      retry_hash            as RetryHash,
      throttle_policy_id    as ThrottlePolicyId,
      throttle_version      as ThrottleVersion,
      throttle_hash         as ThrottleHash,
      confirmation_policy_id as ConfirmationPolicyId,
      confirmation_version  as ConfirmationVersion,
      confirmation_hash     as ConfirmationHash,
      resolved_at           as ResolvedAt,
      resolved_by           as ResolvedBy,
      validity_from         as ValidityFrom,
      validity_to           as ValidityTo
}
