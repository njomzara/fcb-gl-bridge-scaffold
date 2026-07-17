@EndUserText.label: 'GL Transfer Validation Finding - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_val_find
  as select from /fcbp/glt_valfnd
{
  key validation_run_id as ValidationRunId,
  key finding_seq       as FindingSequence,
      transfer_id       as TransferId,
      package_id        as PackageId,
      outdoc_id         as OutboundDocumentId,
      line_no           as LineNumber,
      field_name        as FieldName,
      rule_id           as RuleId,
      rule_category     as RuleCategory,
      severity          as Severity,
      blocking_flag     as BlockingFlag,
      message_code      as MessageCode,
      operator_text     as OperatorText,
      technical_detail_ref as TechnicalDetailReference,
      remediation_owner as RemediationOwner,
      target_id         as TargetId,
      policy_version    as PolicyVersion,
      message_id        as MessageId,
      created_at        as CreatedAt,
      created_by        as CreatedBy
}
