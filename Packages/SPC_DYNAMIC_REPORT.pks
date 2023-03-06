create or replace PACKAGE "SPC_DYNAMIC_REPORT" AS 
/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:
   Package in charge of manipulating dynamic reports.
   Requirements
   * APEX is installed 
   * Package is executed from within an APEX application
     or
     At least one APEX workspace has been created
   If APEX is not installed go to apex.oracle.com for instructions.
   <provide code example to use workspace API>
   Modification History
 *------------------------------------------------------------------* 
 | Date      | Who                | What                            |
 *------------------------------------------------------------------*
   0000-00-00 Name Lastname        text
 *------------------------------------------------------------------*
 */
  
    /************************************************************************
    ------------------------------------------------------------------------- 
    Fonction Description: Generates and return the SQL for the region of the Plug-in
    Return: SQL
    Parameters:  
        @ p_app_id      NOT NULL        Apex Application id value. 
        @ p_page_id     NOT NULL        Apex Page id value.
        @ p_group_id    NULL            ID of the group of specificities, null for all spec for the app and page.
    -------------------------------------------------------------------------
    */
    function get_dr_query /*( p_app_id      in number
                          , p_page_id     in number
                          , p_group_id    in number 
    )*/return varchar2;
   /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Generates and return the SQL for the poplov for the column_value = spc or column name
    Return: SQL
    Parameters:  
        @ p_ref_type_id    NOT NULL     Type of reference id  
        @ p_spc_ind        NOT NULL     Specificity indicator
        @ p_lang           NOT NULL     Language
    -------------------------------------------------------------------------
    */
    function get_col_val_query ( p_ref_type_id      in number
                               , p_spc_ind          in number
                               , p_lang             in varchar2 default null 
    )return varchar2;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the report name or detail in the given language
    Return: Text 
    Parameters:  
        @ p_report_id     NOT NULL        ID of the report
        @ p_value         NOT NULL        REPORT_NAME or DETAIL
        @ p_lang          NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */

    function get_description_lang ( p_report_id     in spc_report.id%type
                                  , p_value         in varchar2 -- REPORT_NAME or DETAIL
                                  , p_lang          in spc_lang.lang_code%type default null
    ) return varchar2;
      
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the label name in the given language
    Return: Text 
    Parameters:  
        @ p_detail_id     NOT NULL        ID of the detail from spc_report_detail
        @ p_lang          NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */

    function get_label_name_lang ( p_detail_id     in spc_report.id%type
                                  , p_lang          in spc_lang.lang_code%type default null
    ) return varchar2;

    /************************************************************************
    -------------------------------------------------------------------------
    Procedure Description: initialize the collection of the report
    Parameters:
        @ p_collection_name     NOT NULL        Name of the collection
        @ p_report_id           NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    procedure init_coll_dynamic_report( p_collection_name in varchar2
                                      , p_report_id       in spc_report.id%type
    );

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Returns the columns position for the group by
    Return: Text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    function get_col_pos_group_by(p_report_id      in spc_report.id%type
    ) return number;

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Returns the columns position for the order by
    Return: Text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    function column_count( p_report_id      in spc_report_detail.id%type
    ) return number;

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Return the columns query for the collection 
    Return: text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
        @ p_seq           NOT NULL        Sequence number of the column
    -------------------------------------------------------------------------
    */

    function get_column_query_coll( p_report_id            in spc_report.id%type
                                  , p_seq                  in number
                                  --, p_ind_valeur_reference in number
    )return varchar2;

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Function to get the query for the collection
    Return: Text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    function get_query_collection( p_report_id         in spc_report.id%type
    ) return clob;

END SPC_DYNAMIC_REPORT;
