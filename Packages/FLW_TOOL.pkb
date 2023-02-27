create or replace package body flw_tool -- authid definer
/*
   Copyright 203 Insum Solutions

   Author: Henrick Maury


   Overview:

   Implement flow mecanism to handle dynamic states or steps for a process.

   Requirements

   * APEX is installed (apex_debug is available)

   * Package is executed from within an APEX application

   If APEX is not installed go to apex.oracle.com for instructions.

   If you do not have a workspace created, have your DBA run this code to
   create a single workspace named "insum_debug" to be used with this utility.

   <provide code example to use workspace API>

   Modification History
   Date       Who                  What
   ---------- -------------------- ---------------------------------
   2023-02-08 Henrick Maury        XXXXXXXXXXXXX

*/ is


/* get all columns for one specific row from table flw_type_step
    @p_flw_type_step_id : flow type step ID
    @returns : flow type step row
*/
function get_flw_type_step(
    p_flw_type_step_id in flw_type_step.id%type
) return flw_type_step_v%rowtype
as
    l_flw_type_step flw_type_step_v%rowtype;
begin
    select * into l_flw_type_step
    from flw_type_step_v
    where id = p_flw_type_step_id;

    return l_flw_type_step;

exception when no_data_found then
    return null;
end;

/* get all columns for one specific row from table flw_type_step_option
    @p_flw_type_step_option_id : flow type step option ID
    @returns : flow type step option row
*/
function get_flw_type_step_option(p_flw_type_step_option_id in flw_type_step_option.id%type)
   return flw_type_step_option_v%rowtype as
    l_flw_type_step_option flw_type_step_option_v%rowtype;
begin

    select * into l_flw_type_step_option
    from flw_type_step_option_v
    where id = p_flw_type_step_option_id;

    return l_flw_type_step_option;

exception when no_data_found then
    return null;
end get_flw_type_step_option;

/* build flow step description with status, note
    @p_flw_type_step_id : flow type step ID
    @p_include_options_yn : include option description : button name
    @returns : flow type step description
*/
function get_flw_type_step_desc(
    p_flw_type_step_id   in flw_type_step.id%type,
    p_include_options_yn in varchar2 default 'N'
)
return varchar2 as

    l_description flw_type_step_v.status%type;
begin

    select
        --s.step_number || ' = ' || s.status || ' ' || s.note as d
        s.status  as d
    into l_description
    from flw_type_step_v s
    where s.id = p_flw_type_step_id;

    return l_description;

exception when no_data_found then
    return null;
end get_flw_type_step_desc;




/* 
   create flow definition
   @p_priority : priority between flows
   @p_ind_active : active by default
   @p_spc_ref_type_id : specificities reference type
   @p_out_id : returns the ID of the row inserted
   @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
   @p_out_message : returns the error details when an error occured, null otherwise
*/
procedure create_flow_type (
   p_priority           in  flw_type.priority%type default null,
   p_ind_active         in  flw_type.ind_active%type default 1,
   p_spc_ref_type_id    in  flw_type.spc_ref_type_id%type,
   p_out_id             out flw_type.id%type,
   p_out_status         out varchar2,
   p_out_message        out varchar2
) as
   l_next_priority   flw_type.priority%type := p_priority;
begin
   --> get next priority
   if l_next_priority is null then
      select nvl(max(priority), 0) + 1 into l_next_priority
      from flw_type;
   end if;

   --> insert row
   insert into flw_type(priority, ind_active, spc_ref_type_id)
   values(l_next_priority, p_ind_active, p_spc_ref_type_id)
   returning id into p_out_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end create_flow_type;



