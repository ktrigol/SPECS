create or replace PACKAGE "FLW_NOTIF_TOOL" AS 
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
    type r_attachment is record (file_name varchar2(200), mime_type varchar2(200), blob_content blob);
    type t_attachments is table of r_attachment index by binary_integer;
    type rt_notification is record ( notif_code flw_notification.notif_code%type
                                   , notif_from flw_notification.notif_from%type
                                   , notif_to flw_notification.notif_to%type
                                   , plsql_code flw_notification.plsql_code%type
                                   , subject flw_notification_lang.subject%type
                                   , detail flw_notification_lang.detail%type
    );
    type t_notification is table of rt_notification index by binary_integer;
   
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
    );
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
    ) return rt_notification;
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
    );
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
        @ p_attachments NULL            Table containing the list of attachments FLW_NOTIF_TOOL.t_attachments type
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
    );
    
END FLW_NOTIF_TOOL;
