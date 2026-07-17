@EndUserText.label: 'GLT Test Cockpit Canonical Lines'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity /fcbp/c_glt_tc_canon
  as select from /fcbp/glt_tccan
  association [1..1] to /fcbp/c_glt_tc_run as _Run on $projection.RunId = _Run.RunId
{
  key run_id        as RunId,
  key package_id    as PackageId,
  key outdoc_id     as OutboundDocumentId,
  key line_id       as LineId,
      @UI.lineItem: [{ position: 10, label: 'Line' }]
      line_no       as LineNumber,
      @UI.lineItem: [{ position: 20, label: 'Company Code' }]
      company_code  as CompanyCode,
      @UI.lineItem: [{ position: 30, label: 'G/L Account' }]
      gl_account    as GLAccount,
      @UI.lineItem: [{ position: 40, label: 'D/C' }]
      debit_credit  as DebitCredit,
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 50, label: 'Amount' }]
      amount        as Amount,
      currency      as Currency,
      profit_center as ProfitCenter,
      segment       as Segment,
      cost_center   as CostCenter,
      internal_order as InternalOrder,
      trading_partner as TradingPartner,
      tax_code      as TaxCode,
      posting_date  as PostingDate,
      document_type as DocumentType,
      ledger_group  as LedgerGroup,
      @UI.lineItem: [{ position: 60, label: 'Source Count' }]
      source_count  as SourceCount,
      line_hash     as LineHash,
      created_at    as CreatedAt,
      _Run
}
