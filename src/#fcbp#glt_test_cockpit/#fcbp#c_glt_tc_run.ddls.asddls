@EndUserText.label: 'GLT Test Cockpit Run'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: {
  headerInfo: {
    typeName: 'Test Run',
    typeNamePlural: 'Test Runs',
    title: { value: 'RunId' },
    description: { value: 'StatusText' }
  },
  presentationVariant: [{
    sortOrder: [{ by: 'StartedAt', direction: #DESC }],
    visualizations: [{ type: #AS_LINEITEM }]
  }],
  selectionFields: [ ScenarioId, RunStatus, TransferId, TargetDocumentNumber, StartedAt ],
  facet: [
    { id: 'Run', type: #IDENTIFICATION_REFERENCE, label: 'Run Metadata', position: 10 },
    { id: 'SeededSource', type: #LINEITEM_REFERENCE, label: 'Seeded Source Data', position: 20, targetElement: '_SeededSource' },
    { id: 'TransferItems', type: #LINEITEM_REFERENCE, label: 'Transfer Item and Metadata', position: 30, targetElement: '_TransferItems' },
    { id: 'WorkItems', type: #LINEITEM_REFERENCE, label: 'Work Item and Metadata', position: 40, targetElement: '_WorkItems' },
    { id: 'Timeline', type: #LINEITEM_REFERENCE, label: 'Status and Audit Timeline', position: 50, targetElement: '_Timeline' },
    { id: 'CanonicalLines', type: #LINEITEM_REFERENCE, label: 'Generated Canonical GL Items', position: 60, targetElement: '_CanonicalLines' },
    { id: 'MockTargetDocument', type: #LINEITEM_REFERENCE, label: 'Mock Target GL Document', position: 70, targetElement: '_MockTargetDocumentTree' }
  ]
}
define root view entity /fcbp/c_glt_tc_run
  as select from /fcbp/glt_tcrun
  association [0..*] to /fcbp/c_glt_tc_seed    as _SeededSource          on $projection.RunId = _SeededSource.RunId
  association [0..*] to /fcbp/c_glt_tc_item    as _TransferItems         on $projection.RunId = _TransferItems.RunId
  association [0..*] to /fcbp/c_glt_tc_work    as _WorkItems             on $projection.RunId = _WorkItems.RunId
  association [0..*] to /fcbp/c_glt_tc_time    as _Timeline              on $projection.RunId = _Timeline.RunId
  association [0..*] to /fcbp/c_glt_tc_canon   as _CanonicalLines        on $projection.RunId = _CanonicalLines.RunId
  association [0..*] to /fcbp/c_glt_tc_tgtnode as _MockTargetDocumentTree on $projection.RunId = _MockTargetDocumentTree.RunId
{
      @UI.lineItem: [{ position: 10, label: 'Run ID' }]
      @UI.identification: [{ position: 10, label: 'Run ID' }]
  key run_id                 as RunId,
      @UI.lineItem: [{ position: 20, label: 'Scenario' }]
      @UI.identification: [{ position: 20, label: 'Scenario' }]
      scenario_id            as ScenarioId,
      @UI.lineItem: [{ position: 30, label: 'Command' }]
      command_id             as CommandId,
      command_text           as CommandText,
      @UI.lineItem: [{ position: 40, label: 'Status', criticality: 'StatusCriticality' }]
      @UI.identification: [{ position: 30, label: 'Status', criticality: 'StatusCriticality' }]
      run_status             as RunStatus,
      status_criticality     as StatusCriticality,
      @UI.lineItem: [{ position: 50, label: 'Status Text' }]
      @UI.identification: [{ position: 40, label: 'Status Text' }]
      status_text            as StatusText,
      @UI.lineItem: [{ position: 60, label: 'Transfer ID' }]
      @UI.identification: [{ position: 50, label: 'Transfer ID' }]
      transfer_id            as TransferId,
      package_id             as PackageId,
      outbox_id              as OutboxId,
      policy_context_id      as PolicyContextId,
      validation_run_id      as ValidationRunId,
      mapping_run_id         as MappingRunId,
      @UI.lineItem: [{ position: 70, label: 'Target Document' }]
      target_doc_no          as TargetDocumentNumber,
      source_reference       as SourceReference,
      source_doc_no          as SourceDocumentNumber,
      @UI.lineItem: [{ position: 80, label: 'Company Code' }]
      company_code           as CompanyCode,
      @UI.lineItem: [{ position: 90, label: 'Target' }]
      target_id              as TargetId,
      final_status           as FinalStatus,
      outbox_status          as OutboxStatus,
      validation_status      as ValidationStatus,
      mapping_status         as MappingStatus,
      seeded_source_count    as SeededSourceCount,
      transfer_item_count    as TransferItemCount,
      work_item_count        as WorkItemCount,
      canonical_line_count   as CanonicalLineCount,
      target_tree_node_count as TargetTreeNodeCount,
      created_by             as CreatedBy,
      @UI.lineItem: [{ position: 100, label: 'Started At' }]
      started_at             as StartedAt,
      finished_at            as FinishedAt,
      duration_ms            as DurationMs,
      message_text           as MessageText,
      _SeededSource,
      _TransferItems,
      _WorkItems,
      _Timeline,
      _CanonicalLines,
      _MockTargetDocumentTree
}
