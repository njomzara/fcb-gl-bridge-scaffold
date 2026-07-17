@EndUserText.label: 'GLT Test Cockpit Mock Target Tree'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@OData.hierarchy.recursiveHierarchy: [{ entity.name: '/FCBP/H_GLT_TC_TGTNODE' }]
define view entity /fcbp/c_glt_tc_tgtnode
  as select from /fcbp/i_glt_tc_tgtnode
  association [1..1] to /fcbp/c_glt_tc_run as _Run on $projection.RunId = _Run.RunId
  association of many to one /fcbp/c_glt_tc_tgtnode as _Parent
    on  $projection.RunId        = _Parent.RunId
    and $projection.ParentNodeId = _Parent.NodeId
{
  key RunId,
  key NodeId,
      ParentNodeId,
      SiblingOrder,
      @UI.lineItem: [{ position: 10, label: 'Node Type' }]
      NodeType,
      DrillState,
      @UI.lineItem: [{ position: 20, label: 'Text' }]
      NodeText,
      @UI.lineItem: [{ position: 30, label: 'Target Document' }]
      TargetDocumentNumber,
      @UI.lineItem: [{ position: 40, label: 'Target Line' }]
      TargetLineNumber,
      TransferId,
      PackageId,
      OutboundDocumentId,
      LineId,
      TraceId,
      @UI.lineItem: [{ position: 50, label: 'Source Reference' }]
      SourceReference,
      SourceDocumentNumber,
      SourceItemNumber,
      @UI.lineItem: [{ position: 60, label: 'G/L Account' }]
      GLAccount,
      DebitCredit,
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 70, label: 'Amount' }]
      Amount,
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 80, label: 'Contribution' }]
      ContributionAmount,
      ContributionRatio,
      Currency,
      @UI.lineItem: [{ position: 90, label: 'Target Status' }]
      TargetStatus,
      CreatedAt,
      _Run,
      _Parent
}
