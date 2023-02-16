create or replace PACKAGE BODY "SPC_TOOLS" AS 

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
      ) return varchar2
    is
      l_return spc_definition_lang.description%type;
    begin
        -- Get the description of the specificity in the given language
        select t1.description
        into l_return
        from spc_definition_lang t1
        join spc_lang t2
        on t1.spc_lang_id = t2.id
        where (t2.lang_code = p_lang
              or p_lang is null
              and t2.default_lang_ind = 1)
        and   t1.spc_definition_id = p_spc_id;

        -- Return the description
        return l_return;
    exception 
        when no_data_found then
            -- log error
            return 'No description found for this specificity in this language';
        when others then 
            -- log error
            return 'One error has occured: '||sqlerrm;
    end get_description_lang;
  
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the hep text of a specificity in a given language
    Return: Text 
    Parameters:  
        @ p_spc_id    NOT NULL        ID of the specificity
        @ p_lang      NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */

    function get_des_helptext_lang ( p_spc_id        in spc_definition.id%type
                                   , p_lang          in spc_lang.lang_code%type default null
      ) return varchar2
    is
      l_return spc_definition_lang.description%type;
    begin
        -- Get the description of the specificity in the given language
        select t1.help_text
        into l_return
        from spc_definition_lang t1
        join spc_lang t2
        on t1.spc_lang_id = t2.id
        where (t2.lang_code = p_lang
              or p_lang is null
              and t2.default_lang_ind = 1)
        and   t1.spc_definition_id = p_spc_id;

        -- Return the description
        return l_return;
    exception 
        when no_data_found then
            -- log error
            return null;
        when others then 
            -- log error
            return 'One error has occured: '||sqlerrm;
    end get_des_helptext_lang;
  
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
      ) return varchar2
    is
      l_return varchar2(4000);
    begin
      -- Build the query
      l_return := ' select t2.description as display, t1.id as return '|| 
                    ' from spc_lov t1 '|| 
                    ' join spc_lov_lang t2 '|| 
                    ' on t1.id = t2.spc_lov_id '|| 
                    ' join spc_lang t3 '|| 
                    ' on t2.spc_lang_id = t3.id '|| 
                    ' where t1.list_group = ''' || p_list_group || ''' '|| 
                    ' and t1.list_code = ''' || p_list_code || ''' '|| 
                    ' and (t3.lang_code = ''' || p_lang ||''' '|| 
                    '     or coalesce('''|| p_lang ||''',''DFLT'') = ''DFLT'' '|| 
                    '     and t3.default_lang_ind = 1)' || 
                    ' order by value_code';
      -- Return the query
      return l_return;
    end get_spc_query_lov;

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
      ) return varchar2
    is
      l_return spc_lov_lang.description%type;
    begin
        -- Get the description of the specificity in the given language
        select t1.description
        into l_return
        from spc_lov_lang t1
        join spc_lang t2
        on t1.spc_lang_id = t2.id
        where (t2.lang_code = p_lang
              or p_lang is null
              and t2.default_lang_ind = 1)
        and   t1.spc_lov_id = p_list_id;

        -- Return the description
        return l_return;
    exception 
        when no_data_found then
            -- log error
            return 'No description for this specificity';
        when others then 
            -- log error
            return 'One error has occured: '||sqlerrm;
    end get_spc_lov_desc;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Procedure Description: Returns the audit information for a given record
    Parameters: 
        @ p_list_id    NOT NULL       ID of the list
        @ p_lang       NULL           Code of the language
    OUT:
        @ out_date_created   OUT       Date when the record was created
        @ out_created_by     OUT       User who created the record
        @ out_date_modified  OUT       Date when the record was modified
        @ out_modified_by    OUT       User who modified the record
    -------------------------------------------------------------------------
    */

    procedure get_audit_resp ( p_ref_id           in number
                             , p_table_name       in varchar2
                             , out_date_created   out varchar2
                             , out_created_by     out varchar2
                             , out_date_modified  out varchar2
                             , out_modified_by    out varchar2
      )
    is 
    begin
        execute immediate 'select created, created_by, modified, modified_by from '||p_table_name||' where id = '||p_ref_id
        into out_date_created, out_created_by, out_date_modified, out_modified_by;
    exception
      when no_data_found then
        out_date_created := null;
        out_created_by := null;
        out_date_modified := null;
        out_modified_by := null;
      when others then
        raise_application_error(-20000, 'Error in get_audit_resp: '||sqlerrm);
    end get_audit_resp;

  
    
END SPC_TOOLS;
