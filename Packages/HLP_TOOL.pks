create or replace PACKAGE "HLP_TOOL" AS 

/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:

   Package of the tools required for the help text module.

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
    Procedure Description: lookup the help text on the given language.
    Parameters:   
        @ p_app_id      NOT NULL        Application id value.
        @ p_page_id     NOT NULL        Page id value.
        @ p_lang        NOT             Language id value.
    out:
        @ out_title     NULL            Title value.
        @ out_text      NULL            Text value.
    ------------------------------------------------------------------------- 
    */ 

    procedure get_help_desc ( 
        p_app_id      in number
      , p_page_id     in number
      , p_lang        varchar2 default null
      , out_title     out varchar2
      , out_text      out varchar2
      );

    /************************************************************************ 
    -------------------------------------------------------------------------  
    Function Description: returns de title of the help text on the 
                          given language.
    Return: varchar2
    Parameters:   
        @ p_ref_type    NOT NULL        Reference type id value.
        @ p_ref_id      NULL            Reference id value.
    ------------------------------------------------------------------------- 
    */ 

    function get_help_title ( 
        p_config_id   in number
      , p_lang        in varchar2 default null
      ) return varchar2;

    /************************************************************************ 
    -------------------------------------------------------------------------  
    Function Description: returns de text of the help text on the 
                          given language.
    Return: clob
    Parameters:   
        @ p_ref_type    NOT NULL        Reference type id value.
        @ p_ref_id      NULL            Reference id value.
    ------------------------------------------------------------------------- 
    */ 

    function get_help_text ( 
        p_config_id   in number
      , p_lang        in varchar2 default null
      ) return clob;

END HLP_TOOL;

