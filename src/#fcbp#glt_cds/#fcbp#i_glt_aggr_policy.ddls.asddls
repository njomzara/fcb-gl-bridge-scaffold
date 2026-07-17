@EndUserText.label: 'GL Transfer Aggregation Policy - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_aggr_policy
  as select from /fcbp/cc_glaggr
{
  key aggregation_profile_id as AggregationProfileId,
  key version                as Version,
      active_flag            as ActiveFlag,
      lifecycle_state        as LifecycleState,
      config_hash            as ConfigHash,
      grouping_mode          as GroupingMode,
      required_dimension_policy as RequiredDimensionPolicy,
      netting_allowed        as NettingAllowed,
      source_hash_version    as SourceHashVersion,
      changed_by             as ChangedBy,
      changed_at             as ChangedAt
}
