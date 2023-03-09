create or replace package flw_modeler as
/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:
   Package in charge of creating the xml file that will be used by the plugin
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
    Function Description: Returns the complete xml file for the plugin
    Return: XML 
    Parameters:  
        @ p_spc_id    NOT NULL        ID of the specificity
        @ p_lang      NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */
    function get_xml_flow_code ( 
        p_flw_type_id in number
    ) return clob;

    /************************************************************************
    -------------------------------------------------------------------------
    Procedure Description: Generates the xml code for the substitution
    Parameters:
        @ p_flw_type_id    NOT NULL        ID of the flow type
    out:
        @ p_xml_header      NOT NULL        XML code for the header
        @ p_xml_body        NOT NULL        XML code for the body
        @ p_xml_arrow_h     NOT NULL        XML code for the arrows header
        @ p_xml_arrow_b     NOT NULL        XML code for the arrows body
    -------------------------------------------------------------------------
    */

    procedure gen_xml_substitution ( 
          p_flw_type_id     in number
        , p_xml_header      in out clob
        , p_xml_body        in out clob
        , p_xml_arrow_h     in out clob
        , p_xml_arrow_b     in out clob
    );
    
    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Generates the xml body code for the arrows (sequence flows)
    Parameters:
        @ p_from_task NOT NULL              From task number (step number)
        @ p_to_task NOT NULL                To task number (step number)
        @ p_rownum NOT NULL                 Row number
    -------------------------------------------------------------------------
    */

    function get_xml_arrow_body ( 
          p_from_task   in varchar2
        , p_to_task     in varchar2
        , p_rownum      in number
    ) return clob;
end flw_modeler;