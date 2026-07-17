@EndUserText.label: 'GLT Test Cockpit Mock Target Hierarchy'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define hierarchy /fcbp/h_glt_tc_tgtnode
  as parent child hierarchy(
    source /fcbp/i_glt_tc_tgtnode
    child to parent association _Parent
    start where
      ParentNodeId is initial
    siblings order by
      SiblingOrder ascending
  )
{
  key RunId,
  key NodeId,
      ParentNodeId,
      SiblingOrder
}
