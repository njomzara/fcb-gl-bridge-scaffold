@EndUserText.label: 'GL Transfer Config Health - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_config_health
  as select from /fcbp/glt_cfghlth
{
  key health_run_id      as HealthRunId,
  key check_id           as CheckId,
      target_id          as TargetId,
      config_object_type as ConfigObjectType,
      config_object_key  as ConfigObjectKey,
      severity           as Severity,
      blocking_flag      as BlockingFlag,
      finding_code       as FindingCode,
      operator_text      as OperatorText,
      evidence_ref       as EvidenceReference,
      checked_at         as CheckedAt,
      checked_by         as CheckedBy
}
