@EndUserText.label: 'GL Transfer Queue Monitor'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_queue
  as select from /fcbp/i_glt_outbox as Outbox
    left outer join /fcbp/i_glt_transfer as Transfer
      on Transfer.TransferId = Outbox.TransferId
{
  key Outbox.OutboxId,
      Outbox.TransferId,
      Outbox.WorkType,
      Outbox.ProcessingStatus,
      Outbox.LockStatus,
      Outbox.DueAt,
      Outbox.Priority,
      Outbox.AttemptNo,
      Outbox.TargetId,
      Transfer.ExternalStatus,
      Transfer.StatusCode,
      Transfer.InternalState,
      Transfer.ConfirmationPending,
      Transfer.OperatorActionRequired,
      Outbox.CreatedAt,
      Outbox.CreatedBy
}
where Outbox.ProcessingStatus = 'OPEN'
   or Outbox.ProcessingStatus = 'IN_PROCESS'
   or Outbox.LockStatus = 'LOCKED'
