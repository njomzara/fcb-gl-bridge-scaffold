@EndUserText.label: 'GL Transfer Aggregation Trace'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_aggr_trace
  as select from /fcbp/i_glt_source_trace
{
  key PackageId,
  key OutboundDocumentId,
  key LineId,
  key TraceId,
      LineNumber,
      TraceSequence,
      CompanyCode,
      SourceType,
      SourceReference,
      SourceDocumentNumber,
      SourceItemNumber,
      ReconciliationKey,
      SourceAmount,
      SourceCurrency,
      SourceHash,
      ContributionRatio,
      ContributionAmount,
      SourceDimensionSnapshot,
      CreatedAt
}
