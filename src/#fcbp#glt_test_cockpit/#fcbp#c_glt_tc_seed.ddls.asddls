@EndUserText.label: 'GLT Test Cockpit Seeded Source'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity /fcbp/c_glt_tc_seed
  as select from /fcbp/glt_tcsd
  association [1..1] to /fcbp/c_glt_tc_run as _Run on $projection.RunId = _Run.RunId
{
      @UI.lineItem: [{ position: 10, label: 'Sequence' }]
  key run_id             as RunId,
      @UI.lineItem: [{ position: 20, label: 'Source Seq.' }]
  key source_seq         as SourceSequence,
      @UI.lineItem: [{ position: 30, label: 'Source Type' }]
      source_type        as SourceType,
      @UI.lineItem: [{ position: 40, label: 'Source Reference' }]
      source_reference   as SourceReference,
      @UI.lineItem: [{ position: 50, label: 'Source Document' }]
      source_doc_no      as SourceDocumentNumber,
      @UI.lineItem: [{ position: 60, label: 'Source Item' }]
      source_item_no     as SourceItemNumber,
      reconciliation_key as ReconciliationKey,
      @UI.lineItem: [{ position: 70, label: 'Company Code' }]
      company_code       as CompanyCode,
      @UI.lineItem: [{ position: 80, label: 'G/L Account' }]
      gl_account         as GLAccount,
      @UI.lineItem: [{ position: 90, label: 'D/C' }]
      debit_credit       as DebitCredit,
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 100, label: 'Amount' }]
      amount             as Amount,
      currency           as Currency,
      profit_center      as ProfitCenter,
      segment            as Segment,
      cost_center        as CostCenter,
      assignment         as Assignment,
      item_text          as ItemText,
      source_hash        as SourceHash,
      line_hash          as LineHash,
      captured_at        as CapturedAt,
      _Run
}
