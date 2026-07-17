"! Request-local authorization decision cache. Never share across users or LUWs.
CLASS /fcbp/cl_glt_authz_cache DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS get
      IMPORTING
        iv_action      TYPE char30
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        iv_actor_id    TYPE char40 OPTIONAL
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_sec_types=>ty_auth_decision.

    METHODS put
      IMPORTING
        is_decision TYPE /fcbp/if_glt_sec_types=>ty_auth_decision.

    METHODS clear.

  PRIVATE SECTION.
    DATA mt_decision TYPE /fcbp/if_glt_sec_types=>tt_auth_decision.

ENDCLASS.

CLASS /fcbp/cl_glt_authz_cache IMPLEMENTATION.

  METHOD get.
    READ TABLE mt_decision INTO rs_decision
      WITH KEY action = iv_action
               transfer_id = iv_transfer_id
               actor_id = iv_actor_id.
  ENDMETHOD.

  METHOD put.
    DELETE mt_decision WHERE action = is_decision-action
                         AND transfer_id = is_decision-transfer_id
                         AND actor_id = is_decision-actor_id.
    APPEND is_decision TO mt_decision.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_decision.
  ENDMETHOD.

ENDCLASS.
