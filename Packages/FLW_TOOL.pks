create or replace package flw_tool -- authid definer
/*
   Copyright 203 Insum Solutions
   Author: Henrick Maury
   Overview:
   Provide flow mecanism to handle dynamic states for a transaction.
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
   2023-02-08   Henrick Maury        XXXXXXXXXXXXX
  *------------------------------------------------------------------*
*/ is
   version constant varchar2(10) := '0.0.1';
   --
   k_flow_reference        constant varchar2(3) := 'FLW';
   -- flow action types 
   k_action_normal         constant varchar2(50) := 'NORMAL';
   k_action_empty          constant varchar2(50) := 'EMPTY_VAL';
   k_action_set            constant varchar2(50) := 'SET_VAL';
   /* Data structures for loading parameter values */
   /*type rec_param is record (
      name   varchar2(200),
      value  varchar2(32767)
   );
   type tab_param is
      table of rec_param;*/
   /* added for logger compatibility but NOT used as default parameter */
   /*gc_empty_tab_param tab_param;*/
   /* Used to return generated usage code */
   /*type lines_t is
      table of varchar2(200);*/
   /* Compatibility with Logger API */
   /*g_off constant number := 0;
   g_apex_name constant varchar2(30) := 'APEX';*/
   /* get all columns for one specific row from table flw_type_step
      @p_flw_type_step_id : flow type step ID
      @returns : flow type step row
   */
   function get_flw_type_step(p_flw_type_step_id in flw_type_step.id%type) 
   return flw_type_step_v%rowtype;
   /* get all columns for one specific row from table flw_type_step_option
      @p_id : flow type step option ID
      @returns : flow type step option row
   */
   function get_flw_type_step_option(p_flw_type_step_option_id in flw_type_step_option.id%type) 
   return flw_type_step_option_v%rowtype;
   /* build flow step description with status, note
      @p_flw_type_step_id : flow type step ID
      @p_include_options_yn : include option description : button name 
      @returns : flow type step description
   */
   function get_flw_type_step_desc(
      p_flw_type_step_id   in flw_type_step.id%type,
      p_include_options_yn in varchar2 default 'N'
   ) 
   return varchar2;   
   ----------------------------------------------------------
   --------------------- PROCESSING -------------------------
   ----------------------------------------------------------
   
   /* 
      create flow definition
      @p_priority : priority between flows
      @p_ind_active : active by default
      @p_spc_ref_type_id : specificities reference type
      @p_ref_type_columns : columns to display when choosing a reference type on creation a flow
      @p_spc_group_id : specificities group definition
      @p_out_id : returns the ID of the row inserted
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure create_flow_type (
      p_priority           in  flw_type.priority%type default null,
      p_ind_active         in  flw_type.ind_active%type default 1,
      p_spc_ref_type_id    in  flw_type.spc_ref_type_id%type,
      p_ref_type_columns   in  flw_type.ref_type_columns%type default null,
      p_spc_group_id       in  flw_type.spc_group_id%type default null,
      p_out_id             out flw_type.id%type,
      p_out_status         out varchar2,
      p_out_message        out varchar2
   );
      /* 
      edit flow definition
      @p_id : flow type ID
      @p_priority : priority between flows
      @p_ind_active : active or not active
      @p_spc_ref_type_id : specificities reference type
      @p_ref_type_columns : columns to display when choosing a reference type on creation a flow
      @p_spc_group_id : specificities group definition
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure update_flow_type (
      p_id                 in  flw_type.id%type,
      p_priority           in  flw_type.priority%type,
      p_ind_active         in  flw_type.ind_active%type,
      p_spc_ref_type_id    in  flw_type.spc_ref_type_id%type,
      p_ref_type_columns   in  flw_type.ref_type_columns%type,
      p_spc_group_id       in  flw_type.spc_group_id%type,
      p_out_status         out varchar2,
      p_out_message        out varchar2
   );
   /* --TODO : and all steps inside if not already used
      delete flow definition
      @p_id : flow type ID
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure delete_flow_type (
      p_id                 in  flw_type.id%type,
      p_out_status         out varchar2,
      p_out_message        out varchar2
   );
   /* 
      create flow step
      @p_flw_type_id : flow type step ID
      @p_display_spc_ids : specificities to display at this step
      @p_note : step note
      @p_out_id : returns the ID of the row inserted
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure create_flow_step (
      p_flw_type_id        in  flw_type.id%type,
      p_display_spc_ids    in  flw_type_step.display_spc_ids%type,
      p_note               in  flw_type_step.note%type,
      p_out_id             out flw_type_step.id%type,
      p_out_status         out varchar2,
      p_out_message        out varchar2
   );   
   /* 
      edit flow step
      @p_id : flow type step ID
      @p_display_spc_ids : specificities to display at this step
      @p_note : step note
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure update_flow_step (
      p_id                 in  flw_type_step.id%type,
      p_display_spc_ids    in  flw_type_step.display_spc_ids%type,
      p_note               in  flw_type_step.note%type,
      p_out_status         out varchar2,
      p_out_message        out varchar2
   );   
   /* 
      delete flow step if not already used
      @p_id : flow type step ID
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure delete_flow_step (
      p_id                 in  flw_type_step.id%type,
      p_out_status         out varchar2,
      p_out_message        out varchar2
   );
   /* create a new option in table flw_type_step_option
      @p_flw_type_step_id : step ID
      @p_next_step_id : next step ID
      @p_role_ids : roles having access to this option or null if no restriction is needed
      @p_mandatory_spc_ids : specificities that need to have a value if this option is selected
      @p_readonly_spc_ids : specificities in readonly mode when this option is selected
      @p_css_button : css applied on button
      @p_out_id : returns the ID of the row inserted
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure create_flow_step_option (
      p_flw_type_step_id         in flw_type_step_option.flw_type_step_id%type,
      p_next_step_id             in flw_type_step_option.next_step_id%type,
      p_role_ids                 in flw_type_step_option.role_ids%type,
      p_mandatory_spc_ids        in flw_type_step_option.mandatory_spc_ids%type, 
      p_readonly_spc_ids         in flw_type_step_option.readonly_spc_ids%type, 
      p_css_button               in flw_type_step_option.css_button%type,
      p_out_id                   out flw_type_step_option.id%type,
      p_out_status               out varchar2,
      p_out_message              out varchar2
   );
   /* update an existing option in table flw_type_step_option
      @p_id : option ID
      @p_next_step_id : next step ID
      @p_role_ids : roles having access to this option or null if no restriction is needed
      @p_mandatory_spc_ids : specificities that need to have a value if this option is selected
      @p_readonly_spc_ids : specificities in readonly mode when this option is selected
      @p_css_button : css applied on button
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure update_flow_step_option (
      p_id                       in flw_type_step_option.id%type,
      p_next_step_id             in flw_type_step_option.next_step_id%type,
      p_role_ids                 in flw_type_step_option.role_ids%type,
      p_mandatory_spc_ids        in flw_type_step_option.mandatory_spc_ids%type, 
      p_readonly_spc_ids         in flw_type_step_option.readonly_spc_ids%type, 
      p_css_button               in flw_type_step_option.css_button%type,
      p_out_status               out varchar2,
      p_out_message              out varchar2
   );
  /* delete option from table flw_type_step_option
      @p_id : option ID
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   procedure delete_flow_step_option (
      p_id                       in flw_type_step_option.id%type,
      p_out_status               out varchar2,
      p_out_message              out varchar2
   );   
   -----------------------------------------------------------------------------------
   /* move flow to the next step and trigger any action (custom PL/SQL code) defined on this step
      @p_flw_process_id : flow ID
      @p_id : option selected by user (click on button)
      -- @p_next_step_id : next flow step
      @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
      @p_out_message : returns the error details when an error occured, null otherwise
   */
   -----------------------------------------------------------------------------------
   procedure move_flow_to_step(
      p_flw_process_id          flw_process.id%type,   
      --p_flw_type_step_id        flw_type_step.id%type,
      p_flw_type_step_option_id flw_type_step_option.id%type,
      --p_next_step_id        flw_type_step_option.next_step_id%type,
      p_out_additional_info     out clob,
      p_out_status              out varchar2,
      p_out_message             out varchar2
   );
   -----------------------------------------------------------------------------------
   /* send mail procedure : used to illustrate how ac action can be called at a specific step
      @p_flw_process_id : flow ID
      @p_param_1 : flow ID
      @p_param_2 : flow ID
   */
   -----------------------------------------------------------------------------------
   procedure demo_send_mail (
      p_process_id   in flw_process.id%type,
      p_role_id      in flw_role.id%type,
      p_user_id      in flw_user.id%type,
      p_other_mail   in varchar2
   );   
   -----------------------------------------------------------------------------------
   /* create flow process procedure : used to create a flow process in a defined step
      @p_flw_type_id : flow type ID
      @p_step : flow Step position
      @p_description : flow description
      @p_note : flow history note (Why the flow was created)
   */
   -----------------------------------------------------------------------------------
   function create_flow_process (
      p_flw_type_id      in flw_process.flw_type_id%type,
      p_step             in flw_process.current_flw_step_id%type,
      p_step_option_id   in flw_history.flw_type_step_option_id%type,
      p_description      in flw_process.description%type,
      p_note             in flw_history.note%type default null
   ) return number;   
   -----------------------------------------------------------------------------------
   /* sync spcs process procedure : used to sync spcs values on a flow creation
      @p_step_action_id : flow step action ID
      @p_flw_process_id_source : flow process ID source
      @p_flw_process_id_target : flow process ID target
   */
   -----------------------------------------------------------------------------------
   procedure flow_action_sync_spcs (
      p_step_action_id        in flw_type_step_action.id%type,
      p_flw_process_id_source in flw_process.id%type,
      p_flw_process_id_target in flw_process.id%type
   );
   -----------------------------------------------------------------------------------
   /* set flow history det process procedure : used to insert the history details for a flow
      @p_flow_process_id : flow process ID
      @out_status : out status
      @out_message : out message
   */
   -----------------------------------------------------------------------------------
   procedure log_history_det (
      p_flow_process_id           in flw_process.id%type,
      out_status                  out varchar2,
      out_message                 out varchar2
   );

   procedure log_process_history (
    p_flw_process_id            in flw_history.id%type,
    p_flw_type_step_option_id   in flw_type_step_option.id%type,
    p_action_name               in flw_history.action_name%type,
    p_note                      in flw_history.note%type default null,
    p_out_id                    out flw_history.id%type,
    out_status                  out varchar2,
    out_message                 out varchar2
   );
   -----------------------------------------------------------------------------------
   /* set flow history det process procedure : used to insert the history details for a flow
      @p_flow_process_id : flow process ID
      @out_status : out status
      @out_message : out message
   */
   -----------------------------------------------------------------------------------
   function get_flw_ref_id_query (
      p_flw_type_id       in flw_type.id%type
   )return varchar2;
end flw_tool;
