@EndUserText.label: 'GL Transfer Support Audit'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_support_audit
  as select from /fcbp/i_glt_audit
{
  key AuditId,
      TransferId,
      EventType,
      EventSubtype,
      DecisionOutcome,
      CompanyCode,
      TargetId,
      SupportTicketId,
      SupportSessionId,
      ActorType,
      ActorId,
      ReasonCode,
      CorrelationId,
      RequestId,
      CreatedAt
}
where EventCategory = 'SUPPORT'
