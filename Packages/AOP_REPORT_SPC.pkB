create or replace PACKAGE BODY "AOP_REPORT_SPC" as


/*------------------------------------------------------------------------- 
Méthode principale pour la formation du JSON de toutes les rapports AOP des
lettres.
@param p_valeurs valeurs nécessaires afin de constuire le JSON du rapport
@author Pascal St-Amour
-------------------------------------------------------------------------*/

function print_spc (p_ref_type_id  in spc_ref_type.id%type 
                   ,p_ref_id       in spc_data.ref_id%type
                   ,p_langue       in spc_lang.lang_code%type default null
) return clob
is
   -- Variables
    l_return clob;
    l_template blob;
    l_registre_blob blob;
  
   -- Cursor
   cursor c_spc (p_ref_type_id  in spc_ref_type.id%type 
                   ,p_ref_id       in spc_data.ref_id%type
                   ,p_langue       in spc_lang.lang_code%type) IS
   select spc_tool.get_description_lang ( p_spc_id => t1.spc_id
                                        , p_lang   => p_langue) as label
         , t1.value as value
   from spc_data t1
   join spc_definition t2 
   on t1.spc_id = t2.id 
   where /*t2.ref_type_id = p_ref_type_id
   and*/   t1.ref_id = p_ref_id;


begin

   --

   apex_json.initialize_clob_output;
   apex_json.open_array(); -- main
   apex_json.open_object(); -- main
   apex_json.write('filename','test');

   apex_json.open_array('data'); -- data
   apex_json.open_object(); -- data

      apex_json.open_array('SPEC'); -- OPEN ARRAY SPEC

      for rec in c_spc (p_ref_type_id => p_ref_type_id
                        ,p_ref_id      => p_ref_id
                        ,p_langue      => p_langue) 
      loop
         apex_json.open_object();
         apex_json.write('NAME', rec.label);
         apex_json.write('VALUE', rec.value);
         apex_json.close_object();
      end loop;

      apex_json.close_array(); -- CLOSE ARRAY SPEC

    apex_json.close_object(); -- data
    apex_json.close_array(); -- data

    apex_json.close_object(); -- main
    apex_json.close_array(); -- main
            
    l_return := apex_json.get_clob_output;
    apex_json.free_output;
        
    return l_return;
    
end print_spc;



/*********************************************************/

function print_spc_by_code (p_ref_type_id  in spc_ref_type.id%type 
                           ,p_ref_id       in spc_data.ref_id%type
                           ,p_langue       in spc_lang.lang_code%type default null
) return clob
is
   -- Variables
    l_return clob;
    l_template blob;
    l_registre_blob blob;
  
   -- Cursor
   cursor c_spc (p_ref_type_id  in spc_ref_type.id%type 
                   ,p_ref_id       in spc_data.ref_id%type
                   ,p_langue       in spc_lang.lang_code%type) IS
   select t1.value as value
        , t2.spc_code as spc_code
   from spc_data t1
   join spc_definition t2 
   on t1.spc_id = t2.id 
   where /*t2.ref_type_id = p_ref_type_id
   and*/   t1.ref_id = p_ref_id;


begin

   --

   apex_json.initialize_clob_output;
   apex_json.open_array(); -- main
   apex_json.open_object(); -- main
   apex_json.write('filename','test');

   apex_json.open_array('data'); -- data
   apex_json.open_object(); -- data

      for rec in c_spc (p_ref_type_id => p_ref_type_id
                        ,p_ref_id      => p_ref_id
                        ,p_langue      => p_langue) 
      loop
         apex_json.write(rec.spc_code , rec.value);
      end loop;


    apex_json.close_object(); -- data
    apex_json.close_array(); -- data

    apex_json.close_object(); -- main
    apex_json.close_array(); -- main
            
    l_return := apex_json.get_clob_output;
    apex_json.free_output;
        
    return l_return;
    
end print_spc_by_code; 

end AOP_REPORT_SPC;