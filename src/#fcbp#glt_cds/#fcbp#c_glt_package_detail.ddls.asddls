@EndUserText.label: 'GL Transfer Package Detail'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_package_detail
  as select from /fcbp/i_glt_package
{
  key PackageId,
      TransferId,
      PackageVersion,
      CurrentFlag,
      PackageStatus,
      PredecessorPackageId,
      SupersededByPackageId,
      SourceType,
      SourceReference,
      TargetId,
      PolicyContextId,
      AggregationProfileId,
      AggregationVersion,
      AggregationHash,
      SplitProfileId,
      SplitVersion,
      SplitHash,
      SourceHash,
      AggregationOutputHash,
      SplitOutputHash,
      PayloadHash,
      OutboundDocumentCount,
      CanonicalLineCount,
      SourceTraceCount,
      CreatedBy,
      CreatedAt
}
