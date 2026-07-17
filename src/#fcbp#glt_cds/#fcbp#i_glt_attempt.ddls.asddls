@EndUserText.label: 'GL Transfer Attempt - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_attempt
  as select from /fcbp/glt_att
  association to parent /fcbp/i_glt_transfer as _Transfer on $projection.TransferId = _Transfer.TransferId
{
  key attempt_id           as AttemptId,
      transfer_id          as TransferId,
      outbox_id            as OutboxId,
      jobrun_id            as JobRunId,
      attempt_no           as AttemptNo,
      attempt_type         as AttemptType,
      package_id           as PackageId,
      outdoc_id            as OutboundDocumentId,
      policy_context_id    as PolicyContextId,
      target_system        as TargetSystem,
      target_adapter       as TargetAdapter,
      destination_alias    as DestinationAlias,
      correlation_id       as CorrelationId,
      idempotency_key_hash as IdempotencyKeyHash,
      middleware_message_id as MiddlewareMessageId,
      target_status_handle as TargetStatusHandle,
      outcome              as Outcome,
      retryable            as Retryable,
      unknown_confirmation as UnknownConfirmation,
      request_hash         as RequestHash,
      response_hash        as ResponseHash,
      raw_request_ref      as RawRequestReference,
      raw_response_ref     as RawResponseReference,
      error_id             as ErrorId,
      started_at           as StartedAt,
      finished_at          as FinishedAt,
      created_by           as CreatedBy,
      _Transfer
}
