@EndUserText.label: 'GL Transfer Validation Finding Drilldown'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_validation_find
  as select from /fcbp/i_glt_val_find as Finding
    inner join /fcbp/i_glt_val_run as Run
      on Run.ValidationRunId = Finding.ValidationRunId
    left outer join /fcbp/i_glt_transfer as Transfer
      on Transfer.TransferId = Finding.TransferId
{
  key Finding.ValidationRunId,
  key Finding.FindingSequence,
      Finding.TransferId,
      Transfer.CompanyCode,
      Transfer.TargetId,
      Finding.PackageId,
      Finding.OutboundDocumentId,
      Finding.LineNumber,
      Finding.FieldName,
      Finding.RuleId,
      Finding.RuleCategory,
      Finding.Severity,
      Finding.BlockingFlag,
      Finding.MessageCode,
      Finding.OperatorText,
      Finding.TechnicalDetailReference,
      Finding.RemediationOwner,
      Finding.PolicyVersion,
      Finding.MessageId,
      Run.ResultStatus,
      Finding.CreatedAt
}
