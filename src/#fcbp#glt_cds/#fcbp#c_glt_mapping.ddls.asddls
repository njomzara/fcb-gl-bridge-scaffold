@EndUserText.label: 'GL Transfer Mapping Summary'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_mapping
  as select from /fcbp/i_glt_map_event as Event
    left outer join /fcbp/i_glt_transfer as Transfer
      on Transfer.TransferId = Event.TransferId
    left outer join /fcbp/i_glt_package as Package
      on Package.PackageId = Event.PackageId
{
  key Event.MappingEventId,
      Event.TransferId,
      Transfer.CompanyCode,
      Event.TargetId,
      Transfer.StatusCode,
      Transfer.InternalState,
      Event.PackageId,
      Package.PackageVersion,
      Package.CurrentFlag,
      Event.OutboundDocumentId,
      Event.LineNumber,
      Event.FieldName,
      Event.DecisionType,
      Event.ResultStatus,
      Event.MappingPolicyId,
      Event.MappingPolicyVersion,
      Event.MappingHash,
      Event.RuleId,
      Event.RuleVersion,
      Event.CreatedAt,
      Event.CreatedBy
}
