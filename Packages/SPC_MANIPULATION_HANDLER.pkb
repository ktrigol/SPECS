create or replace PACKAGE BODY "SPC_MANIPULATION_HANDLER" AS 
/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:
   Package in charge of manipulating and save the specificities data.
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
    Procedure Description: Runs the collection and save the changes on the 
                           spc_data table
    Parameters: 
    -------------------------------------------------------------------------
    */
    procedure set_spc_data
    is
        -- Variables
        l_app_id        number;
        l_page_id       number;
        l_code          varchar2(50);
        l_id_spc_def    spc_definition.id%type;
    begin
        -- Get the application and page id
        l_app_id := apex_util.get_session_state('APP_ID');
        l_page_id := apex_util.get_session_state('APP_PAGE_ID');
        -- Merge the data from the collection to the spc_data table
        MERGE INTO spc_data t1
        USING (SELECT c001 spc_id, c002 spc_value, c003 ref_id, c004 ref_type_id
               FROM apex_collections 
               WHERE collection_name = 'SPC_DT_'||l_app_id||'P?='||l_page_id) t2
        ON (t1.spc_id = t2.spc_id and nvl(t1.ref_id, -1) = nvl(t2.ref_id,-1)) 
        WHEN MATCHED THEN
        UPDATE SET t1.value = t2.spc_value
        WHEN NOT MATCHED THEN
        INSERT (spc_id, ref_id, ref_type_id, value)
        VALUES (t2.spc_id, t2.ref_id, t2.ref_type_id, t2.spc_value); 
        --? INC_UTILS_API.get_val_spec_genere(col.id_spc,col.spc_value)
        
    exception
        when others then 
            -- Get the error message
            raise_application_error(-20100,sqlerrm);         
    end set_spc_data;
    
END SPC_MANIPULATION_HANDLER;
