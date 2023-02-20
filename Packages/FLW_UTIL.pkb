create or replace package body flw_util -- authid definer
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

   /*
   get application language
   @returns : application language ID
   */
   function get_language_id return number
   as
   begin 
      return to_number(apex_util.get_session_state('AI_LANGUAGE_ID'));
   end get_language_id;

   /*
   message to return when value is not found in any language 
   @returns : error message
   */
   function get_missing_language return varchar2 deterministic
   as
   begin
      return flw_util.k_no_language;
   end get_missing_language;


   /*
   wrapper that saves a message in a log table (can be used for error or any message)
   */
   procedure log (
      p_message       in clob default null,
      p_message_type  in varchar2 default 'ERROR'
   )
   as
   begin
      --TODO : implement insert or call insum_debug
      insert into flw_app_log(log_date, log_type, message, ora_sqlcode, oral_sqlerrm, error_backtrace)
      values(sysdate, p_message_type, p_message, null, null, dbms_utility.format_error_backtrace);
   end log;

end flw_util;