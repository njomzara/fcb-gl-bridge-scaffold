@EndUserText.label: 'GL Transfer Mapping Finding'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_mapping_finding
  as select from /fcbp/i_glt_map_event as Event
    left outer join /fcbp/i_glt_transfer as Transfer
      on Transfer.TransferId = Event.TransferId
{
  key Event.MappingEventId,
      Event.TransferId,
      Transfer.CompanyCode,
      Event.TargetId,
      Event.PackageId,
      Event.OutboundDocumentId,
      Event.LineNumber,
      Event.FieldName,
      Event.SourceValueHash,
      Event.SourceValueSafe,
      Event.TargetValueHash,
      Event.TargetValueSafe,
      Event.MappingPolicyId,
      Event.MappingPolicyVersion,
      Event.RuleId,
      Event.RuleVersion,
      Event.DecisionType,
      Event.ResultStatus,
      Event.MessageId,
      Event.OperatorText,
      Event.CreatedAt
}
where Event.ResultStatus = 'FAILED'
   or Event.DecisionType = 'REJECTED'
