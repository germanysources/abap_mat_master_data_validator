*&---------------------------------------------------------------------*
*& Report  ZLINT_MAT_RECIPE_CHECK
*& Reports validates recipes (Transaction C203)
*& - BOM exists for production versions assigned to recipes
*& - BOM items are assigned to recipe steps
*&---------------------------------------------------------------------*
REPORT zlint_mat_recipe_check.

PARAMETERS:
  type    TYPE plnty,
  rec_no  TYPE plnnr,
  item_no TYPE plnal,
  plant   TYPE werks_d.

START-OF-SELECTION.

  PERFORM:
    boms_assigned,
    bom_items_assigned.

FORM boms_assigned.

  zlint_mat_recipe_check=>bom_exists(
    EXPORTING
      recipe = VALUE #( type = type recipe_no = rec_no item_no = item_no plant_no = plant )
    IMPORTING
      unassigned_materials = DATA(unassigned_materials) ).

  IF unassigned_materials IS INITIAL.
    RETURN.
  ENDIF.

  WRITE text-002. NEW-LINE.
  LOOP AT unassigned_materials REFERENCE INTO DATA(un_mat).
    WRITE un_mat->*. NEW-LINE.
  ENDLOOP.

ENDFORM.

FORM bom_items_assigned.

  zlint_mat_recipe_check=>bom_items_assigned(
    EXPORTING
      recipe = VALUE #( type = type recipe_no = rec_no item_no = item_no plant_no = plant )
    IMPORTING
      unassigned_materials = DATA(unassigned_materials) ).

  IF unassigned_materials IS INITIAL.
    RETURN.
  ENDIF.

  WRITE text-001. NEW-LINE.
  LOOP AT unassigned_materials REFERENCE INTO DATA(un_mat).
    WRITE un_mat->*. NEW-LINE.
  ENDLOOP.

ENDFORM.
