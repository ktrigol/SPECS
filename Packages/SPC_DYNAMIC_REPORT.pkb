create or replace PACKAGE BODY SPC_DYNAMIC_REPORT AS 
     
/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:
   Package in charge of manipulating dynamic reports.
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
    function get_dr_query /*( p_app_id      in number
                          , p_page_id     in number
                          , p_group_id    in number 
    )*/ return varchar2  
    is
        l_result varchar2(32767);
    begin
        -- Generate the SQL for the dynamic report
        l_result := 
                 'select '''' as 1 '||
                 '      , '''' as 2 '||
                ' from dual '|| 
                ' where 1 = 1' ;
            return l_result;
    exception 
        when others then 
            -- log error
            l_result := 'select ''One error has occured'' as Error '||
                        '       ,'''||sqlerrm||''' as Error Message '||
                        ' from dual';
            return l_result;
    end get_dr_query;
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Generates and return the SQL for the poplov for the column_value = spc or column name
    Return: SQL
    Parameters:  
        @ p_ref_type_id    NOT NULL     Type of reference id  
        @ p_spc_ind        NOT NULL     Specificity indicator
        @ p_lang           NOT NULL     Language
    -------------------------------------------------------------------------
    */
    function get_col_val_query ( p_ref_type_id      in number
                               , p_spc_ind          in number
                               , p_lang             in varchar2 default null 
    )return varchar2
    is
        l_result varchar2(32767);
    begin
        -- if it's a spc
        if p_spc_ind = 1 then
            -- Generate the SQL for spc
            l_result := 
                'select spc_tool.get_description_lang ( p_spc_id  => t1.id '||
                '                                     , p_lang    => '''||p_lang||''') ||'' [''||spc_code||'']''as display'||
                '     , to_char(id) as return'|| 
                'from spc_definition t1'||
                'where ref_type_id = '''||p_ref_type_id||''' ';
        else
            -- Generate the SQL for column
            l_result := 
                'select  t1.column_name as display, t1.column_name as return'|| 
                'from user_tab_columns t1'||
                'join spc_ref_type t2'||
                'on t1.table_name = t2.table_name'||
                'and  t2.id = '''||p_ref_type_id||''' ';
        end if;
        -- return the SQL
        return l_result;          
    exception 
        when others then 
            -- log error
            l_result := 'select ''One error has occured'' as Error '||
                        '       ,'''||sqlerrm||''' as Error Message '||
                        ' from dual';
            return l_result;
    end get_col_val_query;
     
    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the report name or detail in the given language
    Return: Text 
    Parameters:  
        @ p_report_id     NOT NULL        ID of the report
        @ p_value         NOT NULL        REPORT_NAME or DETAIL
        @ p_lang          NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */

    function get_description_lang ( p_report_id     in spc_report.id%type
                                  , p_value         in varchar2 -- REPORT_NAME or DETAIL
                                  , p_lang          in spc_lang.lang_code%type default null
      ) return varchar2
    is
      l_return_name spc_report_lang.report_name%type;
      l_return_det  spc_report_lang.detail%type;
    begin
        -- Get the report name or detail in the given language
        if p_value = 'REPORT_NAME' then
            select report_name
            into l_return_name
            from spc_report_lang t1
            join spc_lang t2
            on t1.report_lang_id = t2.id
            where (t2.lang_code = p_lang
                  or p_lang is null
                  and t2.default_lang_ind = 1)
            and   t1.report_id = p_report_id;
            return l_return_name;
        else
            select detail
            into l_return_det
            from spc_report_lang t1
            join spc_lang t2
            on t1.report_lang_id = t2.id
            where (t2.lang_code = p_lang
                  or p_lang is null
                  and t2.default_lang_ind = 1)
            and   t1.report_id = p_report_id;
            return l_return_det;
        end if;

        if l_return_name is null and l_return_det is null then 
            return null;
        end if;
    exception 
        when no_data_found then
            -- log error
            return 'No description found for this '||p_value||' in this language';
        when others then 
            -- log error
            return 'One error has occured: '||sqlerrm;
    end get_description_lang;

    /************************************************************************
    ------------------------------------------------------------------------- 
    Function Description: Returns the label name in the given language
    Return: Text 
    Parameters:  
        @ p_detail_id     NOT NULL        ID of the detail from spc_report_detail
        @ p_lang          NOT NULL        Code of the language
    -------------------------------------------------------------------------
    */

    function get_label_name_lang ( p_detail_id     in spc_report.id%type
                                  , p_lang          in spc_lang.lang_code%type default null
      ) return varchar2
    is
      l_return varchar2(4000);--spc_report_detail_lang.label_name%type;
      l_spc_ind spc_report_detail.spc_ind%type;
    begin
        begin
            -- Get the report name or detail in the given language
            select label_name
            into l_return
            from spc_report_detail_lang t1
            join spc_lang t2
            on t1.report_lang_id = t2.id
            where (t2.lang_code = p_lang
                    or p_lang is null
                    and t2.default_lang_ind = 1)
            and   t1.report_detail_id = p_detail_id;

            return l_return;
        exception
          when no_data_found then
            -- Return the name of the spec or the name of the column formated 
            select case t1.spc_ind  
                    when 1 then spc_tool.get_description_lang ( p_spc_id  => t1.column_value
                                                              , p_lang    => p_lang
                                                              )
                    else initcap(replace(column_value,'_',' '))
                    end
            into l_return
            from spc_report_detail t1
            where t1.id = p_detail_id;
            return l_return;
        end;
    exception 
        when no_data_found then
            -- log error
            return null;
        when others then 
            -- log error
            return 'One error has occured: '||sqlerrm;
    end get_label_name_lang;

    /************************************************************************
    -------------------------------------------------------------------------
    Procedure Description: initialize the collection of the report
    Parameters:
        @ p_collection_name     NOT NULL        Name of the collection
        @ p_report_id           NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    procedure init_coll_dynamic_report( p_collection_name in varchar2
                                      , p_report_id       in spc_report.id%type
    )
    is 
    begin
        if apex_collection.collection_exists(p_collection_name) then
            apex_collection.delete_collection(p_collection_name);
        end if; 

        -- Create the collection on page load
        begin 
            APEX_COLLECTION.CREATE_COLLECTION_FROM_QUERY (
                p_collection_name      =>    p_collection_name ,
                p_query                =>    spc_dynamic_report.get_query_collection( p_report_id => p_report_id)
            );
        exception
            when others then
                APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION  (p_collection_name => p_collection_name );
                APEX_COLLECTION.ADD_MEMBER(
                    p_collection_name => p_collection_name,
                    p_c001            => 'One error ocurred creating the dynamic report',
                    p_c002            => sqlerrm
                    );
        end;
    end;

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Returns the columns position for the group by
    Return: Text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    function get_col_pos_group_by(p_report_id      in spc_report.id%type
    ) return number 
    as 
        l_position  number;
    begin
        -- Get the columns for the group by
        select colunm_position into l_position
        from (
            select rownum as colunm_position, --colunm_position-- 
                seq_no, group_by_ind
            from
            (      
                select --rownum as colunm_position
                    seq_no as seq_no
                    , group_by_ind
                from spc_report_detail
                where report_id = p_report_id
                and active_ind = 1
                and display_ind = 1
                --and group_by_ind = 1
                order by seq_no asc
            )
        )
        where group_by_ind = 1
        --and rownum = 1;
        fetch first 1 row only;

        -- Return the position
        return l_position;
    exception when no_data_found then
        return null;
    end get_col_pos_group_by;

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Returns the columns position for the order by
    Return: Text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    function column_count( p_report_id      in spc_report_detail.id%type
    ) return number
    as 
        l_count number;
    begin
        
        select count(*) 
        into l_count
        from spc_report_detail
        where report_id = p_report_id
        and   active_ind = 1
        and   display_ind = 1;
        
        return l_count;
    exception 
        when others then 
            -- log error
            return 0;
    end column_count;

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Return the columns query for the collection 
    Return: text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
        @ p_seq           NOT NULL        Sequence number of the column
    -------------------------------------------------------------------------
    */

    function get_column_query_coll( p_report_id            in spc_report.id%type
                                  , p_seq                  in number
    )return varchar2 
    as
        l_result          varchar2(4000);
        l_rec_detail      spc_report_detail%rowtype;
        l_fiel_type       varchar2(50);
        l_vc_arr2         apex_t_varchar2;
    begin

        -- get the column detail of the report
        select  *
        into    l_rec_detail
        from    spc_report_detail
        where   report_id  = p_report_id
        and     seq_no = p_seq;

        -- Name of the column
        if l_rec_detail.spc_ind = 0 then
            if l_rec_detail.value_ref_ind = 1 then
                l_vc_arr2 := apex_string.split(l_rec_detail.value_ref,':'); -- 1: table_name 2: reference column 3: display column
                l_result := '(select listagg('||l_vc_arr2(3)||','', '') within group(order by '||l_vc_arr2(3)||') from '||l_vc_arr2(1)||' where '||l_vc_arr2(2)||' = t1.'||l_rec_detail.column_value||')';
            else 
                l_result := l_rec_detail.column_value;
            end if;
        -- Column is a specificity 
        else
            -- Get the value of the specificity
            l_result := 
                'spc_tool.get_value_spc( p_spc_id    =>  '||l_rec_detail.column_value ||
                '                      , p_ref_id    =>  id )';
            
        end if;
        
        return l_result;
    end get_column_query_coll;

    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Return the URL of the column
    Return: text
    Parameters:
        @ p_app_id         NOT NULL        
        @ p_app_page_id    NOT NULL        
        @ p_session        NOT NULL
        @ p_send_value    
        @ p_receive_value
    -------------------------------------------------------------------------
    */

    function get_url( p_app_id               in varchar2
                                  , p_app_page_id          in varchar2
                                  , p_session              in varchar2
                                  , p_send_value           in varchar2
                                  , p_receive_value        in varchar2
    )return varchar2 as
    begin
    return null;/*APEX_UTIL.PREPARE_URL(p_url => 'f?p=' || p_app_id || ':'|| p_app_page_id ||':'|| p_session ||'::NO::'||p_send_value||':'||p_receive_value
                ,p_checksum_type => 'SESSION');*/
    end;
    
    /************************************************************************
    -------------------------------------------------------------------------
    Function Description: Function to get the query for the collection
    Return: Text
    Parameters:
        @ p_report_id     NOT NULL        ID of the report
    -------------------------------------------------------------------------
    */

    function get_query_collection( p_report_id         in spc_report.id%type
    ) return clob 
    as
        l_query                  clob;
        l_ref_type_id            number;
        l_table_name             spc_ref_type.table_name%type;
        l_order_by               varchar2(2000);
        l_where                  varchar2(2000);
        l_col                    varchar2(2000);
        l_col_nb                 number := 0;
        l_app_session            varchar2(500):= apex_application.g_instance;
        l_app_id                 varchar2(500):= apex_application.g_flow_id;
    begin

        -- Get the reference type id
        select t2.table_name, t1.ref_type_id
        into l_table_name, l_ref_type_id
        from spc_report t1
        join spc_ref_type t2
        on t1.ref_type_id = t2.id
        where t1.id = p_report_id;

        -- Create the query for the columns
        for c1 in (
            select
                t1.id,
                t1.report_id,
                t1.column_value,
                t1.seq_no,
                t1.group_by_ind,
                t1.order_by_ind,
                --t1.value_ref_com,            
                t1.operator_comp,
                trim(t1.operator_comp_value) operator_comp_value,
                t1.display_ind,
                t1.ind_link,
                t1.link_page_id,
                t1.item_send_value,
                t1.item_recive_value
            from
                spc_report_detail t1
            where t1.report_id = p_report_id
            and   t1.active_ind = 1
            order by t1.seq_no asc
        ) loop
            l_col_nb := l_col_nb + 1;
            l_col := get_column_query_coll( p_report_id   => p_report_id
                                          , p_seq         => c1.seq_no
                                          );

            -- Concatenate the columns
            if c1.display_ind = 1 then
                if c1.ind_link = 1 and c1.link_page_id is not null then
                    l_query := l_query || ', ''<a href="''' 
                            ||' || APEX_UTIL.PREPARE_URL(p_url => ''f?p=' || l_app_id || ':'|| c1.link_page_id ||':'|| l_app_session ||'::NO::'||c1.item_recive_value||':''||'||c1.item_send_value || '||'''''
                        --|| replace(APEX_UTIL.PREPARE_URL(p_url => 'f?p=' || l_app_id || ':'|| c1.link_page_id ||':'|| l_app_session ||'::NO::'||c1.item_recive_value||':#'
                                                         ||',p_checksum_type => ''SESSION'')'                                                        
                            --,'#','''||'||c1.item_send_value||'||''') 
                            || '||''">''||'||l_col||'||''</a>'' as ' || l_col; 
                else
                    l_query := l_query || ',' || l_col; 
                end if;
            end if;
            
            -- Concatenate the where clause
            -- Column filter 
            case c1.operator_comp 
            -- 0: is null, 1: is not null, 2: equal , 3: not equal, 4: like 5: not like
                when 1 then
                    l_where := l_where || ' and ' || l_col || ' is null';
                when 2 then
                    l_where := l_where || ' and ' || l_col || ' is not null';
                when 3 then
                    l_where := l_where || ' and to_char(' || l_col || ') = ''' || c1.operator_comp_value || '''';
                when 4 then 
                    l_where := l_where || ' and to_char(' || l_col || ') != ''' || c1.operator_comp_value || '''';
                when 5 then
                    l_where := l_where || ' and upper(to_char(' || l_col || ')) like upper(''%' || c1.operator_comp_value || '%'')';
                when 6 then
                    l_where := l_where || ' and (upper(to_char(' || l_col || ')) not like upper(''%' || c1.operator_comp_value || '%'') 
                                                    or ' || l_col || ' is null)';
                else
                    null;
            end case;
            
            -- Concatenate the order by clause
            if c1.order_by_ind = 1 then 
                l_order_by := l_order_by || ',' || l_col_nb || ' asc';
            elsif c1.order_by_ind = 2 then
                l_order_by := l_order_by || ',' || l_col_nb || ' desc';
            end if;

        end loop;
        
        -- Delete additional "," and ' and '
        l_query := ltrim(l_query, ',');    
        l_where       := ltrim(l_where, ' and ');
        l_order_by    := ltrim(l_order_by, ',');

        if l_query is not null then
        
            -- Select from table
            l_query := 'select ' || l_query || ' from ' || l_table_name || ' t1  '; 
                    
            -- Add the where clause
            if l_where is not null then 
                l_query := l_query || ' where (' || l_where || ')'; 
            end if;
            
            -- Add the order by clause
            if l_order_by is not null then 
                l_query := l_query || ' order by ' || l_order_by;
            end if;
        else
            --return 'select 1 as col1, 2 as col2 from dual';
            l_query := 'select 1 from dual where 1 = 2';
        end if;
        
        return l_query;
        
    end get_query_collection;

END SPC_DYNAMIC_REPORT;
