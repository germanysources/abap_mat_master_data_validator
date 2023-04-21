CLASS zcl_im_material_checks DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_ex_badi_material_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      _matnr_range TYPE RANGE OF matnr.

    METHODS validate_plant_data
      IMPORTING
        wmara TYPE mara
        wmarc TYPE marc
      EXCEPTIONS
        invalid.

    METHODS validate_sales_data
      IMPORTING
        wmara TYPE mara
        wmvke TYPE mvke
      EXCEPTIONS
        invalid.

    METHODS validate_valuation_data
      IMPORTING
        wmara TYPE mara
        wmbew TYPE mbew
      EXCEPTIONS
        invalid.

ENDCLASS.



CLASS ZCL_IM_MATERIAL_CHECKS IMPLEMENTATION.


  METHOD if_ex_badi_material_check~check_change_mara_meins.
  ENDMETHOD.


  METHOD if_ex_badi_material_check~check_change_pmata.
  ENDMETHOD.


  METHOD if_ex_badi_material_check~check_data.

    IF wmarc IS NOT INITIAL.
      validate_plant_data(
        EXPORTING
          wmara = wmara
          wmarc = wmarc
        EXCEPTIONS
          invalid = 4 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING application_error.
      ENDIF.
    ENDIF.

    IF wmbew IS NOT INITIAL.
      validate_valuation_data(
        EXPORTING
          wmara = wmara
          wmbew = wmbew
        EXCEPTIONS
          invalid = 4 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING application_error.
      ENDIF.
    ENDIF.

    IF wmvke IS NOT INITIAL.
      validate_sales_data(
        EXPORTING
          wmara = wmara
          wmvke = wmvke
        EXCEPTIONS
          invalid = 4 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING application_error.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD if_ex_badi_material_check~check_data_retail.
  ENDMETHOD.


  METHOD if_ex_badi_material_check~check_mass_marc_data.
  ENDMETHOD.


  METHOD if_ex_badi_material_check~fre_suppress_marc_check.
  ENDMETHOD.


  METHOD validate_plant_data.

    SELECT SINGLE * FROM zlint_mat_wparam
      WHERE material_type = @wmara-mtart AND plant_no = @wmarc-werks
      INTO @DATA(plant_setting).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF plant_setting-exp_backflush_sign <> wmarc-rgekz.
      MESSAGE e006 WITH wmara-matnr plant_setting-exp_backflush_sign
        RAISING invalid.
    ENDIF.

    IF plant_setting-exp_batch_mandatory <> wmarc-xchpf
        AND plant_setting-exp_batch_mandatory = abap_true.
      MESSAGE e019 WITH wmara-matnr
        RAISING invalid.
    ENDIF.

    IF plant_setting-prod_profile_mandatory = abap_true
        AND wmarc-sfcpf IS INITIAL.
      MESSAGE e014 WITH wmara-matnr plant_setting-plant_no
        RAISING invalid.
    ENDIF.

    IF plant_setting-prod_supervisor_mandatory = abap_true
        AND wmarc-fevor IS INITIAL.
      MESSAGE e015 WITH wmara-matnr plant_setting-plant_no
        RAISING invalid.
    ENDIF.

  ENDMETHOD.


  METHOD validate_sales_data.
    DATA:
      setting_found TYPE sap_bool.

    SELECT * FROM zlint_mat_mvgr
      WHERE vkorg = @wmvke-vkorg AND vtweg = @wmvke-vtweg
      INTO TABLE @DATA(settings).

    LOOP AT settings INTO DATA(setting).
      DATA(matnr_range) = VALUE _matnr_range( ( sign = setting-matnr_sign
        option = setting-matnr_option low = setting-matnr_low high = setting-matnr_high ) ).
      IF wmara-matnr IN matnr_range.
        setting_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF setting_found = abap_false.
      RETURN.
    ENDIF.

    IF setting-exp_mvgr1 IS NOT INITIAL AND setting-exp_mvgr1 <> wmvke-mvgr1.
      MESSAGE e017 WITH '1' setting-exp_mvgr1 wmara-matnr setting-vkorg
        RAISING invalid.
    ENDIF.

    IF setting-exp_mvgr2 IS NOT INITIAL AND setting-exp_mvgr2 <> wmvke-mvgr2.
      MESSAGE e017 WITH '2' setting-exp_mvgr2 wmara-matnr setting-vkorg
        RAISING invalid.
    ENDIF.

    IF setting-exp_mvgr3 IS NOT INITIAL AND setting-exp_mvgr3 <> wmvke-mvgr3.
      MESSAGE e017 WITH '3' setting-exp_mvgr3 wmara-matnr setting-vkorg
        RAISING invalid.
    ENDIF.

    IF setting-exp_mvgr4 IS NOT INITIAL AND setting-exp_mvgr4 <> wmvke-mvgr4.
      MESSAGE e017 WITH '4' setting-exp_mvgr4 wmara-matnr setting-vkorg
        RAISING invalid.
    ENDIF.

    IF setting-exp_mvgr5 IS NOT INITIAL AND setting-exp_mvgr5 <> wmvke-mvgr5.
      MESSAGE e017 WITH '5' setting-exp_mvgr5 wmara-matnr setting-vkorg
        RAISING invalid.
    ENDIF.

  ENDMETHOD.


  METHOD validate_valuation_data.

    SELECT SINGLE * FROM zlint_mat_vparam
      WHERE material_type = @wmara-mtart AND valuation_area = @wmbew-bwkey
      INTO @DATA(setting).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF setting-exp_valuation_category <> wmbew-bwtty.
      MESSAGE e000 WITH setting-exp_valuation_category wmara-matnr
        RAISING invalid.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
