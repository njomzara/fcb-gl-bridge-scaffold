@EndUserText.label: 'GL Transfer Target Profile - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_target_profile
  as select from /fcbp/cc_gltgt
{
  key target_id              as TargetId,
      target_type            as TargetType,
      adapter_type           as AdapterType,
      destination_alias      as DestinationAlias,
      transfer_mode          as TransferMode,
      confirmation_mode      as ConfirmationMode,
      retry_policy_id        as RetryPolicyId,
      aggregation_profile_id as AggregationProfileId,
      split_profile_id       as SplitProfileId,
      validation_profile_id  as ValidationProfileId,
      mapping_policy_id      as MappingPolicyId,
      throttle_policy_id     as ThrottlePolicyId,
      confirmation_policy_id as ConfirmationPolicyId,
      source_system          as SourceSystem,
      source_type            as SourceType,
      transfer_type          as TransferType,
      company_code           as CompanyCode,
      ledger_group           as LedgerGroup,
      processing_mode        as ProcessingMode,
      active_flag            as ActiveFlag,
      lifecycle_state        as LifecycleState,
      valid_from             as ValidFrom,
      valid_to               as ValidTo,
      priority               as Priority,
      health_state           as HealthState,
      config_version         as ConfigVersion,
      config_hash            as ConfigHash,
      created_by             as CreatedBy,
      created_at             as CreatedAt,
      changed_by             as ChangedBy,
      changed_at             as ChangedAt,
      activated_by           as ActivatedBy,
      activated_at           as ActivatedAt
}
