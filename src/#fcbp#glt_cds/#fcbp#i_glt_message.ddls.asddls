@EndUserText.label: 'GL Transfer Message - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_message
  as select from /fcbp/glt_msg
  association to parent /fcbp/i_glt_transfer as _Transfer on $projection.TransferId = _Transfer.TransferId
{
  key message_id     as MessageId,
      transfer_id    as TransferId,
      error_id       as ErrorId,
      severity       as Severity,
      category       as Category,
      msgid          as MessageClass,
      msgno          as MessageNumber,
      msgv1          as MessageVariable1,
      msgv2          as MessageVariable2,
      msgv3          as MessageVariable3,
      msgv4          as MessageVariable4,
      operator_text  as OperatorText,
      context_ref    as ContextReference,
      created_at     as CreatedAt,
      created_by     as CreatedBy,
      _Transfer
}
