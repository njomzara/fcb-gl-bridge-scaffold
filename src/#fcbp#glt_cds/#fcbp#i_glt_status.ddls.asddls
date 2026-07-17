@EndUserText.label: 'GL Transfer Status - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_status
  as select from /fcbp/glt_stat
  association to parent /fcbp/i_glt_transfer as _Transfer on $projection.TransferId = _Transfer.TransferId
{
  key transfer_id          as TransferId,
  key seq_no               as SequenceNo,
      old_status_code      as OldStatusCode,
      new_status_code      as NewStatusCode,
      old_external_status  as OldExternalStatus,
      new_external_status  as NewExternalStatus,
      reason_code          as ReasonCode,
      error_id             as ErrorId,
      attempt_no           as AttemptNo,
      actor_type           as ActorType,
      actor_id             as ActorId,
      correlation_id       as CorrelationId,
      created_at           as CreatedAt,
      _Transfer
}

