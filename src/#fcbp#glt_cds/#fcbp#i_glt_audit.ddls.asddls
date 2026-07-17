@EndUserText.label: 'GL Transfer Audit - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_audit
  as select from /fcbp/glt_aud
  association to parent /fcbp/i_glt_transfer as _Transfer on $projection.TransferId = _Transfer.TransferId
{
  key audit_id        as AuditId,
      transfer_id     as TransferId,
      event_type      as EventType,
      event_subtype   as EventSubtype,
      event_category  as EventCategory,
      source_type     as SourceType,
      source_reference as SourceReference,
      company_code    as CompanyCode,
      target_id       as TargetId,
      routing_bucket  as RoutingBucket,
      package_id      as PackageId,
      outbox_id       as OutboxId,
      attempt_id      as AttemptId,
      ref_id          as ReferenceId,
      jobrun_id       as JobRunId,
      config_object_type as ConfigObjectType,
      config_object_key as ConfigObjectKey,
      config_version  as ConfigVersion,
      support_ticket_id as SupportTicketId,
      support_session_id as SupportSessionId,
      correlation_id  as CorrelationId,
      request_id      as RequestId,
      decision_outcome as DecisionOutcome,
      actor_type      as ActorType,
      actor_id        as ActorId,
      reason_code     as ReasonCode,
      message_id      as MessageId,
      old_value_hash  as OldValueHash,
      new_value_hash  as NewValueHash,
      evidence_ref    as EvidenceReference,
      retention_class as RetentionClass,
      legal_hold      as LegalHold,
      criticality     as Criticality,
      redaction_profile as RedactionProfile,
      created_at      as CreatedAt,
      _Transfer
}
