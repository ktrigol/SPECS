create or replace PACKAGE "AOP_JSON_PKG" AS 
   /*------------------------------------------------------------------------------ 
    Package Description: Package pour générer le data en format Json pour les rapports AOP 
    Date:   
    Author: Mohamed Lamri (Insum Solutions Inc.) 
    Modifications: 
    Date: 
    Author: 
    Description: 
    ------------------------------------------------------------------------------*/ 
   /*------------------------------------------------------------------------- 
    Procedure Description: Construire l'objet Json 
    Return: 
    Parameters: 
    -------------------------------------------------------------------------*/ 
    function construire_json(p_code_rapport in varchar2,p_values in varchar2,g_bind_title in out varchar2) 
    return clob; 
END AOP_JSON_PKG;
