@EndUserText.label: 'GL Transfer Source Read Diagnostics'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_source_read
  as select from /fcbp/i_glt_source_read_run as SourceRead
    left outer join /fcbp/i_glt_transfer as Transfer
      on Transfer.TransferId = SourceRead.TransferId
{
  key SourceRead.SourceReadId,
      SourceRead.TransferId,
      SourceRead.PackageId,
      SourceRead.SourceType,
      SourceRead.SourceReference,
      SourceRead.RoutingBucket,
      SourceRead.TargetId,
      SourceRead.PolicyContextId,
      coalesce( SourceRead.CompanyCode, Transfer.CompanyCode ) as CompanyCode,
      Transfer.StatusCode,
      Transfer.InternalState,
      SourceRead.ReadMode,
      SourceRead.ResultStatus,
      SourceRead.ReadConsistency,
      SourceRead.RequestedBy,
      SourceRead.RequestedAt,
      SourceRead.CompletedAt,
      SourceRead.SourceLineCount,
      SourceRead.SourceHash,
      SourceRead.SnapshotId,
      SourceRead.ErrorCode,
      SourceRead.Retryable,
      SourceRead.OperatorText,
      SourceRead.CreatedAt
}
