create or replace PACKAGE BODY "AOP_REPORT_SPC" as
/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:

   Package in charge of printing the specificities of a given object

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
    Function Description: Loops and prints all specificities of a given object
    Return: Text 
    Parameters:  
        @ p_ref_type_id  NOT NULL        ID of the reference type
        @ p_ref_id       NOT NULL        ID of the reference
        @ p_lang         NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */
    function print_spc ( p_ref_type_id  in spc_ref_type.id%type 
                       , p_ref_id       in spc_data.ref_id%type
                       , p_langue       in spc_lang.lang_code%type default null
    ) return clob
   is
      -- Variables
      l_return clob;
      l_template blob;
      l_registre_blob blob;
   
      -- Cursor
      cursor c_spc (p_ref_type_id  in spc_ref_type.id%type 
                     ,p_ref_id       in spc_data.ref_id%type
                     ,p_langue       in spc_lang.lang_code%type) IS
      select spc_tool.get_description_lang ( p_spc_id => t1.spc_id
                                          , p_lang   => p_langue) as label
            , t1.value as value
      from spc_data t1
      join spc_definition t2 
      on t1.spc_id = t2.id 
      where /*t2.ref_type_id = p_ref_type_id
      and*/   t1.ref_id = p_ref_id
      and t2.print_ind = 1;


   begin

      --

      apex_json.initialize_clob_output;
      apex_json.open_array();  -- OPEN ARRAY MAIN
      apex_json.open_object(); -- OPEN OBJECT MAIN
      apex_json.write('filename','test');

      apex_json.open_array('data'); -- OPEN ARRAY DATA
      apex_json.open_object();      -- OPEN OBJECT DATA

         apex_json.open_array('SPEC'); -- OPEN ARRAY SPEC

         for rec in c_spc (p_ref_type_id => p_ref_type_id
                           ,p_ref_id      => p_ref_id
                           ,p_langue      => p_langue) 
         loop
            apex_json.open_object();   -- OPEN OBJECT SPEC
            apex_json.write('NAME', rec.label);
            apex_json.write('VALUE', rec.value);
            apex_json.close_object();  -- CLOSE OBJECT SPEC
         end loop;

         apex_json.close_array();      -- CLOSE ARRAY SPEC

      apex_json.close_object();  -- CLOSE OBJECT DATA
      apex_json.close_array();   -- CLOSE ARRAY DATA

      apex_json.close_object(); -- CLOSE OBJECT MAIN
      apex_json.close_array();  -- CLOSE ARRAY MAIN
               
      l_return := apex_json.get_clob_output;
      apex_json.free_output;
         
      return l_return;
      
   end print_spc;



   /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Loops and prints for specified specificities of a given object
    Return: Text 
    Parameters:  
        @ p_ref_type_id  NOT NULL        ID of the reference type
        @ p_ref_id       NOT NULL        ID of the reference
        @ p_lang         NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */
    function print_spc_by_code ( p_ref_type_id  in spc_ref_type.id%type 
                               , p_ref_id       in spc_data.ref_id%type
                               , p_langue       in spc_lang.lang_code%type default null
    ) return clob
   is
      -- Variables
      l_return clob;
      l_template blob;
      l_registre_blob blob;
   
      -- Cursor
      cursor c_spc (p_ref_type_id  in spc_ref_type.id%type 
                     ,p_ref_id       in spc_data.ref_id%type
                     ,p_langue       in spc_lang.lang_code%type) IS
      select t1.value as value
         , t2.spc_code as spc_code
      from spc_data t1
      join spc_definition t2 
      on t1.spc_id = t2.id 
      where /*t2.ref_type_id = p_ref_type_id
      and*/   t1.ref_id = p_ref_id
      and t2.print_ind = 1;


   begin
      -- format the output
      apex_json.initialize_clob_output;
      apex_json.open_array();    -- OPEN ARRAY MAIN
      apex_json.open_object();   -- OPEN OBJECT MAIN
      apex_json.write('filename','test'); -- FILENAME

      apex_json.open_array('data'); -- OPEN ARRAY DATA
      apex_json.open_object();      -- OPEN OBJECT DATA

         for rec in c_spc ( p_ref_type_id => p_ref_type_id
                          , p_ref_id      => p_ref_id
                          , p_langue      => p_langue) 
         loop
            -- Replace the item code by the item value
            apex_json.write(rec.spc_code , rec.value);
         end loop;


      apex_json.close_object();     -- CLOSE OBJECT DATA
      apex_json.close_array();      -- CLOSE ARRAY DATA

      apex_json.close_object(); -- CLOSE OBJECT MAIN
      apex_json.close_array();  -- CLOSE ARRAY MAIN

      -- Get the output  
      l_return := apex_json.get_clob_output;
      apex_json.free_output;

      -- Return the output 
      return l_return;
      
   end print_spc_by_code; 

end AOP_REPORT_SPC;