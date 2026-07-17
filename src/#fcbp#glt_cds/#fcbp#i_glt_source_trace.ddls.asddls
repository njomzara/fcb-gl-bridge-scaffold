@EndUserText.label: 'GL Transfer Source Trace - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_source_trace
  as select from /fcbp/glt_src
{
  key package_id            as PackageId,
  key outdoc_id             as OutboundDocumentId,
  key line_id               as LineId,
  key trace_id              as TraceId,
      line_no               as LineNumber,
      trace_sequence        as TraceSequence,
      source_type           as SourceType,
      source_reference      as SourceReference,
      source_doc_no         as SourceDocumentNumber,
      source_item_no        as SourceItemNumber,
      reconciliation_key    as ReconciliationKey,
      company_code          as CompanyCode,
      source_amount         as SourceAmount,
      source_currency       as SourceCurrency,
      source_hash           as SourceHash,
      contribution_ratio    as ContributionRatio,
      contribution_amount   as ContributionAmount,
      source_dimension_snapshot as SourceDimensionSnapshot,
      created_at            as CreatedAt
}
