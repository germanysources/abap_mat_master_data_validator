*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZLINT_MAT_LPARAM................................*
DATA:  BEGIN OF STATUS_ZLINT_MAT_LPARAM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZLINT_MAT_LPARAM              .
CONTROLS: TCTRL_ZLINT_MAT_LPARAM
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZLINT_MAT_MVGR..................................*
DATA:  BEGIN OF STATUS_ZLINT_MAT_MVGR                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZLINT_MAT_MVGR                .
CONTROLS: TCTRL_ZLINT_MAT_MVGR
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZLINT_MAT_VPARAM................................*
DATA:  BEGIN OF STATUS_ZLINT_MAT_VPARAM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZLINT_MAT_VPARAM              .
CONTROLS: TCTRL_ZLINT_MAT_VPARAM
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZLINT_MAT_WPARAM................................*
DATA:  BEGIN OF STATUS_ZLINT_MAT_WPARAM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZLINT_MAT_WPARAM              .
CONTROLS: TCTRL_ZLINT_MAT_WPARAM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZLINT_MAT_LPARAM              .
TABLES: *ZLINT_MAT_MVGR                .
TABLES: *ZLINT_MAT_VPARAM              .
TABLES: *ZLINT_MAT_WPARAM              .
TABLES: ZLINT_MAT_LPARAM               .
TABLES: ZLINT_MAT_MVGR                 .
TABLES: ZLINT_MAT_VPARAM               .
TABLES: ZLINT_MAT_WPARAM               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
