create or replace PACKAGE BODY SPC_DISPLAY_HANDLER AS 
     
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
   
    /************************************************************************ 
    -------------------------------------------------------------------------  
    Function Description: Generates and return the SQL for the region of the Plug-in 
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
    ) return varchar2  
    is
        l_result varchar2(32767);
    begin
        -- Generate the SQL for the region of the Plug-in
        l_result := 
                 'select c001 '||
                    /* ' , c002 '||
                     ' , c003 '||
                     ' , c004 '||
                     ' , n001 '||
                     ' , n002 '||*/
                     ' , clob001 '||
                ' from apex_collections '|| 
                ' where collection_name = ''SPC_'||p_app_id||'P?='||p_page_id||''' '||
                ' and (n002 = '''||p_group_id||''' '||
                      'or nvl(''' ||p_group_id||''',1 ) = 1)'||
                ' order by n001 asc';
            return l_result;
    exception 
        when others then 
            -- log error
            l_result := 'select ''One error has occured'' as Error '||
                        '       ,'''||sqlerrm||''' as Error Message '||
                        ' from dual';
            return l_result;
    end get_spc_query;
 
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
    ) 
    is 
        -- Variables 
        l_code_type_contrat  number;   
        l_title varchar2(4000); 
        l_item clob; 
 
        -- Cursor
        cursor c_spc (p_app_id in number 
                     ,p_page_id in number 
                     ,p_ref_type_id in number 
                     ,p_ref_id in number)is 
        select  
                  rownum as nb 
                , spcs.spc_id 
                , field_type 
                , title 
                , help_text
                , mandatory_ind 
                , read_only_ind
                , active_ind 
                , help_text_ind
                , list_group 
                , list_code 
                , coalesce(spcs.value, col.value) as value 
                , disp_seq 
                , sysdate_ind 
                , counter_ind 
                , group_def_id
                , item_size
                , item_max_length
                , class
                , spcs.spc_id || '_' || p_app_id || '_' || p_page_id || '_' || p_ref_id as item_id
            from ( 
               select t1.id as spc_id  
                    , t1.field_type 
                    , spc_tool.get_description_lang(t1.id,p_lang) as title 
                    , spc_tool.get_des_helptext_lang(t1.id,p_lang) as help_text
                    , t1.mandatory_ind 
                    , t1.read_only_ind 
                    , t1.active_ind 
                    , t1.help_text_ind 
                    , t1.list_group 
                    , t1.list_code 
                    , nvl(t2.value ,t1.default_value) as value 
                    , t1.disp_seq 
                    , t1.sysdate_ind 
                    , case when t1.counter_code is not null and t2.value is null then 1 
                           when t1.counter_code is not null and t2.value = 'N/A' then 1 
                           else 0 
                      end counter_ind 
                    , t1.group_def_id
                    , t1.item_size
                    , t1.item_max_length
                    , t3.class 
                from  spc_definition t1 
                join  spc_data t2  
                on    t1.id = t2.spc_id 
                left join spc_format t3
                on    t1.format_id = t3.id
                where t1.active_ind = 1  
                and   t1.app_id = p_app_id 
                and   nvl(t1.page_id,p_page_id) = p_page_id
                and   (nvl(t2.ref_type_id, -1) = nvl(p_ref_type_id , -1)
                     and nvl(t2.ref_id,-1) = nvl(p_ref_id,-1))
                union 
               select t1.id as spc_id 
                    , t1.field_type 
                    , spc_tool.get_description_lang(t1.id,p_lang) as title 
                    , spc_tool.get_des_helptext_lang(t1.id,p_lang) as help_text
                    , t1.mandatory_ind 
                    , t1.read_only_ind
                    , t1.active_ind
                    , t1.help_text_ind 
                    , t1.list_group 
                    , t1.list_code 
                    , t1.default_value as value 
                    , t1.disp_seq 
                    , t1.sysdate_ind 
                    , case when t1.counter_code is null then 1 
                           else 0 
                      end counter_ind 
                    , t1.group_def_id
                    , t1.item_size
                    , t1.item_max_length
                    , t3.class
                from  spc_definition t1 
                left join spc_format t3
                on   t1.format_id = t3.id
                where t1.active_ind = 1  
                and   t1.app_id = p_app_id 
                and   nvl(t1.page_id,p_page_id) = p_page_id 
                and    not exists ( 
                    select 1  
                    from spc_data t2 
                    where  t1.id = t2.spc_id 
                    and    t2.ref_id = p_ref_id 
                ) 
            ) spcs, ( 
                select c001 as spc_id, c002 as value 
                from apex_collections 
                where collection_name = 'SPC_DT'||p_app_id||'P?='||p_page_id
            ) col 
            where spcs.spc_id = col.spc_id(+)
            and spcs.spc_id not in (select column_value 
                                   from table(apex_string.split(p_exc_ids,':')))
            order by spcs.disp_seq; 
 
    begin 
        -- Create the collection if it doesn't exist or truncate it if it does
        apex_collection.create_or_truncate_collection(p_collection_name => 'SPC_'||p_app_id||'P?='||p_page_id); 
         
        -- Get the specificities for the App and Page
        for rec in c_spc (p_app_id, p_page_id, p_ref_type_id, p_ref_id) 
        loop 
            -- Generate the HTML for the item
            l_item := spc_display_handler.gen_item_html( p_type_item        => rec.field_type 
                                                       , p_value           => rec.value 
                                                       , p_mandatory_ind   => rec.mandatory_ind 
                                                       , p_read_only_ind   => rec.read_only_ind
                                                       , p_spc_id          => rec.spc_id 
                                                       , p_title           => rec.title 
                                                       , p_list_group      => rec.list_group 
                                                       , p_list_code       => rec.list_code 
                                                       , p_counter         => rec.counter_ind 
                                                       , p_sysdate_ind     => rec.sysdate_ind
                                                       , p_item_size       => rec.item_size
                                                       , p_item_max_length => rec.item_max_length 
                                                       , p_class           => rec.class
                                                       , p_item_id         => rec.item_id
                                                       , p_ref_id          => p_ref_id
                                                       , p_ref_type_id     => p_ref_type_id
                                                       , p_lang            => p_lang 
                        );   
           -- l_title := '<strong>' || rec.title || '</strong>';
           l_title := rec.title;
           -- TODO : Johanna wat to have the title with a background all along
           /*if rec.field_type = k_type_title then 
                l_title :=  '<span style="background-color: cornflowerblue;">' || rec.title || '</span>';
           end if;*/
            
            -- Add the item to the collection
            apex_collection.add_member( 
                      p_collection_name => 'SPC_'||p_app_id||'P?='||p_page_id -- case when rec.nb <= 50 then 'C_SPEC_COL1' else 'C_SPEC_COL2' end 
                    , p_clob001 => l_item
                    , p_c001 => l_title||case when rec.mandatory_ind = 1 then ' <span title="Mandatory" class="u-color-9-text">*</span>' else '' end
                    , p_c002 => p_lang
                    , p_c003 => case when rec.help_text_ind = 1 then rec.help_text else null end
                    , p_c004 => rec.field_type
                    , P_n001 => rec.disp_seq
                    , p_n002 => rec.group_def_id 
                ); 
        end loop; 
 
    end init_spc; 
 
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
        @ p_ref_type_id     NULL            Indicates the type of the reference
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
                          , p_ref_type_id       in number default null
                          , p_lang              in varchar2
    ) return clob 
    is  
        l_return clob; 
    begin 
        -- Generate the HTML for the item based on the type of item
        case p_type_item 
            when k_type_text then 
                l_return := APEX_ITEM.TEXT(  
                    p_idx        => 2 
                  , p_value      => p_value   
                  , p_size       => nvl(p_item_size, 50) 
                  , p_maxlength  => nvl(p_item_max_length, 60) 
                  , p_attributes => 'class="itemSpc'
                        || case when p_class is not null then ' '||p_class end 
                        || case when p_mandatory_ind = 1 then ' mandatoryItem' end
                        || case when p_counter = 1 then ' gen_code' end
                        || case when p_item_id is not null then '" id="'|| p_item_id end 
                        || '" data-specID="' || p_spc_id 
                        || '" data-refTypeID="' || p_ref_type_id 
                        || case when p_ref_id is not null then '" data-refID="' || p_ref_id end
                        || '" data-label="' || p_title || '"' 
                        || case when p_read_only_ind = 1 then ' disabled '  end 
                  , p_item_label => p_title 
                ); 
             
            when k_type_date then 
                l_return := APEX_ITEM.DATE_POPUP2( 
                    p_idx => 2 
                  , p_value => to_date(p_value,'DD-MM-YYYY')  --? 
                  , p_date_format => 'DD-MM-YYYY' --? 
                  , p_size => 10 
                  , p_max_value =>  to_char(case when p_sysdate_ind = '1' then sysdate end,'DD-MM-YYYY') --? 
                  , p_min_value =>  to_char(case when p_sysdate_ind = '2' then sysdate end,'DD-MM-YYYY') --? 
                  , p_maxlength => 10 
                  , p_show_on => 'both' 
                  , p_navigation_list_for => 'MONTH_AND_YEAR' --? 
                  , p_year_range    => '-300:+1' 
                  , p_attributes => 'class="itemSpc date-format' 
                      || case when p_class is not null then ' '||p_class end
                      || case when p_mandatory_ind = 1 then ' mandatoryItem' else ' ' end 
                      --|| case when p_item_id is not null then '" id="'|| p_item_id   end 
                      --|| '" id="apex_date_02_00'--|| p_item_id
                      || '" data-specID="' || p_spc_id  
                      || '" data-refTypeID="' || p_ref_type_id 
                      || case when p_ref_id is not null then '" data-refID="' || p_ref_id end
                      || '" data-label="' || p_title || '"' 
                      || case when p_read_only_ind = 1 then  '" id="'|| p_item_id||'" disabled ' end 
                  , p_item_label => p_title  
                ); 
 
            when k_type_list then 
                l_return := APEX_ITEM.SELECT_LIST_FROM_QUERY( 
                    p_idx => 2 
                  , p_value => p_value 
                  , p_query => spc_tool.get_spc_query_lov( p_list_group => p_list_group 
                                                              , p_list_code => p_list_code 
                                                              , p_lang => p_lang 
                                                              )
                  , p_attributes => 'class="itemSpc' 
                        || case when p_class is not null then ' '||p_class end
                        || case when p_mandatory_ind = 1 then ' mandatoryItem' else '' end
                        || case when p_item_id is not null then '" id="'|| p_item_id end 
                        || '" data-specID="' || p_spc_id  
                        || '" data-refTypeID="' || p_ref_type_id 
                        || case when p_ref_id is not null then '" data-refID="' || p_ref_id end
                        || '" data-label="' || p_title || '"' 
                        || case when p_read_only_ind = 1 then ' disabled ' end 
                  , p_null_text => '-Select-' 
                  , p_item_label => p_title  
                ); 
 
            when k_type_text_area then 
                l_return := APEX_ITEM.TEXTAREA( 
                    p_idx => 2 
                  , p_value => p_value  
                  , p_rows => 2 --? 
                  , p_cols => nvl(p_item_size, 50) 
                  , p_attributes => 'class="itemSpc' 
                        || case when p_class is not null then ' '||p_class end
                        || case when p_mandatory_ind = 1 then ' mandatoryItem' else '' end  
                        || case when p_item_id is not null then '" id="'|| p_item_id end 
                        || '" data-specID="' || p_spc_id  
                        || '" data-refTypeID="' || p_ref_type_id 
                        || case when p_ref_id is not null then '" data-refID="' || p_ref_id end
                        || '" data-label="' || p_title || '"' 
                        || case when p_read_only_ind = 1 then ' disabled ' end 
                ); 
 
            when k_type_hour then 
                l_return := APEX_ITEM.TEXT( 
                    p_idx => 2 
                  , p_value => p_value 
                  , p_size => 5 
                  , p_maxlength => 5 
                  , p_attributes => 'class="itemSpc itemHour' 
                        || case when p_class is not null then ' '||p_class end
                        || case when p_mandatory_ind = 1 then ' mandatoryItem' else '' end 
                        || case when p_item_id is not null then '" id="'|| p_item_id end 
                        || '" data-specID="' || p_spc_id  
                        || '" data-refTypeID="' || p_ref_type_id 
                        || case when p_ref_id is not null then '" data-refID="' || p_ref_id end
                        || '" data-label="' || p_title || '" '
                        || case when p_read_only_ind = 1 then ' disabled ' end  
                  , p_item_label => p_title 
                ); 
            /*when k_type_title then 
                l_return :=  '<strong>' || p_title || '</strong>'; */
                    
            else 
                l_return := null; 
        end case; 
        -- Return the HTML
        return l_return; 
    exception 
      when others then 
        -- Return an error message if an error occurs
        l_return := '<b>'||'Error processing the apex item'||'</b>'; 
        return l_return; 
    end gen_item_html; 
     
END SPC_DISPLAY_HANDLER; 
