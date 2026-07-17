@EndUserText.label: 'GL Transfer Target Reference - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_reference
  as select from /fcbp/glt_ref
{
  key ref_id              as ReferenceId,
      transfer_id         as TransferId,
      target_system       as TargetSystem,
      target_adapter      as TargetAdapter,
      target_doc_no       as TargetDocumentNumber,
      target_company_code as TargetCompanyCode,
      target_fiscal_year  as TargetFiscalYear,
      target_corr_id      as TargetCorrelationId,
      confirmation_mode   as ConfirmationMode,
      confirmed_at        as ConfirmedAt,
      raw_ref_hash        as RawReferenceHash,
      created_at          as CreatedAt
}

