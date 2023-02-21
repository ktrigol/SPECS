create or replace PACKAGE "AOP_RAPPORTS_PKG" AS 
/*------------------------------------------------------------------------------ 
    Package Description: Package générique pour les rapports AOP 
    Date:   
    Author: Mohamed Lamri (Insum Solutions Inc.) 
    Modifications: 
    Date: 
    Author: 
    Description: 
    ------------------------------------------------------------------------------*/ 
/*-------------------------------------------------------------------------- 
    Procedure Description: Générer le rapport 
    Return: 
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
                        p_langue_rapport     in varchar2 default 'fr'
    ) return blob; 
/*-------------------------------------------------------------------------- 
    Procedure Description: Générer le rapport 
    Return: 
    Parameters: 
    ---------------------------------------------------------------------------- 
    */ 
    procedure generer_rapport( 
                        p_code_rapport      in varchar2, 
                        p_valeurs           in varchar2, 
                        p_app_id            in number  default v('APP_ID'), 
                        p_page_id           in number default v('APP_PAGE_ID'),
                        p_langue_rapport    in varchar2 default 'fr'
                        
    ); 
    
     function get_g_aop_api_key return varchar2;
END AOP_RAPPORTS_PKG;
