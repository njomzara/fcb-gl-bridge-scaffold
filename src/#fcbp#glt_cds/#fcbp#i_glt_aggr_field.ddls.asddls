@EndUserText.label: 'GL Transfer Aggregation Field - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_aggr_field
  as select from /fcbp/cc_glaggrf
{
  key aggregation_profile_id as AggregationProfileId,
  key version                as Version,
  key field_sequence         as FieldSequence,
      field_name             as FieldName,
      required_flag          as RequiredFlag,
      normalize_rule         as NormalizeRule,
      include_in_signature   as IncludeInSignature,
      changed_by             as ChangedBy,
      changed_at             as ChangedAt
}
