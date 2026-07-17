@EndUserText.label: 'GL Transfer Timeline'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_timeline
  as select from /fcbp/i_glt_status as Status
    left outer join /fcbp/i_glt_error as Error
      on Error.ErrorId = Status.ErrorId
     and Error.TransferId = Status.TransferId
{
  key Status.TransferId,
  key Status.SequenceNo,
      Status.CreatedAt,
      Status.OldStatusCode,
      Status.NewStatusCode,
      Status.OldExternalStatus,
      Status.NewExternalStatus,
      Status.ReasonCode,
      Status.AttemptNo,
      Status.ActorType,
      Status.ActorId,
      Status.CorrelationId,
      Status.ErrorId,
      Error.Severity as ErrorSeverity,
      Error.Category as ErrorCategory,
      Error.OperatorText as OperatorText
}