/* 
   edit flow definition
   @p_id : flow type ID
   @p_priority : priority between flows
   @p_ind_active : active or not active
   @p_spc_ref_type_id : specificities reference type
   @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
   @p_out_message : returns the error details when an error occured, null otherwise
*/
procedure update_flow_type (
   p_id                 in  flw_type.id%type,
   p_priority           in  flw_type.priority%type,
   p_ind_active         in  flw_type.ind_active%type,
   p_spc_ref_type_id    in  flw_type.spc_ref_type_id%type,
   p_out_status         out varchar2,
   p_out_message        out varchar2
) as
begin

   --> insert row
   update flw_type
   set priority = p_priority, 
       ind_active = p_ind_active,
       spc_ref_type_id = p_spc_ref_type_id
   where id = p_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end update_flow_type;

/*  --TODO : and all steps inside if not already used
   delete flow definition
   @p_id : flow type ID
   @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
   @p_out_message : returns the error details when an error occured, null otherwise
*/
procedure delete_flow_type (
   p_id                 in  flw_type.id%type,
   p_out_status         out varchar2,
   p_out_message        out varchar2
) as
begin

   --> validations
   if p_id is null then
      p_out_status := 'ERROR';
      p_out_message := 'Invalid parameters';
   end if;

   --> delete language
   delete from flw_type_lang
   where flw_type_id = p_id;

   --> delete row
   delete from flw_type
   where id = p_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end delete_flow_type;


/* 
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
) as
   l_next_step_number   flw_type_step.step_number%type;
begin

   --> validations
   if p_flw_type_id is null then
      p_out_status := 'ERROR';
      p_out_message := 'Invalid parameters';
   end if;

   --> get next step number
   select nvl(max(step_number), 0) + 1 into l_next_step_number
   from flw_type_step
   where flw_type_id = p_flw_type_id;

   --> insert row
   insert into flw_type_step(flw_type_id, display_spc_ids, note, step_number)
   values(p_flw_type_id, p_display_spc_ids, p_note, l_next_step_number)
   returning id into p_out_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end create_flow_step;

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
) as
begin   

   --> validations
   if p_id is null then
      p_out_status := 'ERROR';
      p_out_message := 'Invalid parameters';
   end if;

   --> update row
   update flw_type_step
      set display_spc_ids = p_display_spc_ids, 
          note = p_note
   where id = p_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end update_flow_step;

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
) as
begin
   --> validations
   if p_id is null then
      p_out_status := 'ERROR';
      p_out_message := 'Invalid parameters';
   end if;

   --> delete language
   delete from flw_type_step_lang
   where flw_type_step_id = p_id;

   --> delete row
   delete from flw_type_step
   where id = p_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end delete_flow_step;



/* create a new option in table flw_type_step_option
   @p_flw_type_step_id : step ID
   @p_next_step_id : next step ID
   @p_role_ids : roles having access to this option or null if no restriction is needed
   @p_mandatory_spc_ids : specificities that need to have a value if this option is selected
   @p_readonly_spc_ids : specificities in readonly mode when this option is selected
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
) as
   l_next_display_seq   flw_type_step_option.display_seq%type;
begin
   --> get next display sequence
   select nvl(max(display_seq), 0) + 1 into l_next_display_seq
   from flw_type_step_option
   where flw_type_step_id = p_flw_type_step_id;

   --> insert row
   insert into flw_type_step_option(flw_type_step_id, next_step_id, role_ids, mandatory_spc_ids, readonly_spc_ids, display_seq, css_button)
   values(p_flw_type_step_id, p_next_step_id, p_role_ids, p_mandatory_spc_ids, p_readonly_spc_ids, l_next_display_seq, p_css_button)
   returning id into p_out_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end create_flow_step_option;

/* update an existing option in table flw_type_step_option
   @p_id : option ID
   @p_next_step_id : next step ID
   @p_role_ids : roles having access to this option or null if no restriction is needed
   @p_mandatory_spc_ids : specificities that need to have a value if this option is selected
   @p_readonly_spc_ids : specificities in readonly mode when this option is selected
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
) as
begin
   --> update row
   update flw_type_step_option
      set next_step_id = p_next_step_id, 
            role_ids = p_role_ids,
            mandatory_spc_ids = p_mandatory_spc_ids, 
            readonly_spc_ids = p_readonly_spc_ids,
            css_button = p_css_button
   where id = p_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end update_flow_step_option;


/* delete option from table flw_type_step_option
   @p_id : option ID
   @p_out_status : returns SUCCESS if no error or ERROR if something went wrong
   @p_out_message : returns the error details when an error occured, null otherwise
*/
procedure delete_flow_step_option (
   p_id                       in flw_type_step_option.id%type,
   p_out_status               out varchar2,
   p_out_message              out varchar2
) as
begin

   --> validations
   if p_id is null then
      p_out_status := 'ERROR';
      p_out_message := 'Invalid parameters';
   end if;

   --> clean history
   delete from flw_history
   where flw_type_step_option_id = p_id;

   --> delete language
   delete from flw_type_step_option_lang
   where flw_type_step_option_id = p_id;

   --> delete row
   delete from flw_type_step_option
   where id = p_id;

   p_out_status := 'SUCCESS';

exception when others then
   p_out_status := 'ERROR';
   p_out_message := 'An error occured ' || sqlerrm;
   flw_util.log('An error occured');
end delete_flow_step_option;










-----------------------------------------------------------------------------------
-- log l'opération effectuée sur une requête
-----------------------------------------------------------------------------------
procedure log_process_history (
    p_flw_process_id            in flw_history.id%type,
    p_flw_type_step_option_id   in flw_type_step_option.id%type,
    p_action_name               in flw_history.action_name%type,
    p_note                      in flw_history.note%type default null,
    p_out_id                    out flw_history.id%type,
    out_status                  out varchar2,
    out_message                 out varchar2
) as
begin

    --> next sequence
    --select nvl(max(id), 0) + 1 into p_out_id
    --from flw_history;

    --> create log
    insert into flw_history (
        flw_process_id,
        flw_type_step_option_id,
        action_name,
        note,
        executed_by,
        executed_date
    ) values (
        p_flw_process_id,
        p_flw_type_step_option_id,
        p_action_name,
        p_note,
        v('APP_USER'),
        sysdate
    ) returning id into p_out_id;

    out_status := 'SUCCESS';
exception when others then
    out_status := 'ERROR';
    out_message := 'Une erreur est survenue ' || sqlerrm;
    --insum_debug.log_error('An error occured ' || sqlerrm );
end log_process_history;


