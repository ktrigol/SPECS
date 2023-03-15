create or replace PACKAGE BODY "AOP_RAPPORTS_PKG" AS 
/*------------------------------------------------------------------------------ 
    Package Description: Generique report package for AOP.
    Date:   
    Author: Mohamed Lamri (Insum Solutions Inc.) 
    Modifications: 
    Date: 
    Author: 
    Description: 
    ------------------------------------------------------------------------------*/ 
    g_aop_server_url           varchar2(500) := 'https://api.apexofficeprint.com/'; 
    g_aop_api_key              varchar2(500) := 'F5254B8705B42F2FE055043998A2C4EE';  --> DEVELOPMENT KEY
    --g_aop_api_key              varchar2(500) := '';    --> PRODUCTION KEY
    g_values                   varchar2(32767); 
    g_bind_title               varchar2(500); 
    function get_g_aop_api_key return varchar2 as
    begin
        return g_aop_api_key;
    end get_g_aop_api_key;
    /*-------------------------------------------------------------------------- 
    Procedure Description: Generate the AOP report 
    Return: BLOB
    Parameters: 
    ---------------------------------------------------------------------------- 
    */ 
    function creer_rapport( 
                        p_code_rapport       in varchar2, 
                        p_app_id             in number default v('APP_ID'), 
                        p_page_id            in number default v('APP_PAGE_ID'), 
                        p_output_type        in varchar2 default 'pdf', 
                        p_output_filename    in out varchar2, 
                        p_valeurs            in varchar2 default null,
                        p_langue_rapport     in varchar2 default 'en'
    ) 
    return blob 
    is 
        l_binds             wwv_flow_plugin_util.t_bind_list; 
        l_return            blob; 
        l_output_filename   varchar2(100) := 'output'; 
        l_template          blob; 
        l_json_data         clob; 
        
        l_langue_rapport    varchar2(100) := nvl(p_langue_rapport, 'en');
    begin 
        -- Get the template from the database and store it in a blob variable.
        select report 
        into l_template
        from aop_report_config_v
        where report_code = p_code_rapport;

        --json DATA 
        l_json_data := aop_json_pkg.construire_json(p_code_rapport,nvl(p_valeurs,g_values),g_bind_title); 
        
        
        l_return := aop_plsql22_pkg.make_aop_request( 
                                                    p_aop_url         => g_aop_server_url, 
                                                    p_api_key         => g_aop_api_key, 
                                                    p_json            => l_json_data, 
                                                    p_template        => l_template, 
                                                    p_output_type     => p_output_type, 
                                                    p_output_filename => p_output_filename,
                                                    p_aop_remote_debug=> 'Yes' -- for test
                                                    ); 
      
        return l_return; 
    exception 
        when others then 
            --insum_debug.log_error('Erreur : ');
            apex_debug.log_message  (p_message => 'Error creating aop report' 
                                    ,p_enabled => true
                                    ,p_level   => 1);
            raise; 
    end creer_rapport; 
/*-------------------------------------------------------------------------- 
    Procedure Description: Generate the AOP report 
    Return: 
    Parameters: 
    ---------------------------------------------------------------------------- 
    */ 
    procedure generer_rapport( 
                        p_code_rapport      in varchar2, 
                        p_valeurs           in varchar2, 
                        p_app_id            in number  default v('APP_ID'), 
                        p_page_id           in number default v('APP_PAGE_ID') ,
                        p_langue_rapport    in varchar2 default 'en'
    ) AS 
        -- Variables
        l_download_filename         aop_report_config_lang.filename%type;
        l_download_mime_type        aop_report_config_lang.mime_type%type;
        l_output_filename           aop_report_config_lang.filename%type;
        l_output_type               aop_report_config.output_type%type;
        l_blob_content              blob; 
        l_error_message             varchar2(4000); 
        l_execution_flag            number(1) := 1; 
        l_vc_arr2                   apex_t_varchar2; 
        
        l_pfe_no number; 
        l_date_traitement date; 
        l_langue_rapport varchar2(100) := nvl(p_langue_rapport, 'en');
    begin 
        g_values := p_valeurs; 
         
        -- Get the report configuration
        select 
            output_type, 
            'output', 
            download_filename, 
            download_mime_type mime_type
        into 
            l_output_type, 
            l_output_filename, 
            l_download_filename, 
            l_download_mime_type
        from aop_report_config_v 
        where report_code = p_code_rapport;

        -- Generate the report and store the result in a blob variable.
        l_blob_content := creer_rapport( 
                                p_code_rapport => p_code_rapport, 
                                p_app_id => p_app_id, 
                                p_page_id => p_page_id, 
                                p_output_type => l_output_type, 
                                p_output_filename => l_output_filename,
                                p_langue_rapport => l_langue_rapport
        ); 
          
		-- replace #INFO_ADDED# by g_bind_title
        l_download_filename := replace(l_download_filename,'#INFO_ADDED#',g_bind_title); 
        
        -- Insert the blob into the collection
        aop_util_pkg.inserer_blob_dans_collection(p_filename => l_download_filename, 
                                                p_mime_type => l_download_mime_type, 
                                                p_blob_content => l_blob_content); 
                                                
                                               
        aop_util_pkg.ecrire_json_output(p_execution_flag => l_execution_flag, 
                                            p_error_message => l_error_message);
    exception 
        when others then 
        
            apex_debug.log_message  (p_message => 'Error creating aop report' 
                                    ,p_enabled => true
                                    ,p_level   => 1);
            l_execution_flag := 0; 
    
            l_error_message := aop_util_pkg.get_message_erreur; 
    
            aop_util_pkg.ecrire_json_output(p_execution_flag => l_execution_flag, 
                                                p_error_message => l_error_message);
            
            --raise_application_error(-20001,dbms_utility.format_error_backtrace);
    end generer_rapport; 
END AOP_RAPPORTS_PKG;
