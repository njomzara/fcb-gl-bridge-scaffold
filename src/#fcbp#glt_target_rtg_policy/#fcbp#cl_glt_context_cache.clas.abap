"! Request-local effective-context cache. Do not share across LUWs or persist globally.
CLASS /fcbp/cl_glt_context_cache DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS put_effective_context
      IMPORTING
        is_context TYPE /fcbp/if_glt_config_types=>ty_effective_context.

    METHODS get_effective_context
      IMPORTING
        is_scope          TYPE /fcbp/if_glt_config_types=>ty_routing_scope
      RETURNING
        VALUE(rs_context) TYPE /fcbp/if_glt_config_types=>ty_effective_context.

    METHODS clear.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_cache_entry,
             cache_key TYPE char255,
             context   TYPE /fcbp/if_glt_config_types=>ty_effective_context,
           END OF ty_cache_entry.
    TYPES tt_cache_entry TYPE STANDARD TABLE OF ty_cache_entry WITH EMPTY KEY.

    DATA mt_cache TYPE tt_cache_entry.

    METHODS make_key
      IMPORTING
        is_scope      TYPE /fcbp/if_glt_config_types=>ty_routing_scope
      RETURNING
        VALUE(rv_key) TYPE char255.

ENDCLASS.

CLASS /fcbp/cl_glt_context_cache IMPLEMENTATION.

  METHOD put_effective_context.
    DATA(lv_key) = make_key( is_context-routing_scope ).
    DELETE mt_cache WHERE cache_key = lv_key.
    APPEND VALUE #( cache_key = lv_key context = is_context ) TO mt_cache.
  ENDMETHOD.

  METHOD get_effective_context.
    DATA(lv_key) = make_key( is_scope ).
    READ TABLE mt_cache INTO DATA(ls_entry) WITH KEY cache_key = lv_key.
    IF sy-subrc = 0.
      rs_context = ls_entry-context.
    ENDIF.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_cache.
  ENDMETHOD.

  METHOD make_key.
    rv_key = |{ is_scope-source_system }#{ is_scope-source_type }#{ is_scope-source_reference }#{ is_scope-company_code }#{ is_scope-ledger_group }#{ is_scope-processing_mode }#{ is_scope-routing_hint }|.
  ENDMETHOD.

ENDCLASS.
