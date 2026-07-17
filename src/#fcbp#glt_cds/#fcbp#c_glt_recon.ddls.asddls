@EndUserText.label: 'GL Transfer Reconciliation'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_recon
  as select from /fcbp/i_glt_transfer as Transfer
  left outer join /fcbp/i_glt_reference as Reference
    on Transfer.TransferId = Reference.TransferId
{
  key Transfer.TransferId,
      Transfer.ExternalStatus,
      Transfer.StatusCode,
      Transfer.SourceSystem,
      Transfer.SourceType,
      Transfer.SourceRefId,
      Transfer.CompanyCode,
      Transfer.PostingDate,
      Transfer.Currency,
      Transfer.TotalDebitAmount,
      Transfer.TotalCreditAmount,
      Transfer.CorrelationId,
      Transfer.IdempotencyKey,
      Reference.TargetSystem,
      Reference.TargetAdapter,
      Reference.TargetDocumentNumber,
      Reference.TargetFiscalYear,
      Reference.TargetCorrelationId,
      Reference.ConfirmedAt,
      Transfer.CreatedAt,
      Transfer.ChangedAt
}

