@EndUserText.label: 'GL Transfer Security Decision'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_security_decision
  as select from /fcbp/i_glt_audit
{
  key AuditId,
      TransferId,
      EventType,
      EventSubtype as ProtectedAction,
      DecisionOutcome,
      CompanyCode,
      TargetId,
      ActorType,
      ActorId,
      ReasonCode,
      SupportTicketId,
      CorrelationId,
      RequestId,
      CreatedAt
}
where EventCategory = 'SECURITY'
