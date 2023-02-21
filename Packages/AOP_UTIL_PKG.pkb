create or replace PACKAGE BODY "AOP_UTIL_PKG" 
as  
    g_collection_name varchar2(25) := 'TEMP_BLOB_CONTENT';  
    procedure generer_script_rapport(p_code_rapport in varchar2)  
    is  
        l_chunk_size     constant number (4) := 100;  
        l_blob_inhex     clob;  
        l_pos            number;  
        l_text_chunk     clob;  
    begin  
      dbms_output.enable(buffer_size => null);  
      dbms_output.put_line('declare');  
      dbms_output.put_line('l_blob_fra blob;');  
      dbms_output.put_line('l_blob_ang blob;');  
      dbms_output.put_line('l_count number;');  
      dbms_output.put_line('begin');  
      for x in(  
        /* ------------------------SELECT FROM YOUR TABLE HERE------------------------ */  
        select  
        nom_rapport_fra,  
        nom_rapport_ang,  
        rapport_type,  
        filename_fra,  
        filename_ang,  
        mime_type_fra,  
        mime_type_ang,  
        rapport_fra as blob_source_fra,  
        rapport_ang as blob_source_ang,  
        code_rapport_int,  
        output_type,  
        output_filename,  
        download_filename_fra,  
        download_mime_type_fra,  
        download_filename_ang,  
        download_mime_type_ang,  
        zip_download_filename_fra,  
        zip_download_mime_type_fra,  
        zip_download_filename_ang,  
        zip_download_mime_type_ang,  
        zip_number_rows_per_split,  
        id_ir_static,  
        nom_ir_rapport,  
        ir_app_id,  
        ir_page_id,  
        static_id_info_suppl  
        from cnd_config_rapports  
        where code_rapport = p_code_rapport  
      )  
      loop  
        --blob fra  
        l_pos := 1;  
        dbms_output.put_line('l_blob_fra := empty_blob();');  
        dbms_output.put_line('dbms_lob.createtemporary(l_blob_fra, true);');  
        dbms_lob.createtemporary(l_blob_inhex, true);  
        while dbms_lob.getlength(dbms_lob.substr(x.blob_source_fra,l_chunk_size,l_pos)) is not null  
        loop  
          l_text_chunk := rawtohex( dbms_lob.substr(x.blob_source_fra,l_chunk_size,l_pos));  
          l_pos := l_pos + l_chunk_size;  
          dbms_output.put_line('dbms_lob.append(l_blob_fra, hextoraw(''' || l_text_chunk || '''));');  
        end loop;  
        --blob ang  
        l_pos := 1;  
        dbms_output.put_line('l_blob_ang := empty_blob();');  
        dbms_output.put_line('dbms_lob.createtemporary(l_blob_ang, true);');  
        dbms_lob.createtemporary(l_blob_inhex, true);  
        while dbms_lob.getlength(dbms_lob.substr(x.blob_source_ang,l_chunk_size,l_pos)) is not null  
        loop  
          l_text_chunk := rawtohex( dbms_lob.substr(x.blob_source_ang,l_chunk_size,l_pos));  
          l_pos := l_pos + l_chunk_size;  
          dbms_output.put_line('dbms_lob.append(l_blob_ang, hextoraw(''' || l_text_chunk || '''));');  
        end loop;  
        dbms_output.put_line('select count(*) into l_count from cnd_config_rapports where code_rapport = ''' || p_code_rapport || ''';');  
        dbms_output.put_line('if l_count = 0 then');  
        /*------------------------ MODIFY THIS INSERT STATEMENT AS NEEDED SO THIS CAN PRODUCE YOUR SCRIPT ------------------------*/  
        dbms_output.put_line('insert into cnd_config_rapports (');  
        dbms_output.put_line(' code_rapport,');  
        dbms_output.put_line(' nom_rapport_fra,');  
        dbms_output.put_line(' nom_rapport_ang,');  
        dbms_output.put_line(' rapport_type,');  
        dbms_output.put_line(' filename_fra,');  
        dbms_output.put_line(' filename_ang,');  
        dbms_output.put_line(' mime_type_fra,');  
        dbms_output.put_line(' mime_type_ang,');  
        dbms_output.put_line(' rapport_fra,');  
        dbms_output.put_line(' rapport_ang,');  
        dbms_output.put_line(' code_rapport_int,');  
        dbms_output.put_line(' output_type,');  
        dbms_output.put_line(' output_filename,');  
        dbms_output.put_line(' download_filename_fra,');  
        dbms_output.put_line(' download_mime_type_fra,');  
        dbms_output.put_line(' download_filename_ang,');  
        dbms_output.put_line(' download_mime_type_ang,');  
        dbms_output.put_line(' zip_download_filename_fra,');  
        dbms_output.put_line(' zip_download_mime_type_fra,');  
        dbms_output.put_line(' zip_download_filename_ang,');  
        dbms_output.put_line(' zip_download_mime_type_ang,');  
        dbms_output.put_line(' zip_number_rows_per_split,');  
        dbms_output.put_line(' id_ir_static,');  
        dbms_output.put_line(' nom_ir_rapport,');  
        dbms_output.put_line(' ir_app_id,');  
        dbms_output.put_line(' ir_page_id,');  
        dbms_output.put_line(' static_id_info_suppl');  
        dbms_output.put_line(' )');  
        dbms_output.put_line('values (');  
        dbms_output.put_line(''''||p_code_rapport||''',');  
        dbms_output.put_line(''''||replace(x.nom_rapport_fra,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.nom_rapport_ang,'''','''''') ||''',');  
        dbms_output.put_line(''''||x.rapport_type ||''',');  
        dbms_output.put_line(''''||x.filename_fra ||''',');  
        dbms_output.put_line(''''||x.filename_ang ||''',');  
        dbms_output.put_line(''''||x.mime_type_fra ||''',');  
        dbms_output.put_line(''''||x.mime_type_ang ||''',');  
        dbms_output.put_line('l_blob_fra,');  
        dbms_output.put_line('l_blob_ang,');  
        dbms_output.put_line(''''||replace(x.code_rapport_int,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.output_type,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.output_filename,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.download_filename_fra,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.download_mime_type_fra,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.download_filename_ang,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.download_mime_type_ang,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.zip_download_filename_fra,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.zip_download_mime_type_fra,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.zip_download_filename_ang,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.zip_download_mime_type_ang,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.zip_number_rows_per_split,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.id_ir_static,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.nom_ir_rapport,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.ir_app_id,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.ir_page_id,'''','''''') ||''',');  
        dbms_output.put_line(''''||replace(x.static_id_info_suppl,'''','''''') ||'''');  
        dbms_output.put_line(');');  
        dbms_output.put_line('');  
        dbms_output.put_line('else');  
        dbms_output.put_line('update cnd_config_rapports set ');  
        dbms_output.put_line(' nom_rapport_fra = '''||replace(x.nom_rapport_fra,'''','''''') ||''',');  
        dbms_output.put_line(' Nom_Rapport_Ang = '''||replace(x.nom_rapport_ang,'''','''''') ||''',');  
        dbms_output.put_line(' rapport_type = '''||x.rapport_type ||''',');  
        dbms_output.put_line(' filename_fra = '''||x.filename_fra ||''',');  
        dbms_output.put_line(' filename_ang = '''||x.filename_ang ||''',');  
        dbms_output.put_line(' mime_type_fra = '''||x.mime_type_fra ||''',');  
        dbms_output.put_line(' mime_type_ang = '''||x.mime_type_ang ||''',');  
        dbms_output.put_line(' Rapport_Fra = l_blob_fra,');  
        dbms_output.put_line(' rapport_ang = l_blob_ang,');  
        dbms_output.put_line(' code_rapport_abr = '''||replace(x.code_rapport_int,'''','''''') ||''',');  
        dbms_output.put_line(' output_type  = '''||replace(x.output_type,'''','''''') ||''',');  
        dbms_output.put_line(' output_filename  = '''||replace(x.output_filename,'''','''''') ||''',');  
        dbms_output.put_line(' download_filename_fra  = '''||replace(x.download_filename_fra,'''','''''') ||''',');  
        dbms_output.put_line(' download_mime_type_fra  = '''||replace(x.download_mime_type_fra,'''','''''') ||''',');  
        dbms_output.put_line(' download_filename_ang  = '''||replace(x.download_filename_ang,'''','''''') ||''',');  
        dbms_output.put_line(' download_mime_type_ang  = '''||replace(x.download_mime_type_ang,'''','''''') ||''',');  
        dbms_output.put_line(' zip_download_filename_fra  = '''||replace(x.zip_download_filename_fra,'''','''''') ||''',');  
        dbms_output.put_line(' zip_download_mime_type_fra  = '''||replace(x.zip_download_mime_type_fra,'''','''''') ||''',');  
        dbms_output.put_line(' zip_download_filename_ang  = '''||replace(x.zip_download_filename_ang,'''','''''') ||''',');  
        dbms_output.put_line(' zip_download_mime_type_ang  = '''||replace(x.zip_download_mime_type_ang,'''','''''') ||''',');  
        dbms_output.put_line(' zip_number_rows_per_split  = '''||replace(x.zip_number_rows_per_split,'''','''''') ||''',');  
        dbms_output.put_line(' id_ir_static  = '''||replace(x.id_ir_static,'''','''''') ||''',');  
        dbms_output.put_line(' nom_ir_rapport  = '''||replace(x.nom_ir_rapport,'''','''''') ||''',');  
        dbms_output.put_line(' ir_app_id  = '''||replace(x.ir_app_id,'''','''''') ||''',');  
        dbms_output.put_line(' ir_page_id  = '''||replace(x.ir_page_id,'''','''''') ||''',');  
        dbms_output.put_line(' static_id_info_suppl  = '''||replace(x.static_id_info_suppl,'''','''''') ||'''');  
        dbms_output.put_line(' where code_rapport = ''' || p_code_rapport || ''';');  
        dbms_output.put_line('end if;');  
      end loop;  
      dbms_output.put_line('commit;');  
      dbms_output.put_line('end;');  
      dbms_output.put_line('/');  
    end generer_script_rapport;  
    procedure inserer_blob_dans_collection( p_filename      in varchar2,  
                                            p_mime_type     in varchar2,  
                                            p_blob_content  in blob,  
                                            p_inline        in varchar2 default null,  
                                            p_modal         in varchar2 default null)  
    is  
    begin  
    -----  
    --inserer le blob dans une collection  
    -----  
    IF APEX_COLLECTION.COLLECTION_EXISTS (g_collection_name) then  
           APEX_COLLECTION.DELETE_COLLECTION (g_collection_name);  
    END IF;  
    APEX_COLLECTION.CREATE_COLLECTION (g_collection_name);  
    APEX_COLLECTION.ADD_MEMBER (  
        p_collection_name => g_collection_name,  
        p_c001 => p_filename,  
        p_c002 => p_mime_type,  
        p_c003 => p_inline,  
        p_c004 => p_modal,  
        p_blob001 => p_blob_content  
    );  
    end inserer_blob_dans_collection;  
    procedure download_blob  
    is  
        l_filename  varchar2(400);  
        l_mime_type varchar2(255);  
        l_inline    varchar2(1);  
        l_modal     varchar2(1);  
        l_blob blob;  
    begin  
        select c001,  
        c002,  
        c003,  
        c004,  
        blob001  
        into  
        l_filename,  
        l_mime_type,  
        l_inline,  
        l_modal,  
        l_blob  
        from apex_collections  
        where collection_name = g_collection_name;  
        --delete collection  
        IF APEX_COLLECTION.COLLECTION_EXISTS (g_collection_name) then  
               APEX_COLLECTION.DELETE_COLLECTION (g_collection_name);  
        END IF;  
        --oos_utils  
        dbms_lob.open(l_blob, dbms_lob.lob_readonly);  
        owa_util.mime_header(l_mime_type, false);  
        case when l_inline = 'Y' or l_modal = 'Y' then  
            htp.p('Content-Disposition: inline;  filename=' || l_filename || '"');  
        else  
            htp.p('Content-Disposition: attachment; filename=' || l_filename || '"');  
        end case;  
        owa_util.http_header_close;  
        wpg_docload.download_file(l_blob);  
        apex_application.stop_apex_engine;  
    end;  
    procedure ecrire_json_output(  
                p_execution_flag    in number,  
                p_error_message     in varchar2,  
                p_inline            in varchar2 default null,  
                p_modal             in varchar2 default null,  
                p_has_more          in boolean default null )  
    is  
    begin  
        apex_json.initialize_clob_output;  
        apex_json.open_object;  
        apex_json.write('execution_flag', p_execution_flag);  
        apex_json.write('has_more', p_has_more);  
        apex_json.write('p_inline', p_inline);  
        case when p_modal = 'Y' then  
            apex_json.write('url', apex_util.prepare_url('f?p=' || V('APP_ID') || ':998:' || V('APP_SESSION') || ':::'));  
        else  
            apex_json.write('url', apex_util.prepare_url('f?p=' || V('APP_ID') || ':998:' || V('APP_SESSION') || ':::'));  
        end case;  
        apex_json.write('error_message', p_error_message);  
        apex_json.close_object;  
        htp.prn(apex_json.get_clob_output);  
        apex_json.free_output;  
    end ecrire_json_output;  
    function get_message_erreur  
    return varchar2  
    is  
        l_error_message varchar2(4000);  
    begin  
      if sqlcode = -20000 then  
        l_error_message := 'Problème avec serveur AOP.';  
      else  
        l_error_message := 'Erreur lors de la génération du rapport. Vérifiez la configuration du rapport.';  
      end if;  
        return l_error_message;  
    end;  
    function format_aop_montant(p_montant   in number,  
                                p_format    in varchar2 default '999G999G999G999G990D00',  
                                p_decimal   in varchar2 default '.' )  
    return varchar2  
    is  
    begin  
        return '!FMT!'||to_char(p_montant,p_format,'NLS_NUMERIC_CHARACTERS=''' || p_decimal || ' '''); -- keep the space in ' '''  
    end format_aop_montant; 
    ------------------------------------------------------------------------------------------------------  
    procedure load_collection ( p_no in varchar2 )  
     as  
        l_no_split  apex_t_varchar2;  
    BEGIN  
        -- Supprimer la collection si elle existe  
        if apex_collection.COLLECTION_EXISTS( p_collection_name=> gc_coll_name ) then  
            apex_collection.DELETE_COLLECTION ( p_collection_name => gc_coll_name);  
        end if;  
        -- creer la collection  
        apex_collection.CREATE_COLLECTION( p_collection_name => gc_coll_name);  
        l_no_split := apex_string.split( p_no, ':');  
        -- inserer les no_dossier dans la collection  
        for i in 1..l_no_split.count  
        loop  
            apex_collection.ADD_MEMBER( p_collection_name   => gc_coll_name,  
                                        p_c001              => l_no_split(i) );  
        end loop;   
    exception  
        when others then  
            raise;  
    END load_collection;  
end AOP_UTIL_PKG;
