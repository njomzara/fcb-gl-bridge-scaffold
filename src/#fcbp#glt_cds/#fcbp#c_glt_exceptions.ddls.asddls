@EndUserText.label: 'GL Transfer Exceptions'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_exceptions
  as select from /fcbp/i_glt_transfer as Transfer
    left outer join /fcbp/i_glt_error as Error
      on Error.TransferId = Transfer.TransferId
     and Error.ErrorId = Transfer.LastErrorId
{
  key Transfer.TransferId,
      Transfer.ExternalStatus,
      Transfer.StatusCode,
      Transfer.InternalState,
      Transfer.ConfirmationPending,
      Transfer.OperatorActionRequired,
      Transfer.SourceType,
      Transfer.SourceRefId,
      Transfer.CompanyCode,
      Transfer.TargetId,
      Transfer.TargetSystem,
      Transfer.TargetAdapter,
      Transfer.LastErrorId,
      Error.Severity as LastErrorSeverity,
      Error.Category as LastErrorCategory,
      Error.OperatorText as LastOperatorText,
      Transfer.CreatedAt,
      Transfer.ChangedAt
}
where Transfer.ExternalStatus = 'FAILED'
   or Transfer.ConfirmationPending = 'X'
   or Transfer.OperatorActionRequired = 'X'
