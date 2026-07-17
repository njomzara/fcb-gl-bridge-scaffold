@EndUserText.label: 'GL Source Registration - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_registration
  as select from /fcbp/glt_reg
{
  key registration_key       as RegistrationKey,
      source_type            as SourceType,
      source_reference       as SourceReference,
      source_doc_no          as SourceDocumentNumber,
      reconciliation_key     as ReconciliationKey,
      event_type             as EventType,
      event_id               as EventId,
      routing_bucket         as RoutingBucket,
      target_id              as TargetId,
      processing_mode        as ProcessingMode,
      transfer_id            as TransferId,
      registration_status    as RegistrationStatus,
      reserved_by            as ReservedBy,
      reserved_at            as ReservedAt,
      completed_at           as CompletedAt,
      expires_at             as ExpiresAt,
      duplicate_of_transfer_id as DuplicateOfTransferId,
      last_error_code        as LastErrorCode,
      created_at             as CreatedAt,
      changed_at             as ChangedAt
}

