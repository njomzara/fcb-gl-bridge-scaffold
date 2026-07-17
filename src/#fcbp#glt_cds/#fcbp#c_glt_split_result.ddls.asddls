@EndUserText.label: 'GL Transfer Split Result'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_split_result
  as select from /fcbp/i_glt_outdoc
{
  key PackageId,
  key OutboundDocumentId,
      DocumentSequence,
      CompanyCode,
      PostingDate,
      DocumentDate,
      GLDocumentType,
      Currency,
      LedgerGroup,
      Reference,
      HeaderText,
      BalanceStatus,
      DebitAmount,
      CreditAmount,
      DifferenceAmount,
      LineCount,
      PayloadHash,
      CreatedAt
}
