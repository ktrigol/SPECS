create or replace PACKAGE BODY SPC_DYNAMIC_REPORT AS 
     
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
    Function Description: Generates and return the SQL for the region of the Plug-in 
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
    )*/ return varchar2  
    is
        l_result varchar2(32767);
    begin
        -- Generate the SQL for the dynamic report
        l_result := 
                 'select '''' as 1 '||
                 '      , '''' as 2 '||
                ' from dual '|| 
                ' where 1 = 1' ;
            return l_result;
    exception 
        when others then 
            -- log error
            l_result := 'select ''One error has occured'' as Error '||
                        '       ,'''||sqlerrm||''' as Error Message '||
                        ' from dual';
            return l_result;
    end get_dr_query;
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
    )return varchar2
    is
        l_result varchar2(32767);
    begin
        -- if it's a spc
        if p_spc_ind = 1 then
            -- Generate the SQL for spc
            l_result := 
                'select spc_tool.get_description_lang ( p_spc_id  => t1.id '||
                '                                     , p_lang    => '''||p_lang||''') ||'' [''||spc_code||'']''as display'||
                '     , to_char(id) as return'|| 
                'from spc_definition t1'||
                'where ref_type_id = '''||p_ref_type_id||''' ';
        else
            -- Generate the SQL for column
            l_result := 
                'select  t1.column_name as display, t1.column_name as return'|| 
                'from user_tab_columns t1'||
                'join spc_ref_type t2'||
                'on t1.table_name = t2.table_name'||
                'and  t2.id = '''||p_ref_type_id||''' ';
        end if;
        -- return the SQL
        return l_result;          
    exception 
        when others then 
            -- log error
            l_result := 'select ''One error has occured'' as Error '||
                        '       ,'''||sqlerrm||''' as Error Message '||
                        ' from dual';
            return l_result;
    end get_col_val_query;
     
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
      ) return varchar2
    is
      l_return_name spc_report_lang.report_name%type;
      l_return_det  spc_report_lang.detail%type;
    begin
        -- Get the report name or detail in the given language
        if p_value = 'REPORT_NAME' then
            select report_name
            into l_return_name
            from spc_report_lang t1
            join spc_lang t2
            on t1.report_lang_id = t2.id
            where (t2.lang_code = p_lang
                  or p_lang is null
                  and t2.default_lang_ind = 1)
            and   t1.report_id = p_report_id;
            return l_return_name;
        else
            select detail
            into l_return_det
            from spc_report_lang t1
            join spc_lang t2
            on t1.report_lang_id = t2.id
            where (t2.lang_code = p_lang
                  or p_lang is null
                  and t2.default_lang_ind = 1)
            and   t1.report_id = p_report_id;
            return l_return_det;
        end if;

        if l_return_name is null and l_return_det is null then 
            return null;
        end if;
    exception 
        when no_data_found then
            -- log error
            return 'No description found for this '||p_value||' in this language';
        when others then 
            -- log error
            return 'One error has occured: '||sqlerrm;
    end get_description_lang;

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
      ) return varchar2
    is
      l_return spc_report_detail_lang.label_name%type;
    begin
        -- Get the report name or detail in the given language
        select label_name
        into l_return
        from spc_report_detail_lang t1
        join spc_lang t2
        on t1.report_lang_id = t2.id
        where (t2.lang_code = p_lang
                or p_lang is null
                and t2.default_lang_ind = 1)
        and   t1.report_detail_id = p_detail_id;

        return l_return;

    exception 
        when no_data_found then
            -- log error
            return 'No description found for this label in this language';
        when others then 
            -- log error
            return 'One error has occured: '||sqlerrm;
    end get_label_name_lang;



END SPC_DYNAMIC_REPORT;
