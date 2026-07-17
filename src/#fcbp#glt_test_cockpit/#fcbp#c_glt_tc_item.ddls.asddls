@EndUserText.label: 'GLT Test Cockpit Transfer Items'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity /fcbp/c_glt_tc_item
  as select from /fcbp/glt_tcitm
  association [1..1] to /fcbp/c_glt_tc_run as _Run on $projection.RunId = _Run.RunId
{
  key run_id         as RunId,
  key transfer_id    as TransferId,
      @UI.lineItem: [{ position: 10, label: 'Item' }]
  key item_no        as ItemNumber,
      @UI.lineItem: [{ position: 20, label: 'Source Line' }]
      source_line_id as SourceLineId,
      @UI.lineItem: [{ position: 30, label: 'G/L Account' }]
      gl_account     as GLAccount,
      @UI.lineItem: [{ position: 40, label: 'D/C' }]
      debit_credit   as DebitCredit,
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 50, label: 'Amount' }]
      amount         as Amount,
      currency       as Currency,
      @UI.lineItem: [{ position: 60, label: 'Company Code' }]
      company_code   as CompanyCode,
      profit_center  as ProfitCenter,
      cost_center    as CostCenter,
      segment        as Segment,
      tax_code       as TaxCode,
      assignment     as Assignment,
      item_text      as ItemText,
      source_hash    as SourceHash,
      line_hash      as LineHash,
      created_at     as CreatedAt,
      _Run
}
