@EndUserText.label: 'GL Transfer Mapping Rule - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_mapping_rule
  as select from /fcbp/cc_glmap
{
  key mapping_policy_id as MappingPolicyId,
  key mapping_rule_id   as MappingRuleId,
  key version           as Version,
      active_flag       as ActiveFlag,
      config_hash       as ConfigHash,
      field_name        as FieldName,
      source_value      as SourceValue,
      source_pattern    as SourcePattern,
      target_value      as TargetValue,
      decision_type     as DecisionType,
      derivation_ref    as DerivationReference,
      truncation_rule   as TruncationRule,
      pass_through_allowed as PassThroughAllowed,
      priority          as Priority,
      changed_by        as ChangedBy,
      changed_at        as ChangedAt
}
