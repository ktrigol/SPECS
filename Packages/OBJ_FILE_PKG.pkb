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
        @ p_ref_type    NOT NULL        Reference type id value.
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
                 '     , sys.dbms_lob.getlength("OBJECT") as OBJECT' ||
                 '     , sys.dbms_lob.getlength("OBJECT") as IMAGE' ||
                 '     , sys.dbms_lob.getlength("OBJECT") as PREVIEW' ||
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

    /************************************************************************ 
    -------------------------------------------------------------------------  
    Procedure Description: Inserts a new object file into the database.
    Return: SQL 
    Parameters:   
        @ p_ref_type_id NOT NULL        Reference type id value.
        @ p_ref_id      NULL            Reference id value.
        @ p_collection  NOT NULL        Collection name.
    ------------------------------------------------------------------------- 
    */ 

    procedure insert_object_dz ( p_ref_type_id     in varchar2 
                               , p_ref_id          in number
                               , p_collection      in varchar2
    )is 
      -- Cursor
      cursor c_file ( p_collection  in varchar2)is 
      select  c001    as filename,
              c002    as mime_type,
              d001    as date_created,
              n001    as file_id,
              blob001 as blob_content
      from apex_collections
      where collection_name = p_collection;
    begin
      -- Insert the files into the database.
      for file in c_file (p_collection)
      loop
        insert into obj_file (ref_type_id, ref_id, file_name, mime_type, created, object, file_size)
        values ( p_ref_type_id
               , p_ref_id
               , file.filename
               , file.mime_type
               , file.date_created
               , file.blob_content
               , dbms_lob.getlength(file.blob_content)
               );
      end loop;

      -- Truncate the collection.
      apex_collection.truncate_collection(p_collection_name => p_collection);

    end insert_object_dz;

    /************************************************************************ 
    -------------------------------------------------------------------------  
    Procedure Description: deletes an object file from the database.
    Parameters:   
        @ p_obj_id      NOT NULL        Object id value.  
    ------------------------------------------------------------------------- 
    */ 

    procedure d_object_dz ( p_obj_id     in obj_file.id%type
    )is 
    begin
      -- Delete the file from the database.
      delete from obj_file
      where id = p_obj_id;
      commit;
    end d_object_dz;
END OBJ_FILE_PKG;
