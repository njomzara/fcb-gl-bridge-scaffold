@EndUserText.label: 'GL Transfer Target Profile'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_target_profile
  as select from /fcbp/i_glt_target_profile
{
  key TargetId,
      TargetType,
      AdapterType,
      DestinationAlias,
      TransferMode,
      ConfirmationMode,
      RetryPolicyId,
      AggregationProfileId,
      SplitProfileId,
      ValidationProfileId,
      MappingPolicyId,
      ThrottlePolicyId,
      ConfirmationPolicyId,
      CompanyCode,
      SourceSystem,
      SourceType,
      TransferType,
      ActiveFlag,
      LifecycleState,
      HealthState,
      ConfigVersion,
      ConfigHash,
      ChangedBy,
      ChangedAt,
      ActivatedBy,
      ActivatedAt
}
