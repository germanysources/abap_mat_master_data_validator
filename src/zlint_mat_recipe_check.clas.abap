CLASS zlint_mat_recipe_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF _recipe,
        type      TYPE plnty,
        recipe_no TYPE plnnr,
        item_no   TYPE plnal,
        plant_no  TYPE werks_d,
      END OF _recipe .
    TYPES:
      _materials TYPE STANDARD TABLE OF matnr .

    CLASS-METHODS bom_items_assigned
      IMPORTING
        !recipe               TYPE _recipe
      EXPORTING
        !unassigned_materials TYPE _materials .
    CLASS-METHODS bom_exists
      IMPORTING
        !recipe               TYPE _recipe
      EXPORTING
        !unassigned_materials TYPE _materials .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZLINT_MAT_RECIPE_CHECK IMPLEMENTATION.


  METHOD bom_exists.

    SELECT matnr FROM mkal
      WHERE plnty = @recipe-type AND plnnr = @recipe-recipe_no
      AND alnal = @recipe-item_no AND ( stlan = @space OR stlal = @space )
      AND werks = @recipe-plant_no
      INTO TABLE @unassigned_materials.

  ENDMETHOD.


  METHOD bom_items_assigned.

    CLEAR unassigned_materials.

    SELECT m~matnr, m~stlnr, v~stlal, bi~stlty, bi~stlkn FROM mast AS m
      INNER JOIN mkal AS v ON v~matnr = m~matnr AND v~werks = m~werks
      AND v~stlan = m~stlan AND v~stlal = m~stlal
      INNER JOIN stpo AS bi ON bi~stlnr = m~stlnr
      WHERE v~plnty = @recipe-type AND v~plnnr = @recipe-recipe_no
      AND alnal = @recipe-item_no
      AND bi~menge = 1
      INTO TABLE @DATA(bom_headers).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT stlnr, stlal, stlkn FROM plmz
      FOR ALL ENTRIES IN @bom_headers
      WHERE plnty = @recipe-type AND plnnr = @recipe-recipe_no
      AND stlty = @bom_headers-stlty
      AND stlnr = @bom_headers-stlnr AND stlkn = @bom_headers-stlkn
      INTO TABLE @DATA(existing_assignments).

    LOOP AT bom_headers REFERENCE INTO DATA(bom_header).
      IF NOT line_exists( existing_assignments[
        stlnr = bom_header->*-stlnr stlal = bom_header->*-stlal stlkn = bom_header->*-stlkn ] ).
        INSERT bom_header->*-matnr INTO TABLE unassigned_materials.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
