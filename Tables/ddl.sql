--> flows
insert into flw_type (id, priority, ind_active) values(1, 1, 1);
insert into flw_type (id, priority, ind_active) values(2, 2, 1);
insert into flw_type (id, priority, ind_active) values(3, 3, 1);
insert into flw_type (id, priority, ind_active) values(4, 4, 0);
insert into flw_type (id, priority, ind_active) values(5, 5, 1);

insert into flw_type_lang (flw_type_id, spc_lang_id, type_desc) values(1, 1, 'flow 1');
insert into flw_type_lang (flw_type_id, spc_lang_id, type_desc) values(2, 1, 'flow 2');
insert into flw_type_lang (flw_type_id, spc_lang_id, type_desc) values(3, 1, 'flow 3');
insert into flw_type_lang (flw_type_id, spc_lang_id, type_desc) values(4, 1, 'flow 4');
insert into flw_type_lang (flw_type_id, spc_lang_id, type_desc) values(5, 1, 'flow 5');

--> steps for flow 1
insert into flw_type_step(id, flw_type_id, display_spc_ids, note, step_number) values(1, 1, null, 'note 1', 1);
insert into flw_type_step(id, flw_type_id, display_spc_ids, note, step_number) values(2, 1, null, 'note 2', 2);
insert into flw_type_step(id, flw_type_id, display_spc_ids, note, step_number) values(3, 1, null, 'note 3', 3);
insert into flw_type_step(id, flw_type_id, display_spc_ids, note, step_number) values(4, 1, null, 'note 4', 4);
insert into flw_type_step(id, flw_type_id, display_spc_ids, note, step_number) values(5, 1, null, 'note 5', 5);

insert into flw_type_step_lang(flw_type_step_id, spc_lang_id, status) values(1, 1, 'step 1');
insert into flw_type_step_lang(flw_type_step_id, spc_lang_id, status) values(2, 1, 'step 2');
insert into flw_type_step_lang(flw_type_step_id, spc_lang_id, status) values(3, 1, 'step 3');
insert into flw_type_step_lang(flw_type_step_id, spc_lang_id, status) values(4, 1, 'step 4');
insert into flw_type_step_lang(flw_type_step_id, spc_lang_id, status) values(5, 1, 'step 5');

--> option 1 for step 1
insert into flw_type_step_option(id, flw_type_step_id, next_step_id, role_ids, mandatory_spc_ids, readonly_spc_ids, display_seq) values(1, 1, 2, null, null, null, 1);
insert into flw_type_step_option_lang(flw_type_step_option_id, spc_lang_id, button_name) values(1, 1, 'go to step 2');

--> option 2 for step 1
insert into flw_type_step_option(id, flw_type_step_id, next_step_id, role_ids, mandatory_spc_ids, readonly_spc_ids, display_seq) values(2, 1, 3, null, null, null, 2);
insert into flw_type_step_option_lang(flw_type_step_option_id, spc_lang_id, button_name) values(2, 1, 'go to step 3');

--> option 1 for step 2
insert into flw_type_step_option(id, flw_type_step_id, next_step_id, role_ids, mandatory_spc_ids, readonly_spc_ids, display_seq) values(3, 2, 1, null, null, null, 1);
insert into flw_type_step_option_lang(flw_type_step_option_id, spc_lang_id, button_name) values(3, 1, 'go to step 1');

--> option 2 for step 2
insert into flw_type_step_option(id, flw_type_step_id, next_step_id, role_ids, mandatory_spc_ids, readonly_spc_ids, display_seq) values(4, 2, 3, null, null, null, 2);
insert into flw_type_step_option_lang(flw_type_step_option_id, spc_lang_id, button_name) values(4, 1, 'go to step 3');

--> option 1 for step 3
insert into flw_type_step_option(id, flw_type_step_id, next_step_id, role_ids, mandatory_spc_ids, readonly_spc_ids, display_seq) values(5, 3, 4, null, null, null, 1);
insert into flw_type_step_option_lang(flw_type_step_option_id, spc_lang_id, button_name) values(5, 1, 'go to step 4');

--> option 1 for step 4
insert into flw_type_step_option(id, flw_type_step_id, next_step_id, role_ids, mandatory_spc_ids, readonly_spc_ids, display_seq) values(6, 1, 5, null, null, null, 1);
insert into flw_type_step_option_lang(flw_type_step_option_id, spc_lang_id, button_name) values(6, 1, 'go to step 5');