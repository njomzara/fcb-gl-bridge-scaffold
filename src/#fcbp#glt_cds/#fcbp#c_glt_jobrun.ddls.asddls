@EndUserText.label: 'GL Transfer Job Run - Consumption View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_jobrun
  as select from /fcbp/i_glt_jobrun
{
  key JobRunId,
      JobName,
      JobType,
      StatusCode,
      TargetId,
      SelectedCount,
      ProcessedCount,
      SuccessCount,
      FailedCount,
      ActorId,
      MessageText,
      StartedAt,
      FinishedAt
}
