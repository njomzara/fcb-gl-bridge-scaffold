@EndUserText.label: 'GL Transfer Package - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_package
  as select from /fcbp/glt_pkg
{
  key package_id              as PackageId,
      transfer_id             as TransferId,
      package_version         as PackageVersion,
      current_flag            as CurrentFlag,
      package_status          as PackageStatus,
      predecessor_package_id  as PredecessorPackageId,
      superseded_by_package_id as SupersededByPackageId,
      source_type             as SourceType,
      source_reference        as SourceReference,
      target_id               as TargetId,
      policy_context_id       as PolicyContextId,
      aggregation_profile_id  as AggregationProfileId,
      aggregation_version     as AggregationVersion,
      aggregation_hash        as AggregationHash,
      split_profile_id        as SplitProfileId,
      split_version           as SplitVersion,
      split_hash              as SplitHash,
      source_hash             as SourceHash,
      aggregation_output_hash as AggregationOutputHash,
      split_output_hash       as SplitOutputHash,
      payload_hash            as PayloadHash,
      outdoc_count            as OutboundDocumentCount,
      canonical_line_count    as CanonicalLineCount,
      trace_count             as SourceTraceCount,
      created_by              as CreatedBy,
      created_at              as CreatedAt
}
