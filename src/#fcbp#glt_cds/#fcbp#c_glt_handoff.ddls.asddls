@EndUserText.label: 'GL Source Handoff Monitor'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_handoff
  as select from /fcbp/i_glt_registration as Reg
  left outer join /fcbp/i_glt_transfer as Transfer
    on Reg.TransferId = Transfer.TransferId
  left outer join /fcbp/i_glt_outbox as Outbox
    on Reg.TransferId = Outbox.TransferId
{
  key Reg.RegistrationKey,
      Reg.RegistrationStatus,
      Reg.SourceType,
      Reg.SourceReference,
      Reg.SourceDocumentNumber,
      Reg.ReconciliationKey,
      Reg.EventType,
      Reg.EventId,
      Reg.RoutingBucket,
      Reg.TargetId,
      Reg.ProcessingMode,
      Reg.TransferId,
      Transfer.ExternalStatus,
      Transfer.StatusCode,
      Transfer.CorrelationId,
      Outbox.OutboxId,
      Outbox.WorkType,
      Outbox.ProcessingStatus,
      Outbox.LockStatus,
      Reg.ReservedBy,
      Reg.ReservedAt,
      Reg.CompletedAt,
      Reg.ExpiresAt,
      Reg.LastErrorCode,
      Reg.CreatedAt,
      Reg.ChangedAt
}

