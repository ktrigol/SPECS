declare
    l_lang_id  spc_lang.id%type;
begin
     case :APEX$ROW_STATUS
     when 'C' then 
         -- insert new record into spc_lov
         insert into spc_lov 
            ( LIST_GROUP
            , LIST_CODE
            , VALUE_CODE
            , ACTIVE_IND
            , SYSTEM_IND
            ) values (
              :LIST_GROUP
            , :LIST_CODE
            , :VALUE_CODE
            , :ACTIVE_IND
            , :SYSTEM_IND)
         returning ID into :ID;

         -- get the language id for default language
            select id 
            into l_lang_id 
            from spc_lang 
            where default_ind = 1;

         -- insert new record into spc_lov_lang
         insert into spc_lov_lang 
            ( SPC_LANG_ID
            , SPC_LOV_ID
            , DESCRIPTION
            ) values (
              l_lang_id --:SPC_LANG_ID
            , :ID
            , :DESCRIPTION)
            
     /*when 'U' then
         update emp
            set ename  = :ENAME,
                deptno = :DEPTNO
          where rowid  = :ROWID;
     when 'D' then
         delete emp
         where rowid = :ROWID;*/
     end case;
end;