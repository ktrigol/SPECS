------------------------------
-- Flow Datamodel (FLW)
------------------------------

flw_role -- insum security implementation
    id num /pk -- primary key
    name vc255
    description vc4000

flw_user -- insum security implementation
    id num /pk -- primary key
    user_name	vc500
    user_source	vc4000
    email_address	vc2000
    first_name	vc256
    last_name	vc256
    full_name	vc512
    attribute1	vc4000
    attribute2	vc4000
    attribute3	vc4000
    attribute4	vc4000
    attribute5	vc4000
    attribute6	vc4000
    attribute7	vc4000
    attribute8	vc4000
    attribute9	vc4000
    attribute10	vc4000
    attribute11	vc4000
    attribute12	vc4000
    attribute13	vc4000
    attribute14	vc4000
    attribute15	vc4000
    attribute16	vc4000
    attribute17	vc4000
    attribute18	vc4000
    attribute19	vc4000
    attribute20	vc4000
    attribute21	vc4000
    attribute22	vc4000
    attribute23	vc4000
    attribute24	vc4000
    attribute25	vc4000
    attribute26	vc4000
    attribute27	vc4000
    attribute28	vc4000
    attribute29	vc4000
    attribute30	vc4000
    response_data	clob
    --password	raw /nn
    ind_password_changed	number

flw_role_user
    id num /pk -- primary key
    role_id num /fk flw_role(id) -- references the role ID in role table
    user_id num /fk flw_user(id) -- references the user ID in user table

flw_type /auditcols
    id num /pk -- primary key
    --description vc500 -- flow type description - when only one language is used by application
    --ref_id num /nn -- unique identifier for the entity linked to this flow
    --trigger_spc_ids vc4000 : to be done later on
    priority num /default 1 /nn -- priority between flows
    ind_active num  /nn /check 0,1 -- flag indicating if flow is active or not active
    spc_ref_type_id num /fk spc_ref_type(id) -- references the reference type ID in spc_ref_type table
    -- TODO /default 1



--REF_TYPE_ID num /nn -- spc definition
/*
    --TODO : add foregin key spc_definition.ref_id > spc_ref_type.id
    KAEL
    spc_ref_type
        id num /pk -- primary key
        table_name vc500 /nn
        /unique table_name
*/

flw_type_lang /auditcols
    id num /pk -- primary key
    flw_type_id num /fk flw_type(id) /nn -- references the flow type ID in flw_type table
    spc_lang_id num /fk spc_lang(id) /nn -- references the language ID in spc_lang table
    type_desc vc500 /nn -- flow description
    /unique flw_type_id, spc_lang_id

flw_type_step /auditcols
    id num /pk -- primary key
    flw_type_id num /fk flw_type(id) /nn -- references the flow type ID in flw_type table
    --> GROUP DEF - ID : 
    --> SPEC ID
    display_spc_ids vc4000 -- specificities to display for this step
    note vc4000 -- note for this step
    step_number num -- sequence of current flow
    --display_seq num /nn -- display sequence between flows

/*-- association 
flw_type_step_display_spec
    id num /pk -- primary key
    flw_type_step_id num /fk flw_type_step(id) /nn -- references the flow type step ID in flw_type_step table*/


flw_type_step_lang /auditcols -- description for button name
    id num /pk -- primary key
    flw_type_step_id num /fk flw_type_step(id) /nn -- references the flow type ID in flw_type table
    spc_lang_id num /fk spc_lang(id) /nn -- references the language ID in spc_lang table
    status vc500 /nn -- step status description
    /unique flw_type_step_id, spc_lang_id

flw_process /auditcols
    id num /pk -- primary key
    flw_type_id num /fk flw_type(id) /nn -- references the flow type ID in flw_type table
    current_flw_step_id num /fk flw_type_step(id) /nn -- step on which the process is actually, references the step ID in flw_type_step table
    description vc400
    --current_step num /nn -- step on which the process is actually
    -- champ statique ? A VOIR

flw_type_step_option /auditcols
    id num /pk              -- primary key
    flw_type_step_id num /fk flw_type_step(id) /nn -- references the step ID in flw_type_step table
    next_step_id    num     /fk flw_type_step(id) /nn -- references the next step ID in flw_type_step table
    role_ids vc4000          -- roles IDS autorized to trigger this flow (concatenated with ':')
    mandatory_spc_ids vc4000 -- specificities IDS that must have a value for this step';
    readonly_spc_ids vc4000  -- 'specificities IDS in readonly mode for this step';
    display_seq num          -- order used to display the buttons
    css_button vc500         -- APEX class to use on this button
    -- /unique flw_type_step_id, display_seq -- TODO : find a different way to check if uniq

flw_type_step_option_lang /auditcols -- description for button name
    id num /pk -- primary key
    flw_type_step_option_id num /fk flw_type_step_option(id) /nn -- references the step option ID in flw_type_step_option table
    spc_lang_id num /fk spc_lang(id) /nn -- references the language ID in spc_lang table
    button_name vc500 /nn -- button description
    /unique flw_type_step_option_id, spc_lang_id    

flw_action /auditcols
    id num /pk -- primary key
    description vc200 /nn -- action description
    code_plsql vc4000 /nn -- PL/SQL code dynamically executed
    type vc20  /nn /check NORMAL,EMPTY_VAL,SET_VAL 
    -- TODO /default NORMAL
    code_action vc20 /nn

flw_type_step_action /auditcols
    id num /pk -- primary key
    flw_type_step_option_id num /fk flw_type_step_option(id) /nn -- references the option ID in flw_type_step_option table
    flw_action_id num /fk flw_action(id) /nn -- references the action ID in flw_action table
    action_parameters vc4000 -- parameters sent to the action (PL/SLQ)
    spc_id num /fk spc_definition(id) -- specificity that will be impacted by the action (references the specificity ID in spc_definition table)
    role_id num -- action will be executed for all users having this role
    user_id num -- action will be executed for this user only

flw_history /auditcols
    id num /pk -- primary key
    flw_process_id num /nn /fk flw_process(id) -- references the process ID in flw_process table
    flw_type_step_option_id num /fk flw_type_step_option(id) /nn -- references the option ID in flw_type_step_option table
    action_name vc500 /nn -- description of action executed at that time
    note    vc4000  -- history note 
    executed_by vc255 /nn -- audit : user who moved the flow
    executed_date date /nn -- audit : date on which user moved the flow

flw_history_det /auditcols
    id num /pk -- primary key
    flw_history_id num /fk flw_history(id) /nn -- references the history ID in flw_history table
    field_description	vc100  -- field name for which value has changed
    value_before	vc4000  -- value before moving the flow
    value_after	vc4000 -- value after moving the flow
    spc_id num /fk spc_definition(id) -- references the specificity ID in spc_definition table

flw_app_log /auditcols
    id num /pk -- primary key
    log_date date /nn -- date of log
    log_type vc10 /nn /check 'ERROR,INFO'
    message clob -- custom message
    ora_sqlcode num -- sql code error
    oral_sqlerrm vc4000 -- sql error message
    error_backtrace vc4000 -- backtrace

    
    
