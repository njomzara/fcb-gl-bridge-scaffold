@EndUserText.label: 'GL Transfer Mapping Event - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_map_event
  as select from /fcbp/glt_mapev
{
  key mapping_event_id      as MappingEventId,
      transfer_id           as TransferId,
      package_id            as PackageId,
      outdoc_id             as OutboundDocumentId,
      line_no               as LineNumber,
      field_name            as FieldName,
      source_value_hash     as SourceValueHash,
      source_value_safe     as SourceValueSafe,
      target_value_hash     as TargetValueHash,
      target_value_safe     as TargetValueSafe,
      target_id             as TargetId,
      mapping_policy_id     as MappingPolicyId,
      mapping_policy_version as MappingPolicyVersion,
      mapping_hash          as MappingHash,
      rule_id               as RuleId,
      rule_version          as RuleVersion,
      decision_type         as DecisionType,
      result_status         as ResultStatus,
      message_id            as MessageId,
      operator_text         as OperatorText,
      created_at            as CreatedAt,
      created_by            as CreatedBy
}
