create or replace PACKAGE BODY "OBJ_FILE_PKG" AS 

/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:

   Package in charge of BLOBs.

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
    Function Description: Generates and return the SQL for the region with the object file storage.
    Return: SQL 
    Parameters:   
        @ p_ref_type_id NOT NULL        Reference type id value.
        @ p_ref_id      NULL            Reference id value.
    ------------------------------------------------------------------------- 
    */ 

    function get_obj_query ( p_ref_type      in varchar2 
                           , p_ref_id        in number default null
      ) return varchar2
    is
        l_result varchar2(32767);
        l_ref_type_id number;
    begin
        -- Generate the SQL for the region with the object file storage (display).
        begin
          select id 
          into l_ref_type_id
          from spc_ref_type
          where upper(table_name) = upper(trim(p_ref_type));
        exception
          when no_data_found then
            l_result := 'select ''Reference type does not exist'' as Error '||
                        '       ,'''||sqlerrm||''' as Error Message '||
                        ' from dual';
            return l_result;
        end;

        l_result := 
                 'select ID '||
                 '     , FILE_NAME '||
                 '     , FILE_SIZE '||
                 '     , OBJECT' ||
                 '     , MIME_TYPE '||
                ' from OBJ_FILE '|| 
                ' where REF_TYPE_ID = '''||l_ref_type_id||''' '||
                ' and REF_ID = '''||p_ref_id||''' '||
                ' order by ID';
            return l_result;
    exception 
        when others then 
            -- log error
            l_result := 'select ''One error has occured'' as Error '||
                        '       ,'''||sqlerrm||''' as Error Message '||
                        ' from dual';
            return l_result;
    end get_obj_query;
   
END OBJ_FILE_PKG;
