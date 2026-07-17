@EndUserText.label: 'GL Transfer Split Policy - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_split_policy
  as select from /fcbp/cc_glsplit
{
  key split_profile_id      as SplitProfileId,
  key version               as Version,
      active_flag           as ActiveFlag,
      lifecycle_state       as LifecycleState,
      config_hash           as ConfigHash,
      max_lines_per_doc     as MaxLinesPerDocument,
      max_amount            as MaxAmount,
      split_by_company_code as SplitByCompanyCode,
      split_by_currency     as SplitByCurrency,
      split_by_posting_date as SplitByPostingDate,
      split_by_gl_doc_type  as SplitByGLDocumentType,
      split_by_ledger_group as SplitByLedgerGroup,
      balance_scope         as BalanceScope,
      changed_by            as ChangedBy,
      changed_at            as ChangedAt
}
