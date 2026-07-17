@EndUserText.label: 'GL Transfer Policy Administration'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_policy_admin
  as select from /fcbp/i_glt_target_profile
{
  key TargetId              as ConfigObjectKey,
      'TARGET_PROFILE'      as ConfigObjectType,
      TargetId,
      CompanyCode,
      ActiveFlag,
      LifecycleState,
      HealthState,
      ConfigVersion,
      ConfigHash,
      ChangedBy,
      ChangedAt
}
