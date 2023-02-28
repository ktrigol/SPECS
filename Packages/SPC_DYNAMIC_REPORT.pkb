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
     
END SPC_DYNAMIC_REPORT; 
