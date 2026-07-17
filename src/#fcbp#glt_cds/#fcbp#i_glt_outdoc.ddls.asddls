@EndUserText.label: 'GL Transfer Outbound Document - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_outdoc
  as select from /fcbp/glt_doc
{
  key package_id        as PackageId,
  key outdoc_id         as OutboundDocumentId,
      document_sequence as DocumentSequence,
      company_code      as CompanyCode,
      posting_date      as PostingDate,
      document_date     as DocumentDate,
      gl_doc_type       as GLDocumentType,
      currency          as Currency,
      ledger_group      as LedgerGroup,
      reference         as Reference,
      header_text       as HeaderText,
      balance_status    as BalanceStatus,
      debit_amount      as DebitAmount,
      credit_amount     as CreditAmount,
      difference_amount as DifferenceAmount,
      line_count        as LineCount,
      payload_hash      as PayloadHash,
      created_at        as CreatedAt
}
