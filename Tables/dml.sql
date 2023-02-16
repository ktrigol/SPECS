-- create views
create or replace view flw_type_v as 
select 
    t.id                              id,
    t.priority                        priority,
    t.ind_active                      ind_active,
    t.created                         created,
    t.created_by                      created_by,
    t.updated                         updated,
    t.updated_by                      updated_by,
    tl.id                             lang_id,
    tl.spc_lang_id                    spc_lang_id,
    case when tl.type_desc is not null 
      then tl.type_desc 
    else 
      flw_util.get_missing_language() 
    end as type_desc,
    tl.created                        desc_created,
    tl.created_by                     desc_created_by,
    tl.updated                        desc_updated,
    tl.updated_by                     desc_updated_by
from flw_type t
left join flw_type_lang tl
  on t.id = tl.flw_type_id
  and tl.spc_lang_id = flw_util.get_language_id()
  
/

create or replace view flw_type_step_v as 
select 
    t.id                              id,
    t.flw_type_id                     flw_type_id,
    t.display_spc_ids                 display_spc_ids,
    t.note                            note,
    t.step_number                     step_number,
    t.created                         created,
    t.created_by                      created_by,
    t.updated                         updated,
    t.updated_by                      updated_by,

    tl.id                             lang_id,
    tl.spc_lang_id                    spc_lang_id,  
    case when tl.status is not null 
      then tl.status 
    else 
      flw_util.get_missing_language() 
    end as status,
    tl.created                        desc_created,
    tl.created_by                     desc_created_by,
    tl.updated                        desc_updated,
    tl.updated_by                     desc_updated_by
from flw_type_step t
left join flw_type_step_lang tl
  on t.id = tl.flw_type_step_id
  and tl.spc_lang_id = flw_util.get_language_id()
  
/

create or replace view flw_type_step_option_v as 
select 
    t.id                              id,
    t.flw_type_step_id                flw_type_step_id,
    t.next_step_id                    next_step_id,
    t.role_ids                        role_ids,
    t.mandatory_spc_ids               mandatory_spc_ids,
    t.readonly_spc_ids                readonly_spc_ids,
    t.display_seq                     display_seq,
    t.created                         created,
    t.created_by                      created_by,
    t.updated                         updated,
    t.updated_by                      updated_by,
    t.css_button                      css_button,

    tl.id                             lang_id,
    case when tl.button_name is not null 
      then tl.button_name 
    else 
      flw_util.get_missing_language() 
    end as button_name,
    tl.created                        desc_created,
    tl.created_by                     desc_created_by,
    tl.updated                        desc_updated,
    tl.updated_by                     desc_updated_by
from flw_type_step_option t
left join flw_type_step_option_lang tl
  on t.id = tl.flw_type_step_option_id
  and tl.spc_lang_id = flw_util.get_language_id()