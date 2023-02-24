create or replace package flw_util -- authid definer
/*
   Copyright 203 Insum Solutions
   Author: Henrick Maury
   Overview:
   Provide utilities for flow mecanism
   Requirements
   * APEX is installed (apex_debug is available)
   * Package is executed from within an APEX application
     
   If APEX is not installed go to apex.oracle.com for instructions.
   If you do not have a workspace created, have your DBA run this code to
   create a single workspace named "insum_debug" to be used with this utility.
   <provide code example to use workspace API>
   Modification History
  *------------------------------------------------------------------* 
  | Date        | Who                | What                          |
  *------------------------------------------------------------------*
   2023-02-14   Henrick Maury        XXXXXXXXXXXXX
  *------------------------------------------------------------------*
*/ is
   version constant varchar2(10) := '0.0.1';
   --
   k_no_language           constant varchar2(50) := 'No value in current language';
   /*
      get application language
      @returns : application language ID based on APEX application item
   */
   function get_language_id return number;
   /*
      message to return when value is not found in any language 
      @returns : error message
   */
   function get_missing_language return varchar2 deterministic;
   /*
      procedure used to save an error message in a log table
   */
   procedure log (
      p_message       in clob default null,
      p_message_type  in varchar2 default 'ERROR'
   );
   /*
      function to return percent completion flow
   */ 
   function get_percent_completion(p_flow_id number) return number;
end flw_util;
