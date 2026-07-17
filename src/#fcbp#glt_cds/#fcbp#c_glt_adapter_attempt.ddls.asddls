@EndUserText.label: 'GL Transfer Adapter Attempt Drilldown'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_adapter_attempt
  as select from /fcbp/i_glt_attempt
{
  key AttemptId,
      TransferId,
      OutboxId,
      JobRunId,
      AttemptNo,
      AttemptType,
      PackageId,
      OutboundDocumentId,
      PolicyContextId,
      TargetSystem,
      TargetAdapter,
      DestinationAlias,
      CorrelationId,
      IdempotencyKeyHash,
      MiddlewareMessageId,
      TargetStatusHandle,
      Outcome,
      Retryable,
      UnknownConfirmation,
      RequestHash,
      ResponseHash,
      RawRequestReference,
      RawResponseReference,
      ErrorId,
      StartedAt,
      FinishedAt,
      CreatedBy
}
