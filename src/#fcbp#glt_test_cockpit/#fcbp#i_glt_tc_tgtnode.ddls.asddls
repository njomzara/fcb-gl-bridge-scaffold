@EndUserText.label: 'GLT Test Cockpit Mock Target Node'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity /fcbp/i_glt_tc_tgtnode
  as select from /fcbp/glt_tctgt
  association of many to one /fcbp/i_glt_tc_tgtnode as _Parent
    on  $projection.RunId        = _Parent.RunId
    and $projection.ParentNodeId = _Parent.NodeId
{
  key run_id              as RunId,
  key node_id             as NodeId,
      parent_node_id      as ParentNodeId,
      sibling_order       as SiblingOrder,
      node_type           as NodeType,
      drill_state         as DrillState,
      target_doc_no       as TargetDocumentNumber,
      target_line_no      as TargetLineNumber,
      transfer_id         as TransferId,
      package_id          as PackageId,
      outdoc_id           as OutboundDocumentId,
      line_id             as LineId,
      trace_id            as TraceId,
      source_reference    as SourceReference,
      source_doc_no       as SourceDocumentNumber,
      source_item_no      as SourceItemNumber,
      gl_account          as GLAccount,
      debit_credit        as DebitCredit,
      amount              as Amount,
      contribution_amount as ContributionAmount,
      contribution_ratio  as ContributionRatio,
      currency            as Currency,
      target_status       as TargetStatus,
      node_text           as NodeText,
      created_at          as CreatedAt,
      _Parent
}
