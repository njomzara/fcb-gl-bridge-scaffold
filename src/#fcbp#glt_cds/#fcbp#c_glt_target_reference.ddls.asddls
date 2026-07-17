@EndUserText.label: 'GL Transfer Target Reference'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_target_reference
  as select from /fcbp/i_glt_reference
{
  key ReferenceId,
      TransferId,
      TargetSystem,
      TargetAdapter,
      TargetDocumentNumber,
      TargetCompanyCode,
      TargetFiscalYear,
      TargetCorrelationId,
      ConfirmationMode,
      ConfirmedAt,
      RawReferenceHash,
      CreatedAt
}
