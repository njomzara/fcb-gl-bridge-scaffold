@EndUserText.label: 'GL Transfer Validation Run - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_val_run
  as select from /fcbp/glt_valrun
{
  key validation_run_id      as ValidationRunId,
      transfer_id            as TransferId,
      package_id             as PackageId,
      policy_context_id      as PolicyContextId,
      validation_profile_id  as ValidationProfileId,
      validation_profile_version as ValidationProfileVersion,
      validation_hash        as ValidationHash,
      started_at             as StartedAt,
      ended_at               as EndedAt,
      result_status          as ResultStatus,
      blocking_count         as BlockingCount,
      warning_count          as WarningCount,
      actor_type             as ActorType,
      actor_id               as ActorId,
      jobrun_id              as JobRunId,
      outbox_id              as OutboxId,
      waiver_id              as WaiverId,
      created_at             as CreatedAt,
      created_by             as CreatedBy,
      changed_at             as ChangedAt,
      changed_by             as ChangedBy
}
