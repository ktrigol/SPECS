create or replace PACKAGE "OBJ_FILE_PKG" AS 

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
      ) return varchar2;

END OBJ_FILE_PKG;

