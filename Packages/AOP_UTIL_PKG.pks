create or replace PACKAGE "AOP_UTIL_PKG" 
as 
 
    -- nom de la collection et ca doit etre le meme nom dans la vue v_releves_det_collection 
    gc_coll_name          constant varchar2(30) := 'COLL_NAME' ; 
    ------------------------------------------------------------------------------*/ 
    /*procedure generer_script_rapport(p_code_rapport in varchar2); */
    procedure inserer_blob_dans_collection(p_filename       in varchar2, 
                                            p_mime_type     in varchar2, 
                                            p_blob_content  in blob, 
                                            p_inline        in varchar2 default null, 
                                            p_modal         in varchar2 default null 
                                            ); 
    procedure download_blob; 
    procedure ecrire_json_output( 
                p_execution_flag    in number, 
                p_error_message     in varchar2, 
                p_inline            in varchar2 default null, 
                p_modal             in varchar2 default null, 
                p_has_more          in boolean default null ); 
    function get_message_erreur 
    return varchar2; 
    function format_aop_montant(p_montant   in number, 
                                p_format    in varchar2 default '999G999G999G999G990D00', 
                                p_decimal   in varchar2 default '.') 
    return varchar2; 
    -- Charger la collection avec les no_dossier passé en paramètre 
    procedure load_collection ( p_no in varchar2 ); 
end AOP_UTIL_PKG;
