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
   as pragma autonomous_transaction;
   begin
      --TODO : implement insert or call insum_debug
      insert into flw_app_log(log_date, log_type, message, ora_sqlcode, oral_sqlerrm, error_backtrace)
      values(sysdate, p_message_type, p_message, null, null, dbms_utility.format_error_backtrace);

      commit;
   end log;

   /*
      function to return percent completion flow
   */ 
   function get_percent_completion(p_flow_id number) return number is
   l_percent        number;
   l_nb_steps       number;
   l_current_step   number;
   l_nb_step_cmp    number;
   l_flow_type_id   number;
   begin
    -- check if request was completed or cancled

    -- get flow type id for this process
    select flw_type_id 
    into   l_flow_type_id
    from   flw_process 
    where  id = p_flow_id;

    -- get the total number of the steps for this flow type
    select count(1)
    into   l_nb_steps
    from   flw_type_step
    where  flw_type_id = l_flow_type_id;

    -- get the current flow sequence
    select step_number
    into   l_current_step
    from   flw_type_step
    where  id in (select current_flw_step_id from flw_process where id = p_flow_id);

    -- get number of completed steps
    select count(1)
    into   l_nb_step_cmp
    from   flw_type_step
    where  flw_type_id =  l_flow_type_id
    and    step_number <= l_current_step;

    -- calculate the percent
    if l_nb_step_cmp is not null and l_nb_steps !=0 then RETURN TRUNC((l_nb_step_cmp/l_nb_steps) * 100,0);
                else   RETURN 0; end if; -- prevent issue div by 0

    return l_percent;
   exception
    when others then return -1;
   end get_percent_completion;

end flw_util;