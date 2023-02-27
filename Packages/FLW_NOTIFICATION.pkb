create or replace PACKAGE BODY "FLW_NOTIF_TOOL" AS
/* 
   Copyright 203 Insum Solutions 
   Author: Kael Trigo 
   Overview: 
 
   Package in charge of notifications. 
 
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
    /*type r_attachment is record (file_name varchar2(200), mime_type varchar2(200), blob_content blob);
    type t_attachments is table of r_attachment index by binary_integer;
    type rt_notification is record ( notif_code flw_notification.notif_code%type
                                   , notif_from flw_notification.notif_from%type
                                   , notif_to flw_notification.notif_to%type
                                   , plsql_code flw_notification.plsql_code%type
                                   , subject flw_notification_lang.subject%type
                                   , detail flw_notification_lang.detail%type
    );
    type t_notification is table of rt_notification index by binary_integer;*/
   
    /************************************************************************ 
    -------------------------------------------------------------------------  
    Procedure Description: Replace the placeholders in the content with the values from the JSON object.
    Parameters:   
        @ p_placeholders      NOT NULL        JSON object containing the values for the placeholders  
        ex:
            declare
               l_id number := :1; -- Bind variable containing the object id (p_object_id)
               l_placeholders clob;
            begin
               select 
                  json_object(
                     key 'emp_name' value name,
                     key 'emp_lastname' value lastname,
                     key 'emp_birthdate' value to_char(birthdate, 'DD/MM/YYYY') 
                  )
                  into l_placeholders
               from emp
               where id = l_id;
               
               :2 := l_placeholders; --  JSON object return
            end;
    Out: 
        @ p_content            NOT NULL        Content with the placeholders replaced by the values from the JSON object.
    ------------------------------------------------------------------------- 
    */

    procedure replace_placeholders( p_placeholders in json_object_t
                                  , p_content in out varchar2 
    )
    is
        l_keys      json_key_list;
        l_value_vc2 varchar2(4000);
    begin
        -- Parse and replace placeholders
        l_keys := p_placeholders.get_Keys();

        for i in 1..l_keys.count()
        loop
          l_value_vc2 := p_placeholders.get_String(l_keys(i));
          p_content := regexp_replace(p_content, '#' || upper(l_keys(i)) ||'#', l_value_vc2);
        end loop;
      
    end replace_placeholders;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the notification record for the given notification code.
    Return: record type of FLW_NOTIFICATION
    Parameters: 
        @ p_notif_code  NOT NULL        Notification code existing in the FLW_NOTIFICATION table
    -------------------------------------------------------------------------
    */

    function get_notification( p_notif_code in varchar2
                             , p_lang in varchar2 default null
    ) return rt_notification
    is
        r_notification rt_notification; --t_notification%rowtype;
    begin
        select t1.notif_code, t1.notif_from, t1.notif_to, t1.plsql_code, t2.subject, t2.detail
        into r_notification
        from flw_notification t1
        join flw_notification_lang t2 
        on t1.id = t2.notif_id
        join spc_lang t3
        on t2.lang_id = t3.id
        where t1.notif_code = p_notif_code
        and (t3.lang_code = p_lang 
            or p_lang is null
            and t3.default_lang_ind = 1);

        return r_notification;
    end get_notification;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Procedure Description: Send a notification
    Parameters: 
        @ p_notif_code  NOT NULL        Notification code existing in the FLW_NOTIFICATION table
        @ p_object_id   NOT NULL        Id of the object on which the placeholders is based
        @ p_to          NULL            Recipient(s)
        @ p_cc          NULL            Recipient(s) in copy
        @ p_bcc         NULL            Recipient(s) in hidden copy
        @ p_replyto     NULL            Email used when the recipient chooses to reply (default sender)
        @ p_subject     NULL            Email subject
        @ p_attachments NULL            Table containing the list of attachments FLW_NOTIF_TOOL.t_attachments type
        @ p_immediate   NULL            Indicates whether we send the email immediately
        @ p_lang        NULL            Language in which the specificites will be shown 
    Out:
        @ out_error     NULL            Error code
        @ out_error_msg NULL            Error message
    -------------------------------------------------------------------------
    */

    procedure send_notification( p_notif_code  in varchar2
                               , p_ref_id      in number
                               , p_to          in varchar2 default null
                               , p_cc          in varchar2 default null
                               , p_bcc         in varchar2 default null
                               , p_replyto     in varchar2 default null
                               , p_subject     in varchar2 default null
                               , p_attachments in FLW_NOTIF_TOOL.t_attachments default cast(null as FLW_NOTIF_TOOL.t_attachments)
                               , p_immediate   in boolean default false
                               , p_lang        in varchar2 default null
                               , out_error     out varchar2
                               , out_error_msg out varchar2
    )
    is
        l_notification  rt_notification; --t_notification%rowtype;
        l_placeholders  clob;
        l_subject       clob;
        l_body_html     clob;
    begin
        -- Get notification
        l_notification := FLW_NOTIF_TOOL.get_notification( p_notif_code => p_notif_code, p_lang => p_lang);
        
        -- Check if recipients are defined
        if p_to is null and l_notification.notif_to is null and p_cc is null and p_bcc is null then
          --insum_debug.log_warn('No destination where to send notification');
          return;
        end if;

        -- Get placeholders
        execute immediate l_notification.plsql_code using in p_ref_id, out l_placeholders;

        -- Get subject
        l_subject := l_notification.subject;
        FLW_NOTIF_TOOL.replace_placeholders( p_placeholders => json_object_t(l_placeholders)
                                           , p_content      => l_subject
        );

        -- Get body
        l_body_html := l_notification.detail;
        FLW_NOTIF_TOOL.replace_placeholders( p_placeholders => json_object_t(l_placeholders)
                                           , p_content      => l_body_html
        );

        -- Replace specificites
          -- Replace specificites in subject
          for sub in (SELECT distinct trim(regexp_substr(to_char(l_subject), '#[^#]+#', 1, LEVEL)) as spc_code
                      FROM dual
                      CONNECT BY LEVEL <= regexp_count(to_char(l_subject), '#[^#]+#'))
          loop
              l_subject := REGEXP_REPLACE (  l_subject      -- String
                                          ,  sub.spc_code   -- Substitution variable for specificities
                                          ,  spc_tool.get_value_spc( p_spc_code  => replace(sub.spc_code,'#','')
                                                                   , p_ref_id    => p_ref_id
                                                                   , p_lang      => p_lang)
              );
          end loop;

          -- Replace specificites in body
          for sub in (SELECT distinct  trim(regexp_substr(to_char(l_body_html), '#[^#]+#', 1, LEVEL)) as spc_code
                      FROM dual
                      CONNECT BY LEVEL <= regexp_count(to_char(l_body_html), '#[^#]+#'))
          loop
              l_body_html := REGEXP_REPLACE (  l_body_html    -- String
                                            ,  sub.spc_code   -- Substitution variable for specificities
                                            ,  spc_tool.get_value_spc( p_spc_code  => replace(sub.spc_code,'#','')
                                                                     , p_ref_id    => p_ref_id
                                                                     , p_lang      => p_lang)
              );
          end loop;  
        
        FLW_NOTIF_TOOL.send_mail( p_from => l_notification.notif_from
                                , p_to => coalesce(p_to, l_notification.notif_to)
                                , p_cc => p_cc
                                , p_bcc => p_bcc
                                , p_replyto => p_replyto
                                , p_subject => l_subject
                                , p_body => empty_clob()
                                , p_body_html => l_body_html
                                , p_attachments => p_attachments
                                , p_immediate => p_immediate
        );
    exception 
          when others then 
            flw_util.log('An error occured');
            out_error := 'ERROR';
            out_error_msg := sqlerrm;
              --raise_application_error(-20001,dbms_utility.format_error_backtrace);*/
    end send_notification;

   /************************************************************************
    ------------------------------------------------------------------------- 
    Procedure Description: Send an email
    Parameters: 
        @ p_from        NULL            Sender
        @ p_to          NULL            Recipient(s)
        @ p_cc          NULL            Recipient(s) in copy
        @ p_bcc         NULL            Recipient(s) in hidden copy
        @ p_replyto     NULL            Email used when the recipient chooses to reply (default sender)
        @ p_subject     NULL            Email subject
        @ p_body        NULL            Email body
        @ p_body_html   NULL            Email body in HTML format
        @ p_attachments NULL            Table containing the list of attachments cf. FLW_NOTIF_TOOL.t_attachments type
        @ p_immediate   NULL            Indicates whether we send the email immediately 
    -------------------------------------------------------------------------
    */

    procedure send_mail( p_from in varchar2 default null
                       , p_to in varchar2
                       , p_cc in varchar2 default null
                       , p_bcc in varchar2 default null
                       , p_replyto in varchar2 default null
                       , p_subject in varchar2
                       , p_body in clob
                       , p_body_html in clob
                       , p_attachments in FLW_NOTIF_TOOL.t_attachments default cast(null as FLW_NOTIF_TOOL.t_attachments)
                       , p_immediate boolean default false
    )
    is
        l_mail_id number;
        l_session number := v('APP_SESSION');
        l_workspace_id number;
    begin
      -- apex_mail need security group to work properly
      if l_session is null then
        select max(workspace_id) 
        into l_workspace_id 
        from apex_applications; 

        apex_util.set_security_group_id (p_security_group_id => l_workspace_id);
      end if;
      -- Send mail using apex_mail
      l_mail_id := apex_mail.send( p_to        => p_to
                                 , p_from      => p_from
                                 , p_body      => p_body
                                 , p_body_html => p_body_html
                                 , p_subj      => p_subject
                                 , p_cc        => p_cc
                                 , p_bcc       => p_bcc
                                 , p_replyto  => p_replyto
      );

      -- add attachments
      for i in 1..p_attachments.count()
      loop
        apex_mail.add_attachment( p_mail_id => l_mail_id
                                , p_attachment => p_attachments(i).blob_content
                                , p_filename   => p_attachments(i).file_name
                                , p_mime_type  => p_attachments(i).mime_type
        );
      end loop;

      -- push queue if needed
      if p_immediate then
        apex_mail.push_queue;
      end if;

    end send_mail;

END FLW_NOTIF_TOOL;