@EndUserText.label: 'GLT Test Cockpit Work Items'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity /fcbp/c_glt_tc_work
  as select from /fcbp/glt_tcwrk
  association [1..1] to /fcbp/c_glt_tc_run as _Run on $projection.RunId = _Run.RunId
{
  key run_id            as RunId,
      @UI.lineItem: [{ position: 10, label: 'Outbox ID' }]
  key outbox_id         as OutboxId,
      @UI.lineItem: [{ position: 20, label: 'Transfer ID' }]
      transfer_id       as TransferId,
      @UI.lineItem: [{ position: 30, label: 'Work Type' }]
      work_type         as WorkType,
      @UI.lineItem: [{ position: 40, label: 'Status' }]
      processing_status as ProcessingStatus,
      lock_status       as LockStatus,
      priority          as Priority,
      @UI.lineItem: [{ position: 50, label: 'Target' }]
      target_id         as TargetId,
      processing_mode   as ProcessingMode,
      attempt_no        as AttemptNumber,
      lock_owner        as LockOwner,
      due_at            as DueAt,
      locked_at         as LockedAt,
      lock_until        as LockUntil,
      created_by        as CreatedBy,
      created_at        as CreatedAt,
      _Run
}
