create or replace PACKAGE BODY "AOP_JSON_PKG" AS 
   
  /*------------------------------------------------------------------------- 
    Procedure Description: Générer le rapport AOP 
    Return: 
    Parameters: 
    -------------------------------------------------------------------------*/ 
  function construire_json(p_code_rapport in varchar2,p_values in varchar2,g_bind_title in out varchar2) 
    return clob 
    is 
        l_bind_title            varchar2(500); 
        l_vc_arr2               apex_t_varchar2;         
        l_return clob; 
    begin 
        -- mettre les valeurs dans un tableau 
        l_vc_arr2 := apex_string.split(p_values,':'); 
        g_bind_title := l_vc_arr2(1);
        
      --verifier le code du rapport 
      case p_code_rapport 
        when 'PRINT_SPCS' then                
                --g_bind_title := l_vc_arr2(1);
                l_return := aop_report_spc.print_spc (p_ref_type_id  => l_vc_arr2(2)
                                                     ,p_ref_id       => l_vc_arr2(3)
                                                     ,p_langue       => null); 
        when 'PRINT_SPCS_BY_CODE' then
               l_return := aop_report_spc.print_spc_by_code (p_ref_type_id  => l_vc_arr2(2)
                                                            ,p_ref_id       => l_vc_arr2(3)
                                                            ,p_langue       => null); 
        else 
                l_return := null; 
        end case;  
        return l_return; 
       
        exception  when others then  raise; 
    end construire_json;    
END AOP_JSON_PKG;
