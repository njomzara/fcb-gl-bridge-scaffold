@EndUserText.label: 'GL Transfer Unknown Confirmation Queue'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_unknown_confirm
  as select from /fcbp/i_glt_attempt
{
  key AttemptId,
      TransferId,
      OutboxId,
      JobRunId,
      AttemptNo,
      AttemptType,
      TargetSystem,
      TargetAdapter,
      DestinationAlias,
      CorrelationId,
      MiddlewareMessageId,
      TargetStatusHandle,
      Outcome,
      UnknownConfirmation,
      RequestHash,
      ResponseHash,
      RawResponseReference,
      StartedAt,
      FinishedAt,
      CreatedBy
}
where UnknownConfirmation = 'X'
