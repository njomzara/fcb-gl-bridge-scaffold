@EndUserText.label: 'GL Transfer Configuration Audit'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_config_audit
  as select from /fcbp/i_glt_audit
{
  key AuditId,
      EventType,
      EventSubtype,
      DecisionOutcome,
      CompanyCode,
      TargetId,
      ConfigObjectType,
      ConfigObjectKey,
      ConfigVersion,
      ActorType,
      ActorId,
      ReasonCode,
      OldValueHash,
      NewValueHash,
      EvidenceReference,
      CreatedAt
}
where EventCategory = 'CONFIG'
