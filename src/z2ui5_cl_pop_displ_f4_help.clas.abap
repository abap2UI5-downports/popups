CLASS z2ui5_cl_pop_displ_f4_help DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_app.

    DATA mt_data         TYPE REF TO data.
    DATA ms_data_row     TYPE REF TO data.
    DATA ms_layout       TYPE z2ui5_cl_pop_display_layout=>ty_s_layout.

    DATA mv_table        TYPE string.
    DATA mv_field        TYPE string.
    DATA mv_value        TYPE string.
    DATA mv_return_value TYPE string.
    DATA mv_rows         TYPE int1 VALUE '50'.
    DATA mt_dfies        TYPE z2ui5_cl_util=>ty_t_dfies.

    CLASS-METHODS factory
      IMPORTING
        i_table       TYPE string
        i_fname       TYPE string
        i_value       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_pop_displ_f4_help.


  PROTECTED SECTION.
    DATA client             TYPE REF TO z2ui5_if_client.
    DATA mv_init            TYPE abap_bool.
    DATA mv_check_tab_field TYPE string.
    DATA mv_check_tab       TYPE string.

    METHODS get_dfies.

    METHODS on_init.

    METHODS render_view.

    METHODS on_event.

    METHODS set_row_id.

    METHODS get_txt
      IMPORTING
        roll          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_data
      IMPORTING
        !where TYPE string.

    METHODS get_where_tab
      RETURNING
        VALUE(result) TYPE string.

    METHODS prefill_inputs.

    METHODS on_after_layout.

    METHODS get_layout.

    METHODS create_objects.
ENDCLASS.


