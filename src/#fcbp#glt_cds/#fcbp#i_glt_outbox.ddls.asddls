@EndUserText.label: 'GL Transfer Outbox - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_outbox
  as select from /fcbp/glt_outbox
{
  key outbox_id         as OutboxId,
      transfer_id       as TransferId,
      work_type         as WorkType,
      due_at            as DueAt,
      priority          as Priority,
      target_id         as TargetId,
      processing_mode   as ProcessingMode,
      processing_status as ProcessingStatus,
      lock_status       as LockStatus,
      lock_owner        as LockOwner,
      locked_at         as LockedAt,
      lock_until        as LockUntil,
      attempt_no        as AttemptNo,
      created_at        as CreatedAt,
      created_by        as CreatedBy
}

