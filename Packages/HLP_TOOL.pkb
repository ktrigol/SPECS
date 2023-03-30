create or replace PACKAGE BODY "HLP_TOOL" AS 

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
    Return: SQL 
    Parameters:   
        @ p_app_id      NOT NULL        Application id value.
        @ p_page_id     NOT NULL        Page id value.
        @ p_lang        NOT NULL        Language id value.
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
      )
    is
        l_ref_type_id number;
    begin
        -- Generate the SQL for the region with the object file storage (display).
        select hlp_tool.get_help_title( p_config_id   => id
                                      , p_lang        => p_lang) as title
             , hlp_tool.get_help_text( p_config_id   => id
                                      , p_lang        => p_lang) as text
        into out_title, out_text
        from hlp_config 
        where app_id = p_app_id
        and page_id = p_page_id;

    exception
        when no_data_found then 
            -- No help text for this page
            out_title := 'No help found for this page';
            out_text := 'No help found for this page';
        when others then 
            -- log error
            out_title := 'One error has ocurred please contact your administrator';
            out_text := 'One error has ocurred please contact your administrator';
    end get_help_desc;

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
      ) return varchar2
      is
        l_title   hlp_config_lang.title%type;
      begin
        -- Get the title on the given language
        select title
        into l_title
        from hlp_config_lang
        where config_id = p_config_id
        and lang_id = spc_tool.get_lang_id(p_lang_code => p_lang);

        -- If the title is null then get the page name
        if l_title is null then
            select t1.page_name
            into l_title
            from apex_application_pages t1
            join hlp_config t2
            on t2.page_id = t1.page_id
            and t2.app_id = t1.application_id
            where t2.id = p_config_id;
        end if;

        return l_title;
        
      exception 
        when others then 
          l_title := 'One error ocurred please contact your administrator';
          return l_title;
      end get_help_title;

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
      ) return clob
      is
        l_text   hlp_config_lang.text%type;
      begin
        -- Get the text on the given language
        select text
        into l_text
        from hlp_config_lang
        where config_id = p_config_id
        and lang_id = spc_tool.get_lang_id(p_lang_code => p_lang);

        return l_text;
        
      exception 
        when others then 
          l_text := 'One error ocurred please contact your administrator';
          return l_text;
      end get_help_text;

END HLP_TOOL;
