@EndUserText.label: 'GL Transfer Monitor'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_monitor
  as select from /fcbp/i_glt_transfer
{
  key TransferId,
      ExternalStatus,
      StatusCode,
      InternalState,
      TransferType,
      SourceSystem,
      SourceType,
      SourceRefId,
      SourceRegistrationKey,
      RoutingBucket,
      TargetId,
      ProcessingMode,
      CompanyCode,
      PostingDate,
      Currency,
      TotalDebitAmount,
      TotalCreditAmount,
      TargetSystem,
      TargetAdapter,
      CorrelationId,
      IdempotencyKey,
      LastErrorId,
      ConfirmationPending,
      OperatorActionRequired,
      CreatedAt,
      ChangedAt
}
