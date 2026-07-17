@EndUserText.label: 'GLT Test Cockpit Status and Audit Timeline'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity /fcbp/c_glt_tc_time
  as select from /fcbp/glt_tctime
  association [1..1] to /fcbp/c_glt_tc_run as _Run on $projection.RunId = _Run.RunId
{
  key run_id          as RunId,
      @UI.lineItem: [{ position: 10, label: 'Seq.' }]
  key event_seq       as EventSequence,
      @UI.lineItem: [{ position: 20, label: 'Kind' }]
      timeline_kind   as TimelineKind,
      transfer_id     as TransferId,
      @UI.lineItem: [{ position: 30, label: 'Event' }]
      event_type      as EventType,
      event_subtype   as EventSubtype,
      old_status_code as OldStatusCode,
      @UI.lineItem: [{ position: 40, label: 'New Status', criticality: 'Criticality' }]
      new_status_code as NewStatusCode,
      reason_code     as ReasonCode,
      actor_type      as ActorType,
      @UI.lineItem: [{ position: 50, label: 'Actor' }]
      actor_id        as ActorId,
      correlation_id  as CorrelationId,
      evidence_ref    as EvidenceReference,
      criticality     as Criticality,
      @UI.lineItem: [{ position: 60, label: 'Message' }]
      message_text    as MessageText,
      @UI.lineItem: [{ position: 70, label: 'Created At' }]
      created_at      as CreatedAt,
      _Run
}
