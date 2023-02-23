create or replace PACKAGE "AOP_REPORT_SPC" as
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
                       , p_lang         in spc_lang.lang_code%type default null
    ) return clob;

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
                               , p_lang         in spc_lang.lang_code%type default null
                               , p_intern_id    in demo_stagiaire.id%type default null
    ) return clob;


end AOP_REPORT_SPC;