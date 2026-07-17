@EndUserText.label: 'GL Transfer Error - Interface View'
@AccessControl.authorizationCheck: #CHECK
define view entity /fcbp/i_glt_error
  as select from /fcbp/glt_err
{
  key error_id              as ErrorId,
      transfer_id           as TransferId,
      item_no               as ItemNo,
      severity              as Severity,
      category              as Category,
      retryable             as Retryable,
      unknown_confirmation  as UnknownConfirmation,
      msgid                 as MessageId,
      msgno                 as MessageNumber,
      operator_text         as OperatorText,
      technical_ref         as TechnicalReference,
      created_at            as CreatedAt,
      created_by            as CreatedBy
}

