@EndUserText.label: 'GL Transfer Provider Operations Metadata'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_provider_ops
  as select from /fcbp/i_glt_transfer_sec_scope
{
  key TransferId,
      CompanyCode,
      TargetId,
      TargetSystem,
      TargetAdapter,
      ExternalStatus,
      StatusCode,
      InternalState,
      CreatedAt,
      ChangedAt
}
