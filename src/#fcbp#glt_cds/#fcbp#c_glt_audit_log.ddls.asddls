@EndUserText.label: 'GL Transfer Audit Log'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_audit_log
  as select from /fcbp/i_glt_audit as Audit
    left outer join /fcbp/i_glt_transfer_sec_scope as Scope
      on Scope.TransferId = Audit.TransferId
{
  key Audit.AuditId,
      Audit.TransferId,
      Audit.EventCategory,
      Audit.EventType,
      Audit.EventSubtype,
      Audit.DecisionOutcome,
      coalesce( Audit.CompanyCode, Scope.CompanyCode ) as CompanyCode,
      coalesce( Audit.TargetId, Scope.TargetId ) as TargetId,
      Audit.ActorType,
      Audit.ActorId,
      Audit.ReasonCode,
      Audit.EvidenceReference,
      Audit.CorrelationId,
      Audit.RequestId,
      Audit.Criticality,
      Audit.RedactionProfile,
      Audit.CreatedAt
}
