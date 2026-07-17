@EndUserText.label: 'GL Transfer Validation Result'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_validation
  as select from /fcbp/i_glt_val_run as Run
    left outer join /fcbp/i_glt_transfer as Transfer
      on Transfer.TransferId = Run.TransferId
    left outer join /fcbp/i_glt_package as Package
      on Package.PackageId = Run.PackageId
{
  key Run.ValidationRunId,
      Run.TransferId,
      Transfer.CompanyCode,
      Transfer.TargetId,
      Transfer.StatusCode,
      Transfer.InternalState,
      Run.PackageId,
      Package.PackageVersion,
      Package.CurrentFlag,
      Package.PackageStatus,
      Run.PolicyContextId,
      Run.ValidationProfileId,
      Run.ValidationProfileVersion,
      Run.ValidationHash,
      Run.ResultStatus,
      Run.BlockingCount,
      Run.WarningCount,
      Run.ActorType,
      Run.ActorId,
      Run.JobRunId,
      Run.OutboxId,
      Run.WaiverId,
      Run.StartedAt,
      Run.EndedAt,
      Run.ChangedAt
}
