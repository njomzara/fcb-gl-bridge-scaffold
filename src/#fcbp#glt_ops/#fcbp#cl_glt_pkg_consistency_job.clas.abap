"! Application job shell for package evidence consistency checks.
CLASS /fcbp/cl_glt_pkg_consistency_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repo        TYPE REF TO /fcbp/if_glt_package_repo OPTIONAL
        io_consistency TYPE REF TO /fcbp/cl_glt_package_consistency OPTIONAL.

    METHODS execute
      IMPORTING
        iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO /fcbp/if_glt_package_repo.
    DATA mo_consistency TYPE REF TO /fcbp/cl_glt_package_consistency.

ENDCLASS.

CLASS /fcbp/cl_glt_pkg_consistency_job IMPLEMENTATION.

  METHOD constructor.
    mo_repo = io_repo.
    IF io_consistency IS BOUND.
      mo_consistency = io_consistency.
    ELSE.
      mo_consistency = NEW /fcbp/cl_glt_package_consistency( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    IF mo_repo IS NOT BOUND OR iv_package_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Package consistency job requires a package repository and package ID in the scaffold.'.
    ENDIF.

    DATA(ls_graph) = mo_repo->read_package( iv_package_id ).
    DATA(lt_message) = mo_consistency->check_graph( ls_graph ).
    DATA(lt_repo_message) = mo_repo->check_consistency( iv_package_id ).
    APPEND LINES OF lt_repo_message TO lt_message.
    LOOP AT lt_message TRANSPORTING NO FIELDS WHERE blocking = abap_true.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-validation
          operator_text  = 'Package evidence consistency check found blocking issues.'.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