-----------------------------------------------------------------------------------
/* trigger action defined on this step and move flow to the next step
@p_flw_process_id : flow ID
@p_flw_type_step_id : actual flow step
@p_next_step_id : next flow step
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
) is
    l_dummy                 number;
    l_nb_params             number;
    l_params_array          apex_t_varchar2;
    l_code_plsql            flw_action.code_plsql%type;
    l_flw_type_step         flw_type_step_v%rowtype;
    l_flw_type_step_option  flw_type_step_option_v%rowtype;

    -- audit
    l_executed_date         flw_history.executed_date%type := sysdate;
    l_action_name           flw_history.action_name%type;

    -- history
    l_flow_history_id flw_history.id%type;

    -- for out parameters
    l_additional_info       clob;
    l_status                varchar2(50);
    l_message               varchar2(4000);
begin

    -- required paramters
    if p_flw_process_id is null then
        p_out_status := 'ERROR';
        p_out_message := 'Missing parameter : p_flw_process_id';
        return;
        --raise_application_error(-20001, 'Missing parameter : p_flw_process_id');
    end if;

    if p_flw_type_step_option_id is null then
        p_out_status := 'ERROR';
        p_out_message := 'Missing parameter : p_flw_type_step_option_id';
        return;
    end if;

    -- TODO : add validation
        -- next step must be the next step of the current step

    -- get step details
    l_flw_type_step_option := flw_tool.get_flw_type_step_option(p_flw_type_step_option_id => p_flw_type_step_option_id);
    l_flw_type_step := flw_tool.get_flw_type_step(p_flw_type_step_id => l_flw_type_step_option.flw_type_step_id);

    ---------------------------
    --> create history
    ---------------------------
    log_process_history(                                    --TODO : add flow_tool
        p_flw_process_id            => p_flw_process_id,
        p_flw_type_step_option_id   => p_flw_type_step_option_id,
        p_action_name               => l_flw_type_step_option.button_name,
        p_note                      => null,                               -- TODO : change this
        p_out_id                    => l_flow_history_id,
        out_status                  => l_status,
        out_message                 => l_message
    );
    if l_status is null or l_status != 'SUCCESS' then
        p_out_status := 'ERROR';
        p_out_message := l_message;
        -- TODO : insum_debug
        return;
    end if;

    -------------------------------------
    -- update to next step if any
    ------------------------------------
    if l_flw_type_step_option.next_step_id is not null then
        update flw_process
          set current_flw_step_id = l_flw_type_step_option.next_step_id
        where id = p_flw_process_id;
    -------------------------------------
    -- flow process is completed
    ------------------------------------
    else
       update flw_process
          set status = 'COMPLETED'
        where id = p_flw_process_id;
    end if;

    ------------------------------------------------------------
    -- execute PL/SQL actions defined at this step
    ------------------------------------------------------------
    for c1 in (
        select
            t2.description, t2.code_plsql, t1.action_parameters,
            regexp_count(t2.code_plsql, ':') as nb_params,
            t2.type,
            t1.spc_id,
            t2.code_action,
            t1.user_id,
            t1.role_id
        from flw_type_step_action t1
        join flw_action t2
          on t1.flw_action_id = t2.id
          and t2.code_plsql is not null
          and t1.flw_type_step_option_id = l_flw_type_step_option.id
    ) loop

        --insum_debug.log_error('c1.code_plsql => ' || c1.code_plsql );

        -- check if required parameters are passed
        if c1.nb_params > 1 then

            -- function that will set a value to specificity
            if c1.type != 'NORMAL' and c1.spc_id is null then
                raise_application_error(-20001, 'Missing action parameters');

            -- general procedure (send email)
            elsif c1.type = 'NORMAL' and c1.action_parameters is null and c1.user_id is null and c1.role_id is null then
                raise_application_error(-20001, 'Missing action parameters');
            end if;
        end if;

        -- convert parameter list in array
        if c1.type != 'NORMAL' then
            l_params_array := apex_string.split(p_str => c1.spc_id, p_sep => ':');
        else

            if c1.code_action = 'SEND_SMS' then
                l_params_array := apex_string.split(p_str => nvl(c1.role_id, -1) || ':' || nvl(c1.user_id, -1), p_sep => ':');
            elsif c1.code_action = 'SEND_MAIL' then
                l_params_array := apex_string.split(p_str => nvl(c1.role_id, -1) || ':' || nvl(c1.user_id, -1) || ':' || c1.action_parameters, p_sep => ':');
            else
                l_params_array := apex_string.split(p_str => c1.action_parameters, p_sep => ':');
            end if;
        end if;

        -- first parameter is alwasy the ID of the flow process, it is automaticaly replaced
        l_code_plsql := c1.code_plsql;
        l_code_plsql := replace(l_code_plsql, ':PARAM1', p_flw_process_id);

        -- on remplace les autres paramètres
        for i in 1..l_params_array.count loop
            l_code_plsql := replace(l_code_plsql, ':PARAM' || (i+1), '''' || rtrim(ltrim(l_params_array(i), ''''), '''') || '''');
        end loop;

        -- execute dynamique code
        l_code_plsql := 'begin ' || rtrim(l_code_plsql, ';') || '; end;';

        -- TODO : insum_debug.log_error(l_code_plsql);

        -- error handling : will be displayed in case of error
        begin
            execute immediate l_code_plsql;
        exception when others then
            l_additional_info := l_additional_info || '- "' || c1.description || '"<br/>' ;
        end ;

    end loop;

    --:P34_MESSAGE := inb_message_api.get_message('CREATE_SUCCESS') || :P34_MESSAGE;
    if l_additional_info is not null then

        -- build error message
        --:P34_MESSAGE_ERREUR := 'Fonction(s) qui ont échoué : <br/>' || l_additional_info;
        p_out_message := 'Failed Function(s) : <br/>' || l_additional_info;
    end if;

    --------------------------
    -- save error in log
    --------------------------
    if l_additional_info is not null then

        update flw_history
          set note = 'Errors(s) ' || l_additional_info
        where id = l_flow_history_id;
    end if;


    p_out_status := 'SUCCESS';
exception when others then
    p_out_status := 'ERROR';
    p_out_message := 'An error occured ' || sqlerrm;
    --TODO : insum_debug.log_error();
end move_flow_to_step;


procedure demo_send_mail (
   p_process_id   in flw_process.id%type,
   p_role_id      in flw_role.id%type,
   p_user_id      in flw_user.id%type,
   p_other_mail   in varchar2
) as
   l_subject      varchar2(100);
   l_body_html    clob;
   l_intern_id    demo_stagiaire.id%type;

   --l_message   varchar2(4000);
   l_emails       varchar2(4000);
   l_out_statut   varchar2(20);
   l_out_message  varchar2(4000);
begin

   if p_role_id is not null and p_role_id != -1 then

      -- TODO : get all users email in this role
      select 
         --listagg(u.first_name || ' ' || u.last_name || ' (' || u.email_address || ')', '<br/>') within group(order by first_name, last_name) into l_message
         listagg(u.email_address, ';') within group(order by 1) into l_emails
      from flw_role r
      join flw_role_user ru
        on ru.role_id = r.id
      join flw_user u
        on ru.user_id = u.id
      where r.id = p_role_id;

   elsif p_user_id is not null and p_user_id != -1 then

      select 
         --first_name || ' ' || last_name || ' (' || email_address || ')' into l_message
         email_address into l_emails
      from flw_user
      where id = p_user_id;

   elsif p_other_mail is not null then
      --l_message := p_other_mail;
      l_emails := p_other_mail;
   end if;

   -- execute only if we have an email
   /*if l_message is not null then
      flw_util.log(p_message => 'Sending email to ' || l_message);
   end if;*/

   /*
   --TODO : send real email
   l_body_html := 'Test';
   apex_mail.send(
        p_to        => apex_util.get_session_state('APP_USER')--'hmaury@insum.ca'
      , p_from      => 'no-reply@insum.ca'
      , p_body      => null
      , p_body_html => l_body_html
      , p_subj      => l_subject
      , p_cc        => null
      , p_bcc       => null
      , p_replyto   => null
    );*/

   --> look up for intern id
   /*begin

      select id into l_intern_id
      from demo_stagiaire
      where flw_process_id = p_process_id;

   exception when no_data_found then
      raise_application_error(-20000, 'Intern not found');
   end;*/

   flw_notif_tool.send_notification( p_notif_code  => 'FLOW_ACTION_TEMPLATE'
                                 , p_ref_id      => p_process_id
                                 , p_to          => l_emails
                                 , p_cc          => null
                                 , p_bcc         => null
                                 , p_replyto     => null
                                 , p_subject     => null
                                 --, p_attachments => 
                                 , p_immediate   => true
                                 , p_lang        => null --flw_util.get_language_id()
                                 , out_error     => l_out_statut
                                 , out_error_msg => l_out_message
   );

   apex_mail.push_queue;
   
   if l_out_statut = 'ERROR' then
      raise_application_error(-20000, l_out_message);
   end if;

end demo_send_mail;

end flw_tool;