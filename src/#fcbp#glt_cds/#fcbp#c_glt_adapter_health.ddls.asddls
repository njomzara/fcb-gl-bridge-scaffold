@EndUserText.label: 'GL Transfer Adapter Health'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_adapter_health
  as select from /fcbp/c_glt_config_health
{
  key HealthRunId,
  key CheckId,
      TargetId,
      ConfigObjectType,
      ConfigObjectKey,
      Severity,
      BlockingFlag,
      FindingCode,
      OperatorText,
      EvidenceReference,
      CheckedAt,
      CheckedBy
}
where ConfigObjectType = 'TARGET_PROFILE'
