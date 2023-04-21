*&---------------------------------------------------------------------*
*& Report  ZM_MATERIAL_COMPLETE
*& Report validate material master data and print out found
*& inconsistencies.
*&---------------------------------------------------------------------*
REPORT zm_material_complete MESSAGE-ID zlint_mat.

TABLES: mara.

SELECT-OPTIONS:
  d_create FOR mara-ersda,
  matnr_r FOR mara-matnr,
  mtart_r FOR mara-mtart.

START-OF-SELECTION.

  SELECT * FROM mara
    WHERE matnr IN @matnr_r AND mtart IN @mtart_r AND ersda IN @d_create
    INTO TABLE @DATA(materials).
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  SELECT matnr, maktx FROM makt
    FOR ALL ENTRIES IN @materials
    WHERE matnr = @materials-matnr AND spras = @sy-langu
    INTO TABLE @DATA(material_texts).

  DATA(logger) = zcl_logger_factory=>create_log( ).

  LOOP AT materials REFERENCE INTO DATA(material).

    DATA(logger_material) = zcl_logger_factory=>create_log( ).
    TRY.
        ##NEEDED
        MESSAGE s018 WITH material->*-matnr material_texts[ matnr = material->*-matnr ]-maktx
          INTO DATA(mtext).
      CATCH cx_sy_itab_line_not_found.
        MESSAGE s018 WITH material->*-matnr space
          INTO mtext.
    ENDTRY.
    logger_material->add( ).

    zlint_mat_material_complete=>plant_data_complete(
      material = material->* logger = logger_material ).
    zlint_mat_material_complete=>storage_locations_complete(
      material = material->* logger = logger_material ).
    zlint_mat_material_complete=>sales_data_complete(
      material = material->* logger = logger_material ).
    zlint_mat_material_complete=>valuation_data_complete(
      material = material->* logger = logger_material ).

    IF logger_material->has_errors( ) = abap_true.
      logger->add( logger_material->export_to_table( ) ).
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'BAL_DSP_LOG_TEXTFORM'
    EXPORTING
      i_log_handle = logger->handle.
