@EndUserText.label: 'GL Transfer Job Run - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_jobrun
  as select from /fcbp/glt_jobrun
{
  key jobrun_id       as JobRunId,
      job_name        as JobName,
      job_type        as JobType,
      status_code     as StatusCode,
      target_id       as TargetId,
      selected_count  as SelectedCount,
      processed_count as ProcessedCount,
      success_count   as SuccessCount,
      failed_count    as FailedCount,
      actor_id        as ActorId,
      message_text    as MessageText,
      started_at      as StartedAt,
      finished_at     as FinishedAt
}
