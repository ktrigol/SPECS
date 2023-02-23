create or replace PACKAGE "SPC_DISPLAY_HANDLER" AS 

/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:

   Package in charge of manipulating the visualization for the specificities.

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
    
 /* Global Constant */
    k_type_text               constant varchar2(50) := 'TEXT'; 
    k_type_date               constant varchar2(50) := 'DATE'; 
    k_type_hour               constant varchar2(50) := 'HOUR'; 
    k_type_list               constant varchar2(50) := 'LIST'; 
    k_type_text_area          constant varchar2(50) := 'TEXTAREA';
    k_type_title              constant varchar2(50) := 'TITLE'; 

  
    /************************************************************************
    ------------------------------------------------------------------------- 
    Fonction Description: Generates and return the SQL for the region of the Plug-in
    Return: SQL
    Parameters:  
        @ p_app_id      NOT NULL        Apex Application id value. 
        @ p_page_id     NOT NULL        Apex Page id value.
        @ p_group_id    NULL            ID of the group of specificities, null for all spec for the app and page.
    -------------------------------------------------------------------------
    */
    function get_spc_query( p_app_id      in number
                          , p_page_id     in number
                          , p_group_id    in number 
    ) return varchar2;
    
    /************************************************************************ 
    -------------------------------------------------------------------------  
    Procedure Description: Generates and inserts into the collection the HTML for the specificities  
    Parameters:   
        @ p_app_id      NOT NULL        Apex Application id value  
        @ p_page_id     NOT NULL        Apex Page id value  
        @ p_ref_type_id NULL            ID of the type of object the specificities are related to 
        @ p_red_id      NULL            ID of the object the specificites are related to  
        @ p_exc_ids     NULL            IDs of the specificities to exclude from the list, separated by colon (:)
        @ p_lang        NULL            Language in which the specificites will be shown  
    ------------------------------------------------------------------------- 
    */ 
    procedure init_spc( p_app_id      in number 
                      , p_page_id     in number 
                      , p_ref_type_id in number 
                      , p_ref_id      in number
                      , p_exc_ids     in varchar2 
                      , p_lang        in varchar2 default null
    );

    /************************************************************************ 
    -------------------------------------------------------------------------  
    Function Description: Generates and return the HTML for the items of the Plug-in 
    Return: HTML 
    Parameters:   
        @ p_type_item       NOT NULL        Type of item defined on the table SPC_DEFINITION (TEXT,DATE,LIST,etc..)  
        @ p_value           NOT NULL        To set the current value or the default value of a specificity on the construction of the html 
        @ p_mandatory_ind   NULL            To indicate if the attribute mandatory should be added as an attribute of the item 
        @ p_read_only_ind   NULL            To indicate if the attribute read-only should be added as an attribute of the item
        @ p_spc_id          NOT NULL        Atribute data-specID added with the value of the ID to be used later on the javascript 
        @ p_title           NOT NULL        Label to be shown for the item (this should be the name of the specificity with the chosen language) 
        @ p_list_group      NULL            List group for the list type items (required for the correct functioning of the lists) 
        @ p_list_code       NULL            List code for the list type items (required for the correct functioning of the lists) 
        @ p_counter         NULL            Indicates if the specificity is set as a counter 
        @ p_sysdate_ind     NULL            Indicates if the specificity of date should have a max date(1) or min date(2) 
        @ p_item_size       NULL            Indicates the size of the item
        @ p_item_max_length NULL            Indicates the max length of the item
        @ p_class           NULL            Indicates the class of the item
        @ p_item_id         NULL            Indicates the id of the item
        @ p_ref_id          NULL            Indicates the id of the reference
        @ p_lang            NULL            Language in which the specificites will be shown  
    -------------------------------------------------------------------------
    */ 
    function gen_item_html( p_type_item         in varchar2 
                          , p_value             in varchar2 
                          , p_mandatory_ind     in number default 0 
                          , p_read_only_ind     in number default 0
                          , p_spc_id            in number  
                          , p_title             in varchar2 
                          , p_list_group        in varchar2 
                          , p_list_code         in varchar2 
                          , p_counter           in number default 0 
                          , p_sysdate_ind       in number default 0 
                          , p_item_size         in number default null
                          , p_item_max_length   in number default null
                          , p_class             in varchar2 default null
                          , p_item_id           in varchar2 default null
                          , p_ref_id            in number default null
                          , p_lang              in varchar2
    ) return clob;

END SPC_DISPLAY_HANDLER;

