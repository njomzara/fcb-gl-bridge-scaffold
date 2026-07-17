@EndUserText.label: 'GL Transfer Item - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_item
  as select from /fcbp/glt_item
  association to parent /fcbp/i_glt_transfer as _Transfer on $projection.TransferId = _Transfer.TransferId
{
  key transfer_id    as TransferId,
  key item_no        as ItemNo,
      source_line_id as SourceLineId,
      gl_account     as GlAccount,
      debit_credit   as DebitCredit,
      amount         as Amount,
      currency       as Currency,
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
      _Transfer
}

