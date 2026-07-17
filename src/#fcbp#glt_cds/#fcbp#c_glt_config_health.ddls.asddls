@EndUserText.label: 'GL Transfer Configuration Health'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_config_health
  as select from /fcbp/i_glt_config_health
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
