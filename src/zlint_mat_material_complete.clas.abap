CLASS zlint_mat_material_complete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS storage_locations_complete
      IMPORTING
        !material TYPE mara
        !logger   TYPE REF TO zif_logger .
    CLASS-METHODS plant_data_complete
      IMPORTING
        !material TYPE mara
        !logger   TYPE REF TO zif_logger .
    CLASS-METHODS sales_data_complete
      IMPORTING
        !material TYPE mara
        !logger   TYPE REF TO zif_logger .
    CLASS-METHODS valuation_data_complete
      IMPORTING
        !material TYPE mara
        !logger   TYPE REF TO zif_logger .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS validate_prod_version
      IMPORTING
        prod_version TYPE mkal
        logger       TYPE REF TO zif_logger.

ENDCLASS.



CLASS ZLINT_MAT_MATERIAL_COMPLETE IMPLEMENTATION.


  METHOD plant_data_complete.

    SELECT * FROM zlint_mat_wparam
      WHERE material_type = @material-mtart
      INTO TABLE @DATA(plant_settings).
    SELECT matnr, werks, rgekz, xchpf, sfcpf, fevor
      FROM marc
      WHERE matnr = @material-matnr
      INTO TABLE @DATA(existing_plant_data).
    SELECT matnr, werks FROM mast
      WHERE matnr = @material-matnr
      INTO TABLE @DATA(bom_headers).
    " Validate only future versions
    SELECT * FROM mkal
      WHERE matnr = @material-matnr AND bdatu >= @sy-datum
      INTO TABLE @DATA(prod_versions).

    LOOP AT plant_settings REFERENCE INTO DATA(plant_setting).
      READ TABLE existing_plant_data REFERENCE INTO DATA(plant_data)
        WITH KEY werks = plant_setting->*-plant_no.
      IF sy-subrc <> 0 AND plant_setting->*-plant_data_mandatory = abap_true.
        ##NEEDED
        MESSAGE e008 WITH material-matnr plant_setting->*-plant_no
          INTO DATA(mtext).
        logger->add( ).
        CONTINUE.
      ELSEIF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF plant_setting->*-exp_backflush_sign <> plant_data->*-rgekz.
        ##NEEDED
        MESSAGE e006 WITH material-matnr plant_setting->*-exp_backflush_sign
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF plant_setting->*-exp_batch_mandatory <> plant_data->*-xchpf
          AND plant_setting->*-exp_batch_mandatory = abap_true.
        ##NEEDED
        MESSAGE e019 WITH material-matnr
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF plant_setting->*-prod_profile_mandatory = abap_true
          AND plant_data->*-sfcpf IS INITIAL.
        ##NEEDED
        MESSAGE e014 WITH material-matnr plant_setting->*-plant_no
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF plant_setting->*-prod_supervisor_mandatory = abap_true
          AND plant_data->*-fevor IS INITIAL.
        ##NEEDED
        MESSAGE e015 WITH material-matnr plant_setting->*-plant_no
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF plant_setting->*-bom_mandatory = abap_true AND
          NOT line_exists( bom_headers[ matnr = material-matnr werks = plant_setting->*-plant_no ] ).
        ##NEEDED
        MESSAGE e010 WITH material-matnr plant_setting->*-plant_no
          INTO mtext.
        logger->add( ).
      ENDIF.

      READ TABLE prod_versions REFERENCE INTO DATA(prod_version)
        WITH KEY werks = plant_setting->*-plant_no.
      IF sy-subrc <> 0 AND plant_setting->*-prod_version_mandatory = abap_true.
        ##NEEDED
        MESSAGE e011 WITH material-matnr plant_setting->*-plant_no INTO mtext.
        logger->add( ).
      ELSEIF sy-subrc = 0.
        validate_prod_version(
          prod_version = prod_version->* logger = logger ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD sales_data_complete.
    TYPES: _matnr_range TYPE RANGE OF matnr.

    SELECT * FROM mvke
      WHERE matnr = @material-matnr
      INTO TABLE @DATA(sales_data).
    SELECT vkorg, vtweg, matnr FROM knmt
      WHERE matnr = @material-matnr
      INTO TABLE @DATA(customer_assignments).
    SELECT * FROM zlint_mat_mvgr
      INTO TABLE @DATA(settings).

    LOOP AT settings REFERENCE INTO DATA(setting).

      DATA(matnr_range) = VALUE _matnr_range( ( sign = setting->*-matnr_sign
        option = setting->*-matnr_option low = setting->*-matnr_low high = setting->*-matnr_high ) ).
      IF material-matnr NOT IN matnr_range.
        CONTINUE.
      ENDIF.

      READ TABLE sales_data REFERENCE INTO DATA(sales_org_data)
        WITH KEY vkorg = setting->*-vkorg vtweg = setting->*-vtweg.
      IF sy-subrc <> 0 AND setting->*-mandatory = abap_true.
        ##NEEDED
        MESSAGE e016 WITH material-matnr setting->*-vkorg setting->*-vtweg
          INTO DATA(mtext).
        logger->add( ).
        CONTINUE.
      ELSEIF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF setting->*-exp_mvgr1 IS NOT INITIAL AND setting->*-exp_mvgr1 <> sales_org_data->*-mvgr1.
        ##NEEDED
        MESSAGE e017 WITH '1' setting->*-exp_mvgr1 material-matnr setting->*-vkorg
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF setting->*-exp_mvgr2 IS NOT INITIAL AND setting->*-exp_mvgr2 <> sales_org_data->*-mvgr2.
        ##NEEDED
        MESSAGE e017 WITH '2' setting->*-exp_mvgr2 material-matnr setting->*-vkorg
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF setting->*-exp_mvgr3 IS NOT INITIAL AND setting->*-exp_mvgr3 <> sales_org_data->*-mvgr3.
        ##NEEDED
        MESSAGE e017 WITH '3' setting->*-exp_mvgr3 material-matnr setting->*-vkorg
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF setting->*-exp_mvgr4 IS NOT INITIAL AND setting->*-exp_mvgr4 <> sales_org_data->*-mvgr4.
        ##NEEDED
        MESSAGE e017 WITH '4' setting->*-exp_mvgr4 material-matnr setting->*-vkorg
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF setting->*-exp_mvgr5 IS NOT INITIAL AND setting->*-exp_mvgr5 <> sales_org_data->*-mvgr5.
        ##NEEDED
        MESSAGE e017 WITH '5' setting->*-exp_mvgr5 material-matnr setting->*-vkorg
          INTO mtext.
        logger->add( ).
      ENDIF.

      IF setting->*-assignment_to_customer = abap_true
          AND NOT line_exists( customer_assignments[ vkorg = setting->*-vkorg vtweg = setting->*-vtweg ] ).
        ##NEEDED
        MESSAGE e020 WITH material-matnr
          INTO mtext.
        logger->add( ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD storage_locations_complete.

    SELECT * FROM zlint_mat_lparam
      WHERE material_type = @material-mtart AND mandatory = @abap_true
      AND NOT EXISTS ( SELECT * FROM mard WHERE matnr = @material-matnr AND werks = zlint_mat_lparam~plant_no AND lgort = zlint_mat_lparam~storage_location )
      INTO TABLE @DATA(missing_locations).
    LOOP AT missing_locations REFERENCE INTO DATA(mis_location).
      ##NEEDED
      MESSAGE e007 WITH material-matnr mis_location->*-plant_no mis_location->*-storage_location
        INTO DATA(mtext).
      logger->add( ).
    ENDLOOP.

  ENDMETHOD.


  METHOD validate_prod_version.

    SELECT COUNT(*) FROM mast
      WHERE matnr = @prod_version-matnr AND werks = @prod_version-werks
      AND stlan = @prod_version-stlan AND stlal = @prod_version-stlal.
    IF sy-subrc <> 0.
      ##NEEDED
      MESSAGE e012 WITH prod_version-matnr prod_version-werks
        INTO DATA(mtext).
      logger->add( ).
    ENDIF.

    SELECT COUNT(*) FROM plko
      WHERE plnty = @prod_version-plnty AND plnnr = @prod_version-plnnr
      AND plnal = @prod_version-alnal.
    IF sy-subrc <> 0.
      ##NEEDED
      MESSAGE e013 WITH prod_version-matnr prod_version-werks prod_version-verid
        INTO mtext.
      logger->add( ).
    ENDIF.

  ENDMETHOD.


  METHOD valuation_data_complete.

    SELECT * FROM zlint_mat_vparam
      WHERE material_type = @material-mtart
      INTO TABLE @DATA(settings).
    SELECT matnr, bwkey, bwtty FROM mbew
      WHERE matnr = @material-matnr AND bwtar = @space
      INTO TABLE @DATA(existing_valuations).

    LOOP AT settings REFERENCE INTO DATA(setting).
      READ TABLE existing_valuations REFERENCE INTO DATA(valuation)
        WITH KEY bwkey = setting->*-valuation_area.
      IF sy-subrc <> 0 AND setting->*-mandatory = abap_true.
        ##NEEDED
        MESSAGE e009 WITH material-matnr setting->*-valuation_area
          INTO DATA(mtext).
        logger->add( ).
        CONTINUE.
      ELSEIF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF setting->*-exp_valuation_category <> valuation->*-bwtty.
        ##NEEDED
        MESSAGE e000 WITH material-matnr setting->*-exp_valuation_category
          INTO mtext.
        logger->add( ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
