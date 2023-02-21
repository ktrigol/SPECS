create or replace PACKAGE "AOP_REPORT_SPC" as



/*------------------------------------------------------------------------- 
Méthode principale pour la formation du JSON de toutes les rapports AOP des
lettres.
@param p_valeurs valeurs nécessaires afin de constuire le JSON du rapport
@author Pascal St-Amour
-------------------------------------------------------------------------*/

function print_spc (p_ref_type_id  in spc_ref_type.id%type 
                   ,p_ref_id       in spc_data.ref_id%type
                   ,p_langue       in spc_lang.lang_code%type default null
) return clob;


function print_spc_by_code (p_ref_type_id  in spc_ref_type.id%type 
                           ,p_ref_id       in spc_data.ref_id%type
                           ,p_langue       in spc_lang.lang_code%type default null
) return clob;


end AOP_REPORT_SPC;