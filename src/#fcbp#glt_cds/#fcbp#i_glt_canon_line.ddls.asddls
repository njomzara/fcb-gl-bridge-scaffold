@EndUserText.label: 'GL Transfer Canonical Line - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_canon_line
  as select from /fcbp/glt_lin
{
  key package_id          as PackageId,
  key outdoc_id           as OutboundDocumentId,
  key line_id             as LineId,
      line_no             as LineNumber,
      company_code        as CompanyCode,
      chart_of_accounts   as ChartOfAccounts,
      gl_account          as GLAccount,
      debit_credit        as DebitCredit,
      amount              as Amount,
      currency            as Currency,
      profit_center       as ProfitCenter,
      segment             as Segment,
      cost_center         as CostCenter,
      internal_order      as InternalOrder,
      trading_partner     as TradingPartner,
      tax_code            as TaxCode,
      tax_report_date     as TaxReportDate,
      posting_date        as PostingDate,
      document_type       as DocumentType,
      ledger_group        as LedgerGroup,
      assignment          as Assignment,
      item_text           as ItemText,
      aggr_signature_hash as AggregationSignatureHash,
      source_count        as SourceCount,
      line_hash           as LineHash,
      created_at          as CreatedAt
}
