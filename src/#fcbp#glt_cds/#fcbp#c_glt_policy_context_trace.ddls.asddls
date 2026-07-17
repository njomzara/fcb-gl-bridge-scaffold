@EndUserText.label: 'GL Transfer Policy Context Trace'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/c_glt_policy_context_trace
  as select from /fcbp/i_glt_policy_context as Context
    left outer join /fcbp/i_glt_target_profile as Target
      on Target.TargetId = Context.TargetId
{
  key Context.PolicyContextId,
      Context.TransferId,
      Context.PackageId,
      Context.OutboxId,
      Context.TargetId,
      Target.TargetType,
      Target.AdapterType,
      Target.TransferMode,
      Target.ConfirmationMode,
      Context.TargetProfileVersion,
      Context.TargetProfileHash,
      Context.AggregationProfileId,
      Context.AggregationVersion,
      Context.AggregationHash,
      Context.SplitProfileId,
      Context.SplitVersion,
      Context.SplitHash,
      Context.ValidationProfileId,
      Context.ValidationVersion,
      Context.ValidationHash,
      Context.MappingPolicyId,
      Context.MappingVersion,
      Context.MappingHash,
      Context.RetryPolicyId,
      Context.RetryVersion,
      Context.RetryHash,
      Context.ThrottlePolicyId,
      Context.ThrottleVersion,
      Context.ThrottleHash,
      Context.ConfirmationPolicyId,
      Context.ConfirmationVersion,
      Context.ConfirmationHash,
      Context.ResolvedAt,
      Context.ResolvedBy,
      Context.ValidityFrom,
      Context.ValidityTo
}
