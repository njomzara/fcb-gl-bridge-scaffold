@EndUserText.label: 'GL Transfer Validation Rule - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_validation_rule
  as select from /fcbp/cc_glval
{
  key validation_profile_id as ValidationProfileId,
  key rule_id               as RuleId,
  key version               as Version,
      active_flag           as ActiveFlag,
      config_hash           as ConfigHash,
      rule_category         as RuleCategory,
      severity              as Severity,
      blocking_flag         as BlockingFlag,
      target_scope          as TargetScope,
      field_scope           as FieldScope,
      policy_expression_ref as PolicyExpressionReference,
      changed_by            as ChangedBy,
      changed_at            as ChangedAt
}
