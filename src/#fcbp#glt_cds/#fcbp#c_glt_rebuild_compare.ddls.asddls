@EndUserText.label: 'GL Transfer Rebuild Comparison'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_rebuild_compare
  as select from /fcbp/i_glt_package
{
  key PackageId,
      TransferId,
      PackageVersion,
      CurrentFlag,
      PackageStatus,
      PredecessorPackageId,
      SupersededByPackageId,
      TargetId,
      PolicyContextId,
      SourceHash,
      AggregationOutputHash,
      SplitOutputHash,
      PayloadHash,
      OutboundDocumentCount,
      CanonicalLineCount,
      SourceTraceCount,
      CreatedAt
}
