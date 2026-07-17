@EndUserText.label: 'GL Transfer Security Scope - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_transfer_sec_scope
  as select from /fcbp/i_glt_transfer
{
  key TransferId,
      CompanyCode,
      TargetId,
      TargetSystem,
      TargetAdapter,
      SourceType,
      SourceSystem,
      ExternalStatus,
      StatusCode,
      InternalState,
      CreatedBy,
      ChangedBy,
      CreatedAt,
      ChangedAt
}