CLASS z2ui5_cl_pop_displ_f4_help IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_init = abap_false.
      mv_init = abap_true.

      on_init( ).

      IF mv_check_tab IS INITIAL.
        RETURN.
      ENDIF.

      render_view( ).

    ENDIF.

    on_event( ).

    on_after_layout( ).

  ENDMETHOD.

  METHOD on_init.

    get_dfies( ).

    IF mv_check_tab IS INITIAL.
      RETURN.
    ENDIF.

    create_objects( ).

    prefill_inputs( ).

    get_data( get_where_tab( ) ).

    get_layout( ).

  ENDMETHOD.

  METHOD get_where_tab.

    DATA temp1 LIKE LINE OF mt_dfies.
    DATA dfies LIKE REF TO temp1.
      FIELD-SYMBOLS <row> TYPE data.
      FIELD-SYMBOLS <value> TYPE any.
        DATA and TYPE string.
        DATA escape TYPE string.
    LOOP AT mt_dfies REFERENCE INTO dfies.

      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      
      ASSIGN ms_data_row->* TO <row>.

      
      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE <row> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF <value> IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS NOT INITIAL.
        
        and = ` AND `.
      ENDIF.

      IF <value> CA `_`.
        
        escape = `ESCAPE '#'`.
      ELSE.
        CLEAR escape.
      ENDIF.

      result = |{ result }{ and } ( { dfies->fieldname } LIKE '%{ <value> }%' { escape } )|.

      IF result CA `_`.
        REPLACE ALL OCCURRENCES OF `_` IN result WITH `#_`.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD create_objects.

    DATA index TYPE int4.
        DATA temp2 TYPE cl_abap_structdescr=>component_table.
        DATA temp3 LIKE LINE OF temp2.
        DATA temp1 TYPE REF TO cl_abap_datadescr.
        DATA comp LIKE temp2.
        DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
        DATA new_table_desc TYPE REF TO cl_abap_tabledescr.

    TRY.

        
        CLEAR temp2.
        
        temp3-name = 'ROW_ID'.
        
        temp1 ?= cl_abap_datadescr=>describe_by_data( index ).
        temp3-type = temp1.
        INSERT temp3 INTO TABLE temp2.
        
        comp = temp2.

        APPEND LINES OF z2ui5_cl_util=>rtti_get_t_attri_by_table_name( mv_check_tab  ) TO comp.

        
        new_struct_desc = cl_abap_structdescr=>create( comp ).

        
        new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA mt_data     TYPE HANDLE new_table_desc.
        CREATE DATA ms_data_row TYPE HANDLE new_struct_desc.

      CATCH cx_root.

    ENDTRY.

  ENDMETHOD.

  METHOD get_data.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

    TRY.
        ASSIGN mt_data->* TO <table>.

        SELECT *
          FROM (mv_check_tab)
          WHERE (where)
          INTO CORRESPONDING FIELDS OF TABLE <table>
          UP TO mv_rows ROWS.

        IF sy-subrc <> 0.
          client->message_toast_display( 'No Entries found.' ).
        ENDIF.

        set_row_id( ).

      CATCH cx_root.
        client->message_toast_display( 'Table not released.' ).
    ENDTRY.

  ENDMETHOD.

  METHOD render_view.

    DATA popup TYPE REF TO z2ui5_cl_xml_view.
    DATA simple_form TYPE REF TO z2ui5_cl_xml_view.
    DATA temp4 LIKE LINE OF mt_dfies.
    DATA dfies LIKE REF TO temp4.
      FIELD-SYMBOLS <row> TYPE data.
      FIELD-SYMBOLS <val> TYPE any.
      DATA temp5 TYPE string.
    FIELD-SYMBOLS <table> TYPE data.
    DATA table TYPE REF TO z2ui5_cl_xml_view.
    DATA headder TYPE REF TO z2ui5_cl_xml_view.
    DATA columns TYPE REF TO z2ui5_cl_xml_view.
    DATA temp6 LIKE LINE OF ms_layout-t_layout.
    DATA layout LIKE REF TO temp6.
      DATA lv_index LIKE sy-tabix.
    DATA temp7 TYPE string_table.
    DATA cells TYPE REF TO z2ui5_cl_xml_view.
    popup = z2ui5_cl_xml_view=>factory_popup( ).

    
    simple_form = popup->dialog( title        = 'F4-Help'
                                       contentwidth = '90%'
                                       afterclose   = client->_event( 'F4_CLOSE' )
          )->simple_form( title    = 'F4-Help'
                          layout   = 'ResponsiveGridLayout'
                          editable = abap_true
          )->content( 'form' ).

    
    
    LOOP AT mt_dfies REFERENCE INTO dfies.

      IF dfies->fieldname = `MANDT`.
        CONTINUE.
      ENDIF.
      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      
      ASSIGN ms_data_row->* TO <row>.

      
      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE <row> TO <val>.
      IF <val> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      
      temp5 = dfies->rollname.
      simple_form->label( get_txt( temp5 ) ).

      simple_form->input( value         = client->_bind_edit( <val> )
                          showvaluehelp = abap_false
                          submit        = client->_event( 'F4_INPUT_DONE' ) ).

    ENDLOOP.

    simple_form->label( get_txt( 'SYST_TABIX' ) ).

    simple_form->input( value         = client->_bind_edit( mv_rows )
                        showvaluehelp = abap_false
                        submit        = client->_event( 'F4_INPUT_DONE' )
                        maxlength     = '3' ).

    
    ASSIGN mt_data->* TO <table>.

    
    table = popup->get_child( )->table( growing    = 'true'
                                              width      = 'auto'
                                              items      = client->_bind( val = <table> )
                                              headertext = mv_check_tab  ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    
    headder = table->header_toolbar(
                 )->overflow_toolbar(
                 )->title( mv_check_tab
                 )->toolbar_spacer( ).

    headder = z2ui5_cl_pop_display_layout=>render_layout_function( xml    = headder
                                                              client = client ).

    
    columns = table->columns( ).

    
    
    LOOP AT ms_layout-t_layout REFERENCE INTO layout.
      
      lv_index = sy-tabix.

      columns->column( visible         = client->_bind( val       = layout->visible
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       halign          = client->_bind( val       = layout->halign
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       importance      = client->_bind( val       = layout->importance
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       mergeduplicates = client->_bind( val       = layout->merge
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       minscreenwidth  = client->_bind( val       = layout->width
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
       )->text( layout->tlabel ).

    ENDLOOP.

    
    CLEAR temp7.
    INSERT `${ROW_ID}` INTO TABLE temp7.
    
    cells = columns->get_parent( )->items(
                                       )->column_list_item(
                                           valign = 'Middle'
                                           type   = 'Navigation'
                                           press  = client->_event( val   = 'F4_ROW_SELECT'
                                                                    t_arg = temp7 )
                                       )->cells( ).

    LOOP AT ms_layout-t_layout REFERENCE INTO layout.

      cells->object_identifier( text = |\{{ layout->fname }\}| ).

    ENDLOOP.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD on_event.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
        DATA lt_arg TYPE string_table.
        FIELD-SYMBOLS <row> TYPE any.
        DATA temp1 LIKE LINE OF lt_arg.
        DATA temp2 LIKE sy-tabix.
        FIELD-SYMBOLS <value> TYPE any.

    CASE client->get( )-event.

      WHEN `F4_CLOSE`.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `F4_ROW_SELECT`.

        
        lt_arg = client->get( )-t_event_arg.

        ASSIGN mt_data->* TO <tab>.

        
        
        
        temp2 = sy-tabix.
        READ TABLE lt_arg INDEX 1 INTO temp1.
        sy-tabix = temp2.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        READ TABLE <tab> INDEX temp1 ASSIGNING <row>.

        
        ASSIGN COMPONENT mv_check_tab_field OF STRUCTURE <row> TO <value>.
        IF <value> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        mv_return_value = <value>.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'F4_INPUT_DONE'.

        get_data( get_where_tab( ) ).

        client->popup_model_update( ).

      WHEN OTHERS.

        client = z2ui5_cl_pop_display_layout=>on_event_layout( client = client
                                                          layout = ms_layout ).

    ENDCASE.

  ENDMETHOD.

  METHOD set_row_id.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <row> TYPE any.

    ASSIGN mt_data->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.

      
      ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <line> TO <row>.
      IF <row> IS ASSIGNED.
        <row> = sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD factory.

    CREATE OBJECT result.

    result->mv_table = i_table.
    result->mv_field = i_fname.
    result->mv_value = i_value.

  ENDMETHOD.

  METHOD get_txt.

    result = z2ui5_cl_util=>rtti_get_data_element_texts( roll )-long.

  ENDMETHOD.

  METHOD get_dfies.

    DATA t_dfies TYPE z2ui5_cl_abap_api=>ty_t_dfies.
    DATA dfies TYPE REF TO z2ui5_cl_abap_api=>ty_s_dfies.
    DATA temp9 TYPE string.
    DATA temp10 TYPE string.
    DATA temp11 TYPE z2ui5_cl_abap_api=>ty_s_dfies.
      DATA temp12 TYPE string.
      DATA temp13 TYPE z2ui5_cl_abap_api=>ty_s_dfies.
    t_dfies = z2ui5_cl_util=>rtti_get_t_dfies_by_table_name( mv_table ).

    
    READ TABLE t_dfies REFERENCE INTO dfies WITH KEY fieldname = mv_field.
    IF sy-subrc <> 0.

      client->popup_destroy( ).
      client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

    ENDIF.

    IF dfies->checktable IS INITIAL.
      RETURN.
    ENDIF.

    
    temp9 = dfies->checktable.
    mt_dfies = z2ui5_cl_util=>rtti_get_t_dfies_by_table_name( temp9 ).
    "
    " ASSIGNMENT --- this may not be 100% certain ... :(
    
    CLEAR temp10.
    
    READ TABLE mt_dfies INTO temp11 WITH KEY rollname = dfies->rollname.
    IF sy-subrc = 0.
      temp10 = temp11-fieldname.
    ENDIF.
    mv_check_tab_field = temp10.
    "  we have to go via Domname ..

    IF mv_check_tab_field IS INITIAL.
      
      CLEAR temp12.
      
      READ TABLE mt_dfies INTO temp13 WITH KEY domname = dfies->domname.
      IF sy-subrc = 0.
        temp12 = temp13-fieldname.
      ENDIF.
      mv_check_tab_field = temp12.
    ENDIF.
    mv_check_tab = dfies->checktable.

  ENDMETHOD.

  METHOD prefill_inputs.

    DATA temp14 LIKE LINE OF mt_dfies.
    DATA dfies LIKE REF TO temp14.
      FIELD-SYMBOLS <row> TYPE data.
      FIELD-SYMBOLS <val> TYPE any.
    LOOP AT mt_dfies REFERENCE INTO dfies.

      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      
      ASSIGN ms_data_row->* TO <row>.

      
      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE <row> TO <val>.
      IF <val> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      IF dfies->fieldname = mv_check_tab_field.

        <val> = mv_value.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD on_after_layout.
        DATA temp15 TYPE REF TO z2ui5_cl_pop_display_layout.
        DATA app LIKE temp15.

    " Kommen wir aus einer anderen APP
    IF client->get( )-check_on_navigated = abap_false.
      RETURN.
    ENDIF.

    TRY.
        " War es das Layout?
        
        temp15 ?= client->get_app( client->get( )-s_draft-id_prev_app ).
        
        app = temp15.

        ms_layout = app->ms_layout.

        render_view( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD get_layout.

    DATA class TYPE string.
    DATA temp16 TYPE z2ui5_cl_pop_display_layout=>handle.
    DATA temp2 TYPE z2ui5_cl_pop_display_layout=>handle.
    class = ``.
    class = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.

    
    temp16 = class.
    
    temp2 = mv_table.
    ms_layout = z2ui5_cl_pop_display_layout=>init_layout( control  = z2ui5_cl_pop_display_layout=>m_table
                                                     data     = mt_data
                                                     handle01 = temp16
                                                     handle02 = temp2
                                                     handle03 =  'F4'  ).

  ENDMETHOD.

ENDCLASS.
