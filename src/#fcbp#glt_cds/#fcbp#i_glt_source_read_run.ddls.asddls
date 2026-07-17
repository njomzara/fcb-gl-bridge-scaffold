@EndUserText.label: 'GL Transfer Source Read Run - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_source_read_run
  as select from /fcbp/glt_srcrun
{
  key source_read_id     as SourceReadId,
      transfer_id        as TransferId,
      package_id         as PackageId,
      source_type        as SourceType,
      source_reference   as SourceReference,
      routing_bucket     as RoutingBucket,
      target_id          as TargetId,
      policy_context_id  as PolicyContextId,
      company_code       as CompanyCode,
      read_mode          as ReadMode,
      result_status      as ResultStatus,
      read_consistency   as ReadConsistency,
      requested_by       as RequestedBy,
      requested_at       as RequestedAt,
      completed_at       as CompletedAt,
      source_line_count  as SourceLineCount,
      source_hash        as SourceHash,
      snapshot_id        as SnapshotId,
      error_code         as ErrorCode,
      retryable          as Retryable,
      operator_text      as OperatorText,
      technical_reference as TechnicalReference,
      created_at         as CreatedAt
}
