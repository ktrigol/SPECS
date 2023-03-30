create or replace PACKAGE "SPC_TOOL" AS 
/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:
   Package in charge of manipulating most of the utilities for the specificities.
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
    Function Description: Returns the description of a specificity in a given language
    Return: Text 
    Parameters:  
        @ p_spc_id    NOT NULL        ID of the specificity
        @ p_lang      NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */
    function get_description_lang ( p_spc_id        in spc_definition.id%type
                                  , p_lang          in spc_lang.lang_code%type default null
      ) return varchar2;
  
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the help text of a specificity in a given language
    Return: Text 
    Parameters:  
        @ p_spc_id    NOT NULL        ID of the specificity
        @ p_lang      NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */
    function get_des_helptext_lang ( p_spc_id        in spc_definition.id%type
                                   , p_lang          in spc_lang.lang_code%type default null
      ) return varchar2;
  
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the SQL query to be used in a LOV
    Return: SQL query
    Parameters: 
        @ p_list_group NOT NULL       Group of the list
        @ p_list_code  NOT NULL       Code of the list 
        @ p_lang       NULL           Code of the language
    -------------------------------------------------------------------------
    */
    function get_spc_query_lov ( p_list_group    in spc_lov.list_group%type
                               , p_list_code     in spc_lov.list_code%type
                               , p_lang          in spc_lang.lang_code%type
      ) return varchar2;
    
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the description for a given list on the given language
    Return: TEXT Varchar2
    Parameters: 
        @ p_list_id    NOT NULL       ID of the list
        @ p_lang       NULL           Code of the language
    -------------------------------------------------------------------------
    */
    function get_spc_lov_desc ( p_list_id       in spc_lov.id%type
                              , p_lang          in spc_lang.lang_code%type
      ) return varchar2;
    /************************************************************************
    ------------------------------------------------------------------------- 
    Procedure Description: Returns the audit information for a given record
    Parameters: 
        @ p_ref_id          NOT NULL    ID of the record
        @ p_table_name      NOT NULL    Name of the table
        @ p_column_name1    NULL        Name of the column date of creation
        @ p_column_name2    NULL        Name of the column user of creation
        @ p_column_name3    NULL        Name of the column date of modification
        @ p_column_name4    NULL        Name of the column user of modification
    OUT:
        @ out_date_created   OUT       Date when the record was created
        @ out_created_by     OUT       User who created the record
        @ out_date_modified  OUT       Date when the record was modified
        @ out_modified_by    OUT       User who modified the record
    -------------------------------------------------------------------------
    */

    procedure get_audit_resp ( p_ref_id           in number
                             , p_table_name       in varchar2
                             , p_column_name1     in varchar2 default null
                             , p_column_name2     in varchar2 default null
                             , p_column_name3     in varchar2 default null
                             , p_column_name4     in varchar2 default null
                             , out_date_created   out varchar2
                             , out_created_by     out varchar2
                             , out_date_modified  out varchar2
                             , out_modified_by    out varchar2
      );
    
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the value of a given specificity
    Parameters: 
        @ p_spc_id     NOT NULL       ID of the specificity
        @ p_ref_id     NOT NULL       ID of the reference
        @ p_lang       NULL           Code of the language
        @ p_format     NULL           Format of the value
    -------------------------------------------------------------------------
    */
    function get_value_spc( p_spc_id     in spc_definition.id%type
                          , p_ref_id     in spc_data.ref_id%type
                          , p_lang       in spc_lang.lang_code%type default null
                          , p_format     in varchar2 default 'Y') 
    return varchar2;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the value of a given specificity
    Parameters: 
        @ p_spc_code   NOT NULL       Code of the specificity
        @ p_ref_id     NOT NULL       ID of the reference
        @ p_lang       NULL           Code of the language
        @ p_format     NULL           Format of the value
    -------------------------------------------------------------------------
    */
    function get_value_spc( p_spc_code   in spc_definition.spc_code%type
                          , p_ref_id     in spc_data.ref_id%type
                          , p_lang       in spc_lang.lang_code%type default null
                          , p_format     in varchar2 default 'Y') 
    return varchar2;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the value formated for a given specificity
    Parameters: 
        @ p_filed_type NOT NULL       Type of the specificity
        @ p_value      NOT NULL       Value of the specificity
        @ p_lang       NULL           Code of the language
    -------------------------------------------------------------------------
    */
    function format_spc_value ( p_filed_type in spc_definition.field_type%type
                              , p_value      in spc_data.value%type
                              , p_lang       in spc_lang.lang_code%type default null) 
    return varchar2;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the id of a given language from the table spc_lang
    Parameters: 
        @ p_lang_code  NOT NULL       Code of the language
    -------------------------------------------------------------------------
    */
    function get_lang_id( 
        p_lang_code in spc_lang.lang_code%type
    ) return number;
    
END SPC_TOOL;
