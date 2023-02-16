create or replace PACKAGE BODY "INC_CONTRAT_API" is
--------------------------------------------------------------------------------
-- ***** CONSTANTES *****
--------------------------------------------------------------------------------  
function get_co_type_r return varchar2 deterministic as
begin
    return inc_contrat_api.co_type_r;
end get_co_type_r;

function get_co_type_p return varchar2 deterministic as
begin
    return inc_contrat_api.co_type_p;
end get_co_type_p;

function get_co_statut_en_cours return varchar2 deterministic as
begin
    return inc_contrat_api.co_statut_en_cours;
end get_co_statut_en_cours;

function get_co_statut_soumis return varchar2 deterministic as
begin
    return inc_contrat_api.co_statut_soumis;
end get_co_statut_soumis;
    
function get_co_statut_completer return varchar2 deterministic
as
begin
    return inc_contrat_api.co_statut_completer;
end get_co_statut_completer;
--------------------------------------------------------------------------------
function get_co_statut_annuler return varchar2 deterministic
as
begin
    return inc_contrat_api.co_statut_annuler;
end get_co_statut_annuler;

-----------------------------------------------------------------------------------------------------------------------------
-- fonction privee retrounant la portion heure d'une date ou, s'il n'y en a pas, une heure fictive en fonction d'une séquence
    function trouver_heure (p_date in date
                           ,p_cnt  in integer
                           )   return varchar2
    is
        l_heure                       varchar2(6 byte);
    begin
        l_heure := to_char(p_date, 'hh24miss');
        if l_heure = '000000' then
            l_heure := lpad(trunc(mod(p_cnt, 86400) / 3600), 2, '0') || lpad(trunc(mod(p_cnt, 3600) /60), 2, '0') || lpad(mod(p_cnt, 60), 2, '0');
        end if;
        if l_heure = '000000' then
            l_heure := '120001';
        end if;
        return l_heure;
    end trouver_heure;

--------------------------------------------------------------
-- fonction d'affectation pour la table inc_contrat
    function affect_contrat (p_valeurs       in     notes_data.t_table_valeurs
                            )            return     inc_contrat%rowtype
    is
        l_ligne                                     inc_contrat%rowtype;
        l_lne                                       pls_integer := 28;
    begin
        if p_valeurs.exists('id') then
            l_ligne.id := p_valeurs('id');
        end if;
        if p_valeurs.exists('contrat_no') then l_lne := 31;
            l_ligne.contrat_no := p_valeurs('contrat_no');
        end if;
        if p_valeurs.exists('dossier_no') then l_lne := 34;
            l_ligne.dossier_no := p_valeurs('dossier_no');
        end if;
        if p_valeurs.exists('dossier_id') then
            l_ligne.dossier_id := p_valeurs('dossier_id');
        end if;
        if p_valeurs.exists('code_type') then l_lne := 37;
            l_ligne.code_type := p_valeurs('code_type');
        end if;
        if p_valeurs.exists('code_categorie') then l_lne := 40;
            l_ligne.code_categorie := p_valeurs('code_categorie');
        end if;
        if p_valeurs.exists('code_statut') then
            l_ligne.code_statut := p_valeurs('code_statut');
        end if;
        if p_valeurs.exists('statut') then l_lne := 43;
            l_ligne.statut := p_valeurs('statut');
        else
            l_ligne.statut := 'À facturer';
        end if;
        if p_valeurs.exists('terme_paiement') then l_lne := 48;
            l_ligne.terme_paiement := p_valeurs('terme_paiement');
        end if;
        if p_valeurs.exists('code_quittance') then l_lne := 51;
            if substr(p_valeurs('code_quittance'), 1, 7) = 'Non pay' then
                l_ligne.code_quittance := 'NP';
            else
                l_ligne.code_quittance := substr(p_valeurs('code_quittance'), 1, 3);
            end if;
        else l_lne := 57;
            l_ligne.code_quittance := 'NP';
        end if;
        if p_valeurs.exists('cree_le') then l_lne := 60;
            l_ligne.cree_le := lnd_notes_data.format_date(p_valeurs('cree_le'));
        end if;
        if p_valeurs.exists('cree_par') then l_lne := 63;
            l_ligne.cree_par := p_valeurs('cree_par');
        end if;
        if p_valeurs.exists('modifie_le') then l_lne := 66;
            l_ligne.modifie_le := lnd_notes_data.format_date(p_valeurs('modifie_le'));
        end if;
        if p_valeurs.exists('modifie_par') then l_lne := 69;
            l_ligne.modifie_par := p_valeurs('modifie_par');
        end if;
        if p_valeurs.exists('ind_incomplet') then l_lne := 72;
            l_ligne.ind_incomplet := p_valeurs('ind_incomplet');
        else
            l_ligne.ind_incomplet := 0;
        end if;
        if p_valeurs.exists('concession_no') then l_lne := 77;
            l_ligne.concession_no := p_valeurs('concession_no');
        end if;
        if p_valeurs.exists('code_section') then l_lne := 80;
            l_ligne.code_section := p_valeurs('code_section');
        end if;
        if p_valeurs.exists('nom_representant') then l_lne := 83;
            l_ligne.nom_representant := p_valeurs('nom_representant');
        end if;
        if p_valeurs.exists('incitatif') then l_lne := 86;
            l_ligne.incitatif := p_valeurs('incitatif');
        end if;
        if p_valeurs.exists('code_maison_funeraire') then l_lne := 89;
            if length(p_valeurs('code_maison_funeraire')) <= 5 then
                l_ligne.code_maison_funeraire := p_valeurs('code_maison_funeraire');
            else
                l_ligne.nom_maison_funeraire  := p_valeurs('code_maison_funeraire');
            end if;
        end if;
        if p_valeurs.exists('nom_maison_funeraire') and substr(p_valeurs('nom_maison_funeraire'), 1, 6) <> 'Aucune' then l_lne := 96;
            l_ligne.nom_maison_funeraire := p_valeurs('nom_maison_funeraire');
        end if;
        if p_valeurs.exists('nom_dir_funeraire') then l_lne := 99;
            l_ligne.nom_dir_funeraire := substr(p_valeurs('nom_dir_funeraire'), 1, 100);
        end if;
        if p_valeurs.exists('raison_statut') then l_lne := 102;
            l_ligne.raison_statut := p_valeurs('raison_statut');
        end if;
        if p_valeurs.exists('precision') then l_lne := 105;
            l_ligne.precision := p_valeurs('precision');
        end if;
        if p_valeurs.exists('signe_le') then l_lne := 108;
            l_ligne.signe_le := lnd_notes_data.format_date(p_valeurs('signe_le'));
        end if;
        if p_valeurs.exists('date_achat') then l_lne := 111;
            l_ligne.date_achat := lnd_notes_data.format_date(p_valeurs('date_achat'));
        end if;
        if p_valeurs.exists('annule_par') then l_lne := 114;
            l_ligne.annule_par := p_valeurs('annule_par');
        end if;
        if p_valeurs.exists('annule_le') then l_lne := 117;
            l_ligne.annule_le := lnd_notes_data.format_date(p_valeurs('annule_le'));
        end if;
        if p_valeurs.exists('raison_annule') then l_lne := 120;
            l_ligne.raison_annule := p_valeurs('raison_annule');
        end if;
        if p_valeurs.exists('donnees_compl') then l_lne := 123;
            l_ligne.donnees_compl := p_valeurs('donnees_compl');
        end if;
        if p_valeurs.exists('service_rendu_le') then l_lne := 126;
            l_ligne.service_rendu_le := lnd_notes_data.format_date(p_valeurs('service_rendu_le'));
        end if;
        if p_valeurs.exists('notes_id') then l_lne := 129;
            l_ligne.notes_id := p_valeurs('notes_id');
        end if;
        if p_valeurs.exists('notes_unid') then l_lne := 132;
            l_ligne.notes_unid := p_valeurs('notes_unid');
        end if;
        if p_valeurs.exists('code_statut') then l_lne := 135;
            l_ligne.code_statut := p_valeurs('code_statut');
        end if;
        if p_valeurs.exists('code_incitatif') then l_lne := 138;
            l_ligne.code_incitatif := p_valeurs('code_incitatif');
        end if;
        if p_valeurs.exists('afficher_precision') then l_lne := 141;
            l_ligne.afficher_precision := p_valeurs('afficher_precision');
        else
            l_ligne.afficher_precision := 0;
        end if;
        if p_valeurs.exists('duree_terme') then l_lne := 146;
            l_ligne.duree_terme := p_valeurs('duree_terme');
        end if;
        if p_valeurs.exists('terme_location') then l_lne := 149;
            l_ligne.terme_location := p_valeurs('terme_location');
        end if;
        if p_valeurs.exists('contrat_categorie_id') then l_lne := 152;
            l_ligne.contrat_categorie_id := p_valeurs('contrat_categorie_id');
        end if;
        if p_valeurs.exists('id_maison_funeraire') then l_lne := 154;
            l_ligne.id_maison_funeraire := p_valeurs('id_maison_funeraire');
        end if;
        if p_valeurs.exists('urgent') then l_lne := 158;
            l_ligne.urgent := p_valeurs('urgent');
        end if;
        if p_valeurs.exists('code_statut_facturation') then l_lne := 159;
            l_ligne.code_statut_facturation := p_valeurs('code_statut_facturation');
        end if;

        return l_ligne;
    exception
        when others then
            dbms_output.put_line('INC_CONTRAT.affect_contrat(' || l_lne || ') - exception: ' || sqlerrm);
            raise;
    end affect_contrat;

--------------------------------------------------------------
-- procedure d'insertion pour la table inc_contrat
   procedure cre_contrat (p_contrat_rec in out inc_contrat%rowtype)
   is 
   begin
      insert into inc_contrat (id,                           contrat_no,                     dossier_no,                        code_type
                              ,code_categorie,               statut,                         terme_paiement,                    code_quittance
                              ,cree_le,                      cree_par,                       modifie_le,                        modifie_par
                              ,ind_incomplet,                concession_no,                  code_section,                      nom_representant
                              ,incitatif
                              ,raison_statut,                precision,                      signe_le,                          code_maison_funeraire
                              ,date_achat,                   annule_par,                     annule_le,                         nom_maison_funeraire
                              ,raison_annule,                service_rendu_le,               donnees_compl,                     nom_dir_funeraire
                              ,notes_id,                     notes_unid,                     code_statut,                       code_incitatif
                              ,duree_terme,                  terme_location,                 afficher_precision
                              ,contrat_categorie_id,         dossier_id,                     id_maison_funeraire,               urgent
                              ,code_statut_facturation
                              )
                       values (p_contrat_rec.id,             p_contrat_rec.contrat_no,       p_contrat_rec.dossier_no,          p_contrat_rec.code_type
                              ,p_contrat_rec.code_categorie, p_contrat_rec.statut,           p_contrat_rec.terme_paiement,      p_contrat_rec.code_quittance
                              ,p_contrat_rec.cree_le,        p_contrat_rec.cree_par,         p_contrat_rec.modifie_le,          p_contrat_rec.modifie_par
                              ,p_contrat_rec.ind_incomplet,  p_contrat_rec.concession_no,    p_contrat_rec.code_section,        p_contrat_rec.nom_representant
                              ,p_contrat_rec.incitatif
                              ,p_contrat_rec.raison_statut,  p_contrat_rec.precision,        p_contrat_rec.signe_le,            p_contrat_rec.code_maison_funeraire
                              ,p_contrat_rec.date_achat,     p_contrat_rec.annule_par,       p_contrat_rec.annule_le,           p_contrat_rec.nom_maison_funeraire
                              ,p_contrat_rec.raison_annule,  p_contrat_rec.service_rendu_le, p_contrat_rec.donnees_compl,       p_contrat_rec.nom_dir_funeraire
                              ,p_contrat_rec.notes_id,       p_contrat_rec.notes_unid,       p_contrat_rec.code_statut,         p_contrat_rec.code_incitatif
                              ,p_contrat_rec.duree_terme,    p_contrat_rec.terme_location,   p_contrat_rec.afficher_precision
                              ,p_contrat_rec.contrat_categorie_id, p_contrat_rec.dossier_id, p_contrat_rec.id_maison_funeraire, p_contrat_rec.urgent
                              ,p_contrat_rec.code_statut_facturation)
                returning  id into p_contrat_rec.id;
   end cre_contrat;

--------------------------------------------------------------
-- procedure de modification de la table inc_contrat
   procedure mod_contrat (p_contrat_rec in out inc_contrat%rowtype
                         ,p_md5         in     varchar2 default null)
   is 
      l_md5 varchar2(32767) := null;
   begin
       --dbms_output.put_line('INC_CONTRAT_API.merge_contrat - contrat: ' || p_contrat_rec.contrat_no);
       if p_md5 is not null then
         for c1 in (select c.* from inc_contrat c
                     where c.id = p_contrat_rec.id for update)
         loop
            l_md5 := gen_contrat_md5(c1);
         end loop;
      end if;

      if (p_md5 is null) or (l_md5 = p_md5) then 
         update inc_contrat 
         set
         dossier_no            = p_contrat_rec.dossier_no,
         code_type             = p_contrat_rec.code_type,
         code_categorie        = p_contrat_rec.code_categorie,
         statut                = p_contrat_rec.statut,
         terme_paiement        = p_contrat_rec.terme_paiement,
         code_quittance        = p_contrat_rec.code_quittance,
         cree_le               = p_contrat_rec.cree_le,
         cree_par              = p_contrat_rec.cree_par,
         modifie_le            = p_contrat_rec.modifie_le,
         modifie_par           = p_contrat_rec.modifie_par,
         ind_incomplet         = p_contrat_rec.ind_incomplet,
         concession_no         = p_contrat_rec.concession_no,
         code_section          = p_contrat_rec.code_section,
         nom_representant      = p_contrat_rec.nom_representant,
         incitatif             = p_contrat_rec.incitatif,
         code_maison_funeraire = p_contrat_rec.code_maison_funeraire,
         nom_maison_funeraire  = p_contrat_rec.nom_maison_funeraire,
         nom_dir_funeraire     = p_contrat_rec.nom_dir_funeraire,
         raison_statut         = p_contrat_rec.raison_statut,
         precision             = p_contrat_rec.precision,
         signe_le              = p_contrat_rec.signe_le,
         date_achat            = p_contrat_rec.date_achat,
         annule_par            = p_contrat_rec.annule_par,
         annule_le             = p_contrat_rec.annule_le,
         raison_annule         = p_contrat_rec.raison_annule,
         service_rendu_le      = p_contrat_rec.service_rendu_le,
         donnees_compl         = p_contrat_rec.donnees_compl,
         code_statut           = p_contrat_rec.code_statut,      
         code_incitatif        = p_contrat_rec.code_incitatif,   
         duree_terme           = p_contrat_rec.duree_terme,       
         terme_location        = p_contrat_rec.terme_location,   
         afficher_precision    = p_contrat_rec.afficher_precision
         where id              = p_contrat_rec.id;
      else
         raise_application_error (-20001,'Cet enregistrement a été modifié par un autre utilisateur; veuillez interroger à nouveau les données.');  
      end if;
    end mod_contrat;

--------------------------------------------------------------
-- procedure de mise à jour du code statut dans la table inc_contrat
   procedure mod_statut  (p_contrat_id  in number
                         ,p_code_statut in varchar2
                         ,p_raison      in varchar2 default null)
   is
       l_dossier_no                        inc_contrat.dossier_no%type;
   begin
      update inc_contrat c
         set c.code_statut   = p_code_statut
            ,c.annule_le     = case p_code_statut when 'ANN' then sysdate else null end 
            ,c.annule_par    = case p_code_statut when 'ANN' then nvl(sys_context('APEX$SESSION','APP_USER'),user) else null end
            ,c.raison_annule = case p_code_statut when 'ANN' then p_raison else null end
            ,c.signe_le      = case p_code_statut when 'SIG' then sysdate else c.signe_le end 
            ,c.recupere_le  = case p_code_statut when 'RECUP' then sysdate end 
            ,c.recupere_par = case p_code_statut when 'RECUP' then nvl(sys_context('APEX$SESSION','APP_USER'),user) end 
       where c.id            = p_contrat_id;
      -- Répercuter la mise à jour au niveau du dossier.
      /*for r in (select c1.dossier_no ,count(distinct c2.id) cnt from inc_contrat c1, inc_contrat c2
                 where c1.id = p_contrat_id and c2.dossier_no (+) = c1.dossier_no and c2.code_statut (+) <> c1.code_statut
                 group by c1.dossier_no having count(distinct c2.id) = 0)
      loop
         update inc_dossier d
            set d.code_statut   = p_code_statut
               ,d.annule_le     = case p_code_statut when 'ANN' then sysdate else null end 
               ,d.annule_par    = case p_code_statut when 'ANN' then nvl(sys_context('APEX$SESSION','APP_USER'),user) else null end
               ,d.raison_annule = case p_code_statut when 'ANN' then p_raison else null end
          where d.dossier_no    = r.dossier_no;
      end loop;*/
   end mod_statut;

--------------------------------------------------------------
-- procedure de suppression de la table inc_contrat
   procedure sup_contrat (p_id in number)
   is 
   begin
      raise_application_error (-20001,'La suppression d''un contrat n''est pas permise.');  
      delete from inc_contrat 
      where ID = p_id;
   end sup_contrat;

--------------------------------------------------------------
--  fonction de creation/modification pour la table inc_contrat
    function merge_contrat  (p_contrat_rec   in   notes_data.t_table_valeurs
                            ,p_donnees_compl in   varchar2
                            )          return     inc_contrat.id%type
    is
        l_rec                                     inc_contrat%rowtype;
        l_rec_db                                  inc_contrat%rowtype;
        l_md5                                     varchar2(32767) := null;
        l_md5_db                                  varchar2(32767) := null;
    begin
        l_rec               := affect_contrat(p_contrat_rec);
        l_rec.donnees_compl := p_donnees_compl;
      --dbms_output.put_line('INC_CONTRAT_API.merge_contrat - contrat: ' || l_rec.contrat_no);
        trouver_contrat(l_rec.id , l_rec.notes_unid ,l_rec_db ,l_md5_db);
        if l_md5_db is null then
            cre_contrat(l_rec);
        else
            l_md5    := gen_contrat_md5(l_rec);
            l_rec.id := l_rec_db.id;
            if l_md5 <> l_md5_db then
                mod_contrat(l_rec);
            end if;
        end if;
        return l_rec.id;
    end merge_contrat;

--------------------------------------------------------------
-- procedure de recherche dans la table inc_contrat
    procedure trouver_contrat (p_id          in     number
                              ,p_notes_unid  in     varchar2
                              ,p_contrat_rec    out inc_contrat%rowtype)
   is 
       l_dummy                                     varchar2(32676);
   begin
      trouver_contrat (p_id  ,p_notes_unid ,p_contrat_rec, l_dummy);
   end trouver_contrat;

--------------------------------------------------------------
-- procedure de recherche dans la table inc_contrat (avec indicateur de modification)
   procedure trouver_contrat (p_id          in     number
                             ,p_notes_unid  in     varchar2
                             ,p_contrat_rec    out inc_contrat%rowtype
                             ,p_md5            out varchar2)
   is 
   begin
      for r1 in (select c0.* from inc_contrat c0  where c0.id         = p_id and p_id is not null union
                 select c2.* from inc_contrat c2  where c2.notes_unid = p_notes_unid and p_id is null and p_notes_unid is not null)
      loop
         p_contrat_rec             := r1;

         p_md5 := gen_contrat_md5(p_contrat_rec);
      end loop;
   end trouver_contrat;

--------------------------------------------------------------
-- fonction de generation de l'indicateur de modification pour la table inc_contrat
   function gen_contrat_md5 (p_contrat_rec in inc_contrat%rowtype
                            )          return varchar2 
   is 
   begin
      if p_contrat_rec.code_statut is null then -- Version provenant de la migration Notes
          return apex_util.get_hash(apex_t_varchar2(p_contrat_rec.dossier_no,         p_contrat_rec.code_type,        p_contrat_rec.code_categorie,        p_contrat_rec.statut
                                                   ,p_contrat_rec.terme_paiement,     p_contrat_rec.code_quittance,   p_contrat_rec.ind_incomplet,         p_contrat_rec.concession_no
                                                   ,p_contrat_rec.code_section,       p_contrat_rec.nom_representant, p_contrat_rec.code_maison_funeraire, p_contrat_rec.nom_maison_funeraire
                                                   ,p_contrat_rec.incitatif
                                                   ,p_contrat_rec.nom_dir_funeraire,  p_contrat_rec.raison_statut,    p_contrat_rec.precision,             p_contrat_rec.signe_le
                                                   ,p_contrat_rec.date_achat,         p_contrat_rec.annule_par,       p_contrat_rec.annule_le,             p_contrat_rec.raison_annule
                                                   ,p_contrat_rec.service_rendu_le,   p_contrat_rec.donnees_compl));--p_contrat_rec.code_statut,           p_contrat_rec.code_incitatif
                                                 --,p_contrat_rec.duree_terme,        p_contrat_rec.terme_location,   p_contrat_rec.afficher_precision));
      else
          return apex_util.get_hash(apex_t_varchar2(p_contrat_rec.dossier_no,         p_contrat_rec.code_type,        p_contrat_rec.code_categorie,        p_contrat_rec.statut
                                                   ,p_contrat_rec.terme_paiement,     p_contrat_rec.code_quittance,   p_contrat_rec.ind_incomplet,         p_contrat_rec.concession_no
                                                   ,p_contrat_rec.code_section,       p_contrat_rec.nom_representant, p_contrat_rec.code_maison_funeraire, p_contrat_rec.nom_maison_funeraire
                                                   ,p_contrat_rec.incitatif
                                                   ,p_contrat_rec.nom_dir_funeraire,  p_contrat_rec.raison_statut,    p_contrat_rec.precision,             p_contrat_rec.signe_le
                                                   ,p_contrat_rec.date_achat,         p_contrat_rec.annule_par,       p_contrat_rec.annule_le,             p_contrat_rec.raison_annule
                                                   ,p_contrat_rec.service_rendu_le,   p_contrat_rec.donnees_compl,    p_contrat_rec.code_statut,           p_contrat_rec.code_incitatif
                                                   ,p_contrat_rec.duree_terme,        p_contrat_rec.terme_location,   p_contrat_rec.afficher_precision));
      end if;
   end gen_contrat_md5;

-----------------------------------------------------------------------------
-- fonction generant un identifiant unique visible pour la table des contrats
   function gen_contrat_no  (p_code_type      in varchar2
                            ,p_code_categorie in varchar2 default null
                            )             return varchar2
   is
       l_contrat_no                               varchar2(20);
       l_cnt                                      integer := 1;
       l_num                                      number(7, 0);
   begin
       l_contrat_no := p_code_type || to_char(sysdate, 'yyyymmddhh24miss');
       loop
           select count(*) into l_cnt from inc_contrat c where c.contrat_no = l_contrat_no;
           exit when l_cnt = 0;
           l_num        := to_number(substr(l_contrat_no, 10)) + 1;
           l_contrat_no := substr(l_contrat_no, 1, 9) || lpad(l_num, 6, '0');
        end loop;
        return l_contrat_no;
    end gen_contrat_no;

-----------------------------------------------------------------------------------------------------------------------------
--  Procédure permettant de transférer les données sur les conjoints de la table INC_CONTRAT à la table INC_CONTACT
    procedure transferer_conjoints (p_nbr_max    in number default 2000000
                                   ,p_contrat_id in number default null)
    is
        l_cnt_add     integer := 0;
        l_cnt_rel     integer := 0;
        l_cnt_chg     integer := 0;
        l_cnt_mod     integer := 0;
        l_cnt_non     integer := 0;
        l_ajout       integer := 0;
        l_histo       integer := 0;
        l_modif       integer := 0;
        l_addrel      integer := 0;
        l_id          number;
        l_ctr_id      number;
        l_contact_no  varchar2(20);
        l_row         notes_data.t_table_valeurs;
        l_cct_rec     inc_contact_api.t_contact_enr;
        l_cnj_rec     inc_contact_api.t_contact_enr;
        l_cc_rec      inc_contact_contrat%rowtype;
        l_ccth_rec    inc_contact_histo_api.t_contact_histo_enr;
        cursor c_cnj (p_contact_no varchar2) is
            select c.* from inc_contact c
             where c.contact_no = p_contact_no;
        cursor c_oth (p_contrat_id number
                     ,p_nom        varchar2
                     ,p_prenom     varchar2) is
            select c.* from inc_contact c, inc_contact_contrat cc
             where c.contact_nom    = p_nom        and c.contact_prenom = p_prenom
               and cc.contrat_id    = p_contrat_id and c.contact_no     = cc.contact_no;
    begin
        select max(id) into l_ajout from inc_contact;
        select max(id) into l_histo from inc_contact_histo;
        dbms_output.put_line(' Dernier contact: ' || l_ajout || '; Dernier contact histo: ' || l_histo);
        for r in (  select ctr.*, cct.contact_no, cct.contact_nom, cct.contact_prenom, cct.code_sexe
                          ,json_value(ctr.donnees_compl,'$.items_non_attribues.NomCJ')    nom_cj
                          ,json_value(ctr.donnees_compl,'$.items_non_attribues.PrenomCJ') prenom_cj
                          ,json_value(ctr.donnees_compl,'$.items_non_attribues.SexeCJ')   code_sexe_cj
                          ,case when cct.contact_no is null then null
                                when json_value(ctr.donnees_compl,'$.items_non_attribues.NomCJ')              collate binary_ai = cct.contact_nom and
                                     nvl(json_value(ctr.donnees_compl,'$.items_non_attribues.PrenomCJ'), '*') collate binary_ai = nvl(cct.contact_prenom, '*')
                                then 1 else 0 end nom_egal
                          ,case when cct.contact_no is null then null
                                when decode(json_value(ctr.donnees_compl,'$.items_non_attribues.SexeCJ'), null, '*', '1', 'M', '0', 'F'
                                           ,json_value(ctr.donnees_compl,'$.items_non_attribues.SexeCJ')) = nvl(cct.code_sexe, '*')
                                then 1 else 0 end sex_egal
                          ,cc2.type_contact
                          ,cc2.contact_no autre_contact_no
                      from inc_contrat ctr, inc_contact_contrat cc, inc_contact cct, inc_contact_contrat cc2
                     where json_value(ctr.donnees_compl,'$.items_non_attribues.NomCJ') like '%' 
                       and rownum < p_nbr_max and ctr.id = nvl(p_contrat_id, ctr.id)
                       and cc.contrat_id    (+) = ctr.id
                       and cc.type_contact  (+) = 'CNJ'
                       and cct.contact_no   (+) = cc.contact_no
                       and cc2.contrat_id   (+) = ctr.id
                       and cc2.type_contact (+) = case when ctr.code_categorie = 'CON' then 'CON'
                                                       when ctr.code_type      = 'P'   then 'BEN'
                                                       when ctr.code_categorie = 'SEP' then 'DEF'
                                                       else 'REF' end)
        loop
            l_row.delete;
            l_ajout   := 0;
            l_histo   := 0;
            l_modif   := 0;
            l_addrel  := 0;
            l_ctr_id  := r.id;
            if r.contact_no is null then
                open  c_oth(r.id, r.nom_cj, r.prenom_cj);
                fetch c_oth into l_cnj_rec;
                if c_oth%found then
                    l_contact_no := l_cnj_rec.contact_no;
                    l_addrel := 1;
                  --dbms_output.put_line('Branche 0: Addrel (' || r.id || ')'); 
                else
                    if r.autre_contact_no is null then
                        l_contact_no := 'C' || to_char(r.cree_le, 'yyyymmdd') || trouver_heure(r.cree_le, l_cnt_add) || 'CJ';
                    else 
                        l_contact_no := r.autre_contact_no || 'CJ';
                    end if;
                    open  c_cnj(l_contact_no);
                    fetch c_cnj into l_cnj_rec;
                    if c_cnj%notfound then
                        l_ajout  := 1;
                      --dbms_output.put_line('Branche 1: ajout (' || r.id || ')'); 
                    elsif chaine_indexee(l_cnj_rec.contact_nom)    <> chaine_indexee(r.nom_cj) or 
                          chaine_indexee(l_cnj_rec.contact_prenom) <> chaine_indexee(r.prenom_cj) then
                      --dbms_output.put_line('Comparaison ' || l_cnj_rec.contact_no || ': ' || l_cnj_rec.contact_nom || ', ' || 
                      --                     r.nom_cj || ', ' || l_cnj_rec.contact_prenom || ', ' || r,prenom_cj);
                      --dbms_output.put_line('Branche 2: Histo (' || r.id || ')'); 
                        l_histo  := 1;
                        l_addrel := 1;
                    else
                      --dbms_output.put_line('Branche 3: Addrel (' || r.id || ')'); 
                        l_addrel := 1;
                    end if;
                    close c_cnj;
    /*          else
                    l_contact_no := null;
                    l_ajout      := 1;
                  --dbms_output.put_line('Branche 4: Ajout (' || r.id || ')'); */
                end if;
                close c_oth;
            elsif r.nom_egal = 1 then
                if r.sex_egal = 1 or r.code_sexe_cj is null then
                    l_cnt_non := l_cnt_non + 1;
                  --dbms_output.put_line('Branche 5: touche pas (' || r.id || ')'); 
                else
                    l_cnt_mod := l_cnt_mod + 1;
                    l_modif   := 1;
                  --dbms_output.put_line('Branche 6: Modif (' || r.id || ')'); 
                    update inc_contact c 
                       set c.code_sexe = case r.code_sexe_cj when '1' then 'M' when '0' then 'F' else r.code_sexe_cj end
                     where c.contact_no = r.contact_no;
                end if;
            else
                l_contact_no := r.contact_no;
                l_histo := 1;
              --dbms_output.put_line('Branche 7: Histo (' || r.id || ')'); 
              --dbms_output.put_line('Comparaison ' || l_cnj_rec.contact_no || ': '  || r.contact_nom || ', ' || r.nom_cj || ', ' || r.contact_prenom || ', ' || r.prenom_cj);
            end if;
            if l_ajout = 1 then
                l_cnt_add := l_cnt_add + 1;
                if l_contact_no is not null then
                    l_row('contact_no')     := l_contact_no;
                end if;
                l_row('contact_nom')    := r.nom_cj;
                l_row('contact_prenom') := r.prenom_cj;
                l_row('code_sexe')      := case r.code_sexe_cj when '1' then 'M' when '0' then 'F' else r.code_sexe_cj end;
                l_row('cree_le')        := to_char(r.cree_le, 'YYYYMMDD') || 'T' || trouver_heure(r.cree_le, l_cnt_add);
                l_cct_rec               := inc_contact_api.affect_contact(l_row);
                l_cct_rec.id            := null;
                l_cct_rec.notes_unid    := l_cct_rec.contact_no;
                l_cct_rec.nom_indexe    := chaine_indexee(l_cct_rec.contact_nom);
                l_cct_rec.cree_le       := r.cree_le;
                l_cct_rec.cree_par      := r.cree_par;
                l_cct_rec.modifie_le    := r.modifie_le;
                l_cct_rec.modifie_par   := r.modifie_par;
                inc_contact_api.cre_contact(l_cct_rec);
                l_cc_rec.id             := null;
                l_cc_rec.contrat_id     := r.id;
                l_cc_rec.type_contact   := 'CNJ';
                l_cc_rec.contact_no     := l_cct_rec.contact_no;
                l_cc_rec.cree_le        := l_cct_rec.cree_le;
                l_cc_rec.cree_par       := l_cct_rec.cree_par;
                l_cc_rec.modifie_le     := l_cct_rec.modifie_le;
                l_cc_rec.modifie_par    := l_cct_rec.modifie_par;
                inc_contact_contrat_api.cre_contact_contrat(l_cc_rec);
            elsif l_histo = 1 then
              --dbms_output.put_line('Mise à jour  ' || l_contact_no);
                l_cnt_chg := l_cnt_chg + 1;
                l_row('contact_no')     := l_contact_no;
                l_row('dossier_no')     := r.dossier_no;
                l_row('contact_nom')    := nvl(r.contact_nom,    l_cnj_rec.contact_nom);
                l_row('contact_prenom') := nvl(r.contact_prenom, l_cnj_rec.contact_prenom);
                l_row('code_sexe')      := case r.code_sexe_cj when '1' then 'M' when '0' then 'F' else r.code_sexe_cj end;
                l_row('contrat_no')     := r.contrat_no;
                l_ccth_rec := inc_contact_histo_api.affect_contact_histo(l_row);
                l_ccth_rec.seq_no       := 1;
                l_ccth_rec.type_doublon := 'CNJ';
                l_ccth_rec.cree_le      := r.cree_le;
                l_ccth_rec.cree_par     := r.cree_par;
                l_ccth_rec.modifie_le   := r.modifie_le;
                l_ccth_rec.modifie_par  := r.modifie_par;
                l_ccth_rec.nom_indexe   := chaine_indexee(l_ccth_rec.contact_nom);
                l_id := inc_contact_histo_api.merge_contact_histo(l_ccth_rec, 'CNJ');
                update inc_contact c 
                   set c.code_sexe      = l_ccth_rec.code_sexe
                      ,c.contact_nom    = r.nom_cj
                      ,c.contact_prenom = r.prenom_cj
                 where c.contact_no     = l_contact_no;
            end if;
            if l_addrel = 1 then
                l_cnt_rel := l_cnt_rel + 1;
                l_cc_rec.id             := null;
                l_cc_rec.contrat_id     := r.id;
                l_cc_rec.type_contact   := 'CNJ';
                l_cc_rec.contact_no     := l_contact_no;
                l_cc_rec.cree_le        := r.cree_le;
                l_cc_rec.cree_par       := r.cree_par;
                l_cc_rec.modifie_le     := r.modifie_le;
                l_cc_rec.modifie_par    := r.modifie_par;
                inc_contact_contrat_api.cre_contact_contrat(l_cc_rec);
            end if;
            if mod(l_cnt_add + l_cnt_chg + l_cnt_mod + l_cnt_rel, 500) = 0 then
                commit;
            end if;
        end loop;
        dbms_output.put_line(l_cnt_add || ' Contacts ajoutés; '    || l_cnt_chg || ' changés; ' || l_cnt_mod || ' modifiés; ' || 
                             l_cnt_rel || ' relations ajoutées; '  || l_cnt_non || ' laissés tels quels');
        commit;
    exception
        when others then
            if l_ajout = 1 then
                dbms_output.put_line(l_cct_rec.notes_unid || ', ' || l_contact_no || ', ' || l_cct_rec.contact_nom || ', ' ||   l_cct_rec.contact_prenom  || ', ' || l_ctr_id);
            elsif l_histo = 1 then
                dbms_output.put_line(l_contact_no || ', ' || l_ccth_rec.contact_nom || ', ' || l_ccth_rec.contact_prenom  || ', ' || l_ctr_id);
            else
                dbms_output.put_line(l_contact_no || ', ' ||  l_ctr_id);
            end if;
            dbms_output.put_line(l_cnt_add || ' Contacts ajoutés; '    || l_cnt_chg || ' changés; ' || l_cnt_mod || ' modifiés; ' || 
                                 l_cnt_rel || ' relations ajoutées; '  || l_cnt_non || ' laissés tels quels');
            raise;
    end transferer_conjoints;
    
-----------------------------------------------------------------------------------   
procedure change_statut_contrat (p_contrat_id          in inc_contrat.id%type
                                ,p_nouveau_code_statut in inc_contrat.code_statut%type
                                ,out_statut            out varchar2
                                ,out_err_message       out varchar2)
as
    l_dummy number;
    --l_ctr_rec               inc_contrat%rowtype;
begin

    inc_contrat_api.mod_statut  (
        p_contrat_id  => p_contrat_id,
        p_code_statut => p_nouveau_code_statut
    );

    /*select * into l_ctr_rec
    from inc_contrat
    where id = p_contrat_id;
    
    --> change le statut du contrat
    update inc_contrat
    set code_statut = p_nouveau_code_statut
    where id = p_contrat_id;*/
    
    --> change le statut du dossier si tous les contrats ont le même statut
    /*begin
        select 1 into l_dummy
        from inc_contrat 
        where dossier_id = l_ctr_rec.dossier_id
        and code_statut = p_nouveau_code_statut
        and rownum = 1;
        
        --> au moins un contrat a un status différent
    exception when no_data_found then
    
        --> tous les contrats ont le même status, le dossier peut-être MAJ
        update inc_dossier
        set code_statut = p_nouveau_code_statut
        where id = l_ctr_rec.dossier_id;
    end;
    */
    
    out_statut := 'SUCCESS';
exception when others then
    out_statut := 'ERROR';
    out_err_message := 'Une erreur est survenue';
    insum_debug.log_error('Error in change_statut_contrat ' || sqlerrm );
end change_statut_contrat;

-----------------------------------------------------------------------------------  
procedure recuperer_contrat (p_contrat_id            in  inc_contrat.id%type
                            ,p_new_contrat_id        out inc_contrat.id%type
                            ,p_flow_diagram_requete  in varchar2
                            ,out_statut              out varchar2
                            ,out_err_message         out varchar2)
as
    l_dummy                 number;
    l_contact_id            inc_contact.id%type;
    l_ctr_rec               inc_contrat%rowtype;
	l_ctr_new_id            inc_contrat.id%type;
    l_id_concession         inc_concession.id%type;
    l_out_statut            varchar2(50);
    l_out_message           varchar2(2000);
begin

    select * into l_ctr_rec
    from inc_contrat
    where id = p_contrat_id;
    
    --> Vérifier si contrat est une convension en cours
    if l_ctr_rec.code_type != 'P' or l_ctr_rec.code_statut != 'COUR' then
		out_statut := 'ERROR';
		out_err_message := 'Le contrat n''est pas une convension en cours';
        return;
	else 		
		
		--> création d'un nouveau contrat (Régulier)
		insert into inc_contrat(CONTRAT_NO
								,NOTES_ID
								,NOTES_UNID
								,DOSSIER_NO
								,CODE_TYPE
								,CODE_CATEGORIE
								,STATUT
								,CODE_QUITTANCE
								,IND_INCOMPLET
								,TERME_PAIEMENT
								,CONCESSION_NO
								,CODE_SECTION
								,NOM_REPRESENTANT
								,INCITATIF
								,CODE_MAISON_FUNERAIRE
								,NOM_MAISON_FUNERAIRE
								,NOM_DIR_FUNERAIRE
								,RAISON_STATUT
								,PRECISION
								,SIGNE_LE
								,DATE_ACHAT
								,DONNEES_COMPL
								,SERVICE_RENDU_LE
								,CODE_STATUT
								,CODE_INCITATIF
								,AFFICHER_PRECISION
								,DUREE_TERME
								,TERME_LOCATION
								,DOSSIER_ID
								,CONTRAT_CATEGORIE_ID)
						values( l_ctr_rec.CONTRAT_NO
								,l_ctr_rec.NOTES_ID
								,l_ctr_rec.NOTES_UNID || to_char(sysdate,'YYYYMMDDHHMI')
								,l_ctr_rec.DOSSIER_NO
								,'R' --l_ctr_rec.CODE_TYPE
								,l_ctr_rec.CODE_CATEGORIE
								,l_ctr_rec.STATUT
								,l_ctr_rec.CODE_QUITTANCE
								,l_ctr_rec.IND_INCOMPLET
								,l_ctr_rec.TERME_PAIEMENT
								,l_ctr_rec.CONCESSION_NO
								,l_ctr_rec.CODE_SECTION
								,nvl(v('APP_USER'),l_ctr_rec.NOM_REPRESENTANT) --l_ctr_rec.NOM_REPRESENTANT
								,l_ctr_rec.INCITATIF
								,l_ctr_rec.CODE_MAISON_FUNERAIRE
								,l_ctr_rec.NOM_MAISON_FUNERAIRE
								,l_ctr_rec.NOM_DIR_FUNERAIRE
								,l_ctr_rec.RAISON_STATUT
								,l_ctr_rec.PRECISION
								,l_ctr_rec.SIGNE_LE
								,l_ctr_rec.DATE_ACHAT
								,l_ctr_rec.DONNEES_COMPL
								,l_ctr_rec.SERVICE_RENDU_LE
								,'COUR' --l_ctr_rec.CODE_STATUT
								,l_ctr_rec.CODE_INCITATIF
								,l_ctr_rec.AFFICHER_PRECISION
								,l_ctr_rec.DUREE_TERME
								,l_ctr_rec.TERME_LOCATION
								,l_ctr_rec.DOSSIER_ID
								,l_ctr_rec.CONTRAT_CATEGORIE_ID)
				returning id into l_ctr_new_id;
                
		--> Copier les données des items spécifiques
		for i in (select   ID_SPEC,VALEUR
					from   inc_spec_data
					where  contrat_id = p_contrat_id)
		loop
			insert into inc_spec_data(ID_SPEC,CONTRAT_ID,VALEUR)
			                values(i.ID_SPEC,l_ctr_new_id,i.VALEUR);
		end loop;
        
		--> Copier les données des services
		for i in (select   
                    s.ID,
                    s.type_service
                    ,s.categorie_service
                    ,s.prix
                    ,s.portion_taxable
                    ,s.montant_tps
                    ,s.montant_tvq
                    ,s.taux_escompte
                    ,s.montant_escompte
                    ,s.type_rabais
                    ,s.precisions
                    ,s.execute_le
                    ,s.quantite_2
                    ,s.code_produit
                    ,s.code_unique_produit
                    ,s.seq_no
                    ,s.taxable
                    ,s.contrat_categorie_id
                    ,s.service_id
                    ,s.montant_taxes
                    ,s.quantite
                    ,s.solde
                    ,s.code_statut_facturation
                    ,s.service_recupere_id
                    ,ps.ind_rendu_vente
            from   inc_service s, inc_produit_service ps
            where  s.contrat_id = p_contrat_id
            and s.service_id = ps.id
            and s.ind_supprime = 0
            )
		loop
			insert into inc_service(CONTRAT_ID
								,TYPE_SERVICE
								,CATEGORIE_SERVICE
								,PRIX
								,PORTION_TAXABLE
								,MONTANT_TPS
								,MONTANT_TVQ
								,TAUX_ESCOMPTE
								,MONTANT_ESCOMPTE
								,TYPE_RABAIS
								,PRECISIONS
								,EXECUTE_LE
								,QUANTITE_2
								,CODE_PRODUIT
								,CODE_UNIQUE_PRODUIT
								,SEQ_NO
								,TAXABLE
								,CONTRAT_CATEGORIE_ID
								,SERVICE_ID
								,MONTANT_TAXES
								,QUANTITE
                                ,SOLDE
                                ,CODE_STATUT_FACTURATION
                                ,SERVICE_RECUPERE_ID
                                ,IND_SERVICE_RENDU
                                ,DATE_SERVICE_RENDU
                                ,SERVICE_RENDU_MODIFIE_PAR 
                                )
			                values(l_ctr_new_id
								,i.TYPE_SERVICE
								,i.CATEGORIE_SERVICE
								,i.PRIX
								,i.PORTION_TAXABLE
								, 0 --i.MONTANT_TPS
								, 0 --i.MONTANT_TVQ
								,i.TAUX_ESCOMPTE
								,i.MONTANT_ESCOMPTE
								,i.TYPE_RABAIS
								,i.PRECISIONS
								,i.EXECUTE_LE
								,i.QUANTITE_2
								,i.CODE_PRODUIT
								,i.CODE_UNIQUE_PRODUIT
								,i.SEQ_NO
								,i.TAXABLE
								,i.CONTRAT_CATEGORIE_ID
								,i.SERVICE_ID
								,i.MONTANT_TAXES
								,i.QUANTITE
                                ,i.SOLDE 
                                ,i.CODE_STATUT_FACTURATION
                                ,i.ID
                                , case when i.ind_rendu_vente = 1 then 1 else 0 end         --> service_rendu automatiquement
                                , case when i.ind_rendu_vente = 1 then sysdate end   --> date service rendu
                                , case when i.ind_rendu_vente = 1 then nvl(sys_context('APEX$SESSION','APP_USER'),user) end --> service rendu par utilisateur 
                            );
		end loop;
        
        
		--> Copier les données des contacts contrat
		for i in (select   CONTACT_NO,TYPE_CONTACT
					from   inc_contact_contrat
					where  contrat_id = p_contrat_id)
		loop
			-- modifier le code bénificiaire par le code défunt
			if i.TYPE_CONTACT = 'BEN' then 
			    insert into inc_contact_contrat(CONTACT_NO,CONTRAT_ID,TYPE_CONTACT)
			                values(i.CONTACT_NO,l_ctr_new_id,'DEF');
                
                begin
                    select id into l_contact_id
                    from inc_contact
                    where contact_no = i.CONTACT_NO;
    
                    insert into inc_defunt (
                        contact_id
                    ) values (
                        l_contact_id
                    );
                exception 
                    when no_data_found then
                        null;
                    when dup_val_on_index then
                        null;
                end;
            else
                insert into inc_contact_contrat(CONTACT_NO,CONTRAT_ID,TYPE_CONTACT)
			                values(i.CONTACT_NO,l_ctr_new_id,i.TYPE_CONTACT);
            end if;
		end loop;
    end if;
 
    
    ------------------------------------------------
    --> génère les requêtes pour ce type de contrat
    ------------------------------------------------
    /*declare
        l_nb                     number := 1;
        l_req_cree               number := 0;
        l_flow_process_id        inc_requete.flow_process_id%type;
        l_prcs_id                number;
        l_id_requete_new         inc_requete.id%type;        
        
        l_requete                inc_requete%rowtype;
        l_out_statut             varchar2(50);
        l_out_message            varchar2(2000);
    begin
        for i in (
                select id, liste_id_specs, priorite, type_description_fr as description
                from  inc_requete_type
                where  id_contrat_cat = l_ctr_rec.CONTRAT_CATEGORIE_ID)
        loop 
    
            -- initialisation des variables
            l_req_cree := 0;
            
            -- vérifie si toutes les spécificités du contrat ont des valeur
            begin
                --> spécificités du contrat qui doivent être renseignées pour générer une requête
                select  id_spec_contrat into l_nb
                from (
                    select to_number(trim(regexp_substr(i.liste_id_specs, '[^:]+', 1, level))) id_spec_contrat
                    from dual
                    connect by instr(i.liste_id_specs, ':', 1, level - 1) > 0
                    MINUS
                    --> spécificités du contrat qui ont des valeurs
                    select id_spec
                    from   inc_spec_data 
                    where  contrat_id = l_ctr_new_id
                    and valeur is not null
                    and id_spec in (
                        select trim(regexp_substr(i.liste_id_specs, '[^:]+', 1, level)) id_spec_contrat
                        from dual
                        connect by instr(i.liste_id_specs, ':', 1, level - 1) > 0
                    )
                ) where rownum = 1;
            
                --> on ne fait rien car certaines spécificités du contrat n'ont pas de valeurs
                
            exception when no_data_found then
                --> toutes les spécificités ont des valeurs, on génère la requête
                l_req_cree := 1;
            end;
            
            -- condition pour declencher la creation de la requete. 
            if l_req_cree != 0 then
    
                -- initialise les valeurs
                l_requete.req_no := inc_requete_api.gen_requete_no();
                l_requete.type_id := i.ID;
                l_requete.date_prevue := sysdate;
                
                select g.titre_fr || ' ' || l_ctr_rec.dossier_no || ' (' || i.description || ')'
                into l_requete.description 
                from   inc_gabarit g
                      ,inc_contrat c
                where  c.contrat_no = l_ctr_rec.contrat_no
                and    c.code_type = g.code_type_contrat
                and    c.contrat_categorie_id = g.cat_contrat_id
                and rownum = 1;

                l_requete.dossier_id := l_ctr_rec.dossier_id;
                l_requete.contrat_id := l_ctr_new_id;

                begin
                
                    select id into l_requete.concession_id
                    from inc_concession_v
                    where   code_section = l_ctr_rec.code_section
                    and     concession_no = l_ctr_rec.concession_no;
                
                exception when no_data_found then
                    rollback;
                    out_statut := 'ERROR';
                    out_err_message := 'Concession introuvable';
                    return;
                end;
                
                l_requete.date_execution := sysdate;
                l_requete.remarques := null;
                l_requete.seq_actuelle := inc_requete_api.get_sequence_initiale(p_type_id => i.ID);
                l_requete.ind_bloquee := 0;
                l_requete.priorite := i.priorite;
                l_requete.ind_generee := 1;
                
                
                -- création de la requête
                INC_REQUETE_API.creer_requete(l_requete,l_id_requete_new,l_out_statut,l_out_message);
                if l_out_statut is null or l_out_statut = 'ERROR' then 
                    out_statut := 'ERROR';
                    out_err_message := l_out_message;
                    return;
                end if;
 
                -- initialise les valeurs des spécificités des requêtes si elles sont reliées aux spécificités du contrat
                for c1 in (
                    select 
                        t0.id_spec,
                        t1.valeur as spec_value,
                        t2.id as id_spec_req
                    from inc_specificites t0, inc_spec_data t1, inc_requete_specificites t2
                    where t0.id_spec = t1.id_spec
                    and t0.contrat_categorie_id =  l_ctr_rec.contrat_categorie_id
                    and t1.contrat_id = l_ctr_new_id
                    and t0.id_spec = t2.id_spec_contrat
                    and t2.type_req_id = l_requete.type_id
                    and t2.id_spec_contrat is not null
                ) loop
                    
                    insert into inc_requete_spec_data (
                        id_spec,
                        id_req,
                        valeur
                    ) values (
                        c1.id_spec_req,
                        l_id_requete_new,
                        c1.spec_value
                    ); 
                    --insum_debug.log_error('1. APRES ' || l_id_requete_new );
                end loop;
    
                -- créer une instance dans Apex Flows pour la nouvelle requête
                l_prcs_id := flow_api_pkg.flow_create( pi_dgrm_id   => p_flow_diagram_requete
                                                    , pi_prcs_name => l_id_requete_new);
                -- start Flow procedure
                flow_api_pkg.flow_start(p_process_id => l_prcs_id);
                -- update id_flow in inc_contrat 
                update inc_requete
                set    FLOW_PROCESS_ID =   l_prcs_id
                where  id = l_id_requete_new;
            end if;
        end loop;
    end;*/
    
    ----------------------------------------------------------------------------
    --> génére les requêtes basées sur les spécificités pour le nouveau contrat
    ----------------------------------------------------------------------------    
    begin
        select id into l_id_concession
        from inc_concession
        where concession_no = l_ctr_rec.concession_no
        and code_section = l_ctr_rec.code_section;
    exception when no_data_found then
        l_id_concession := null;
    end;
    
    inc_requete_api.synchronise_requete_specficite(
        p_contrat_id           => l_ctr_new_id,
        p_concession_id        => l_id_concession,
        p_dans_collection      => false, 
        p_mode_recuperation_pa => true,
        out_statut             => l_out_statut,
        out_message            => l_out_message
    ); 
    if l_out_statut is null or l_out_statut != 'SUCCESS' then
        out_statut := 'ERROR';
        out_err_message := l_out_message;
        return;
    end if;
    
    ----------------------------------------------------------------------------
    --> génére les requêtes basées sur les services pour le nouveau contrat
    ----------------------------------------------------------------------------
    inc_requete_api.synchronise_requete_service(
        p_contrat_id           => l_ctr_new_id,
        p_concession_id        => l_id_concession,
        p_dans_collection      => false, 
        p_mode_recuperation_pa => true,
        out_statut             => l_out_statut,
        out_message            => l_out_message
    ); 
    if l_out_statut is null or l_out_statut != 'SUCCESS' then
        out_statut := 'ERROR';
        out_err_message := l_out_message;
        return;
    end if;
    
     -- met a jour les id des services dans les requetes concernées
    for c1 in (
        select t1.id, t1.service_produit_id
        from inc_requete_service t1, inc_requete t2
        where t1.requete_id = t2.id
        and t2.contrat_id = l_ctr_new_id
        and t1.service_id is null
    ) loop
            update inc_requete_service
            set service_id = (
                select id
                from inc_service
                where contrat_id = l_ctr_new_id
                and service_id = c1.service_produit_id
                and ind_supprime = 0
            )
            where id = c1.id;
    end loop;
    
    p_new_contrat_id := l_ctr_new_id;
    out_statut := 'SUCCESS';
exception when others then
    out_statut := 'ERROR';
    out_err_message := 'Une erreur est survenue ' || sqlerrm;
    insum_debug.log_error('Error in recuperer_contrat ' || sqlerrm );
end recuperer_contrat;

----------------------------------------------------------------------------------- 

-- procedure de retour au PA lors de l'annulation d'un contrat  
   procedure retour_au_pa (p_contrat_id              in  inc_contrat.id%type) as 
    l_ctr_no               inc_contrat.contrat_no%type;
    l_ctr_id               inc_contrat.id%type;
    l_out_statut           varchar2(255);
    l_out_err_message      varchar2(255);
    l_diag_flow_id         number := APEX_UTIL.GET_SESSION_STATE('G_FLOW_DIAGRAM_CONTRAT');
    l_prcs_id              number;
    l_subflow_id           FLOW_TASK_INBOX_VW.SBFL_ID%type;
   begin
    select contrat_no 
    into   l_ctr_no
    from   inc_contrat
    where  id = p_contrat_id;

    begin
        select id
        into   l_ctr_id
        from   inc_contrat
        where  contrat_no = l_ctr_no
        and    code_type = 'P'
        and    code_statut = 'RECUP';

        --> modification statut PA a COUR
        change_statut_contrat(l_ctr_id,'COUR',l_out_statut,l_out_err_message);
        --> Créer une nouvelle instance Apex Flow
        l_prcs_id := flow_api_pkg.flow_create( pi_dgrm_id   => l_diag_flow_id
                                             , pi_prcs_name => l_ctr_id);
        -- start Flow procedure
        flow_api_pkg.flow_start(p_process_id => l_prcs_id);
        -- update id_flow in inc_contrat 
        update inc_contrat
        set    FLOW_PROCESS_ID =   l_prcs_id
        where  id = l_ctr_id;
        -- avancer le flow pour avoir le statut en cours
        flow_process_vars.set_var( pi_prcs_id   => l_prcs_id
                                        , pi_var_name  => 'Soumission-validation:route'
                                        , pi_vc2_value => 'NonSoumission'
                                    );
        -- Get last subflow_id for this instance
        select max(sbfl_id)
        into   l_subflow_id
        from   FLOW_TASK_INBOX_VW
        where  SBFL_PRCS_ID = l_prcs_id
        and    SBFL_DGRM_ID = l_diag_flow_id; 
        -- avancer dans le flow
        flow_api_pkg.flow_complete_step( p_process_id => l_prcs_id, p_subflow_id => l_subflow_id);
    exception
      when others then
        null;  
    end;
    --> 
    
      
   end;
--------------------------------------------------------
-- Modifie une contrat - table inc_requete
--------------------------------------------------------
procedure modifie_contrat (
    p_contrat              in inc_contrat%rowtype,
    out_statut             out varchar2,
    out_message            out varchar2
)as
begin

    update inc_contrat 
    set row = p_contrat
    where id = p_contrat.id;
    
    out_statut := 'SUCCESS';
exception when others then
    out_statut := 'ERROR';
    out_message := 'Une erreur est survenue';
    insum_debug.log_error('Erreur : ' || sqlerrm );
end modifie_contrat;
-----------------------------------------------------------------------------------
-- function de recherche de la valeur de un specficite par code ou id, et id du contrat
function get_spec_val_code (p_code_spec            in inc_specificites.code_spec%type
                           ,p_contrat_id           in inc_contrat.id%type
                           ) return inc_spec_data.valeur%type
is
    l_valeur inc_spec_data.valeur%type;
begin
    select t1.valeur into l_valeur
    from inc_spec_data t1, inc_specificites t2
    where t1.id_spec = t2.id_spec 
    and t2.code_spec = p_code_spec 
    and t1.contrat_id = p_contrat_id;

    return l_valeur;
exception
  when no_data_found then
    return null;
end;
-----------------------------------------------------------------------------------
-- function qui calcule le prix des services pour un contrat
-----------------------------------------------------------------------------------
function get_prix_service(
     p_dossier_id       in inc_dossier.id%type default null
    ,p_contrat_id       in inc_contrat.id%type default null
    ,p_service_id       in inc_service.id%type default null
    ,p_type_montant     in varchar2 default 'PRIX_TAXE'
) return number
is
    l_prix  number;
begin
    --> paramètres non valides
    if p_dossier_id is null and p_contrat_id is null and p_service_id is null then
        return 0;
    end if;
    
    if p_dossier_id is not null then
        select nvl(sum(
            case 
                when p_type_montant = 'PRIX' then s.montant_ht
                when p_type_montant = 'PRIX_TAXE' then s.montant_ttc
                when p_type_montant = 'TAXE' then s.montant_taxes
                when p_type_montant = 'ESCOMPTE' then s.montant_escompte
                /*when p_type_montant = 'PRIX' then s.prix
                when p_type_montant = 'PRIX_TAXE' then s.prix + s.montant_taxes
                when p_type_montant = 'TAXE' then s.montant_taxes
                when p_type_montant = 'ESCOMPTE' then s.montant_escompte*/
            end), 0) into l_prix
        from inc_service s, inc_contrat c
        where s.contrat_id = c.id
        and c.dossier_id = p_dossier_id
        and c.code_statut in (inc_contrat_api.co_statut_en_cours, inc_contrat_api.co_statut_completer, 'PAYE')
        and s.ind_supprime = 0;
    else
        select nvl(sum(
            case 
                when p_type_montant = 'PRIX' then s.montant_ht
                when p_type_montant = 'PRIX_TAXE' then s.montant_ttc
                when p_type_montant = 'TAXE' then s.montant_taxes
                when p_type_montant = 'ESCOMPTE' then s.montant_escompte
            end), 0) into l_prix
        from inc_service s
        --where s.contrat_id = p_contrat_id
        where s.ind_supprime = 0
        and (p_service_id is null or s.id = p_service_id)         -- pour un service particulier
        and (p_contrat_id is null or s.contrat_id = p_contrat_id); -- pour un contrat particulier
    end if;
    
    return l_prix;
exception
  when no_data_found then
    return null;
end;
-----------------------------------------------------------------------------------
-- function qui vérifie si la section est dupliqué ou non
-----------------------------------------------------------------------------------
function section_is_duplicated(p_nom_section in inc_section.nom_section%type
) return boolean as
    l_dummy  number;
begin
    select 1
    into   l_dummy
    from   inc_section
    where  nom_section = p_nom_section
    and    type_contenu = 'REGION'
    and    IND_REPLIQUER = 1;
    return true;
exception
    when others then return false;
end section_is_duplicated;
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- procedure pour dupliquer le contact dans les contrats du dossier
-----------------------------------------------------------------------------------
procedure duplicate_contact_section(p_type_contact in varchar2
    ,p_id_dossier inc_dossier.id%type
    ,p_contact_no inc_contact.contact_no%type
    ,p_id_contrat inc_contrat.id%type default null
) is

begin    
    -- chercher tous les contrats du dossier
    for rec in (select id 
                from   inc_contrat
                where  dossier_id = p_id_dossier
                and    id = nvl(p_id_contrat,id)
                and    (code_statut = INC_CONTRAT_API.get_co_statut_en_cours()
                        or
                        code_statut = INC_CONTRAT_API.get_co_statut_soumis()))
    loop
        MERGE INTO INC_CONTACT_CONTRAT s1 USING (select rec.id as CONTRAT_ID, 
                                                    p_type_contact   as TYPE_CONTACT 
                                                    from dual) s2 
                ON (s1.CONTRAT_ID = s2.CONTRAT_ID and s1.TYPE_CONTACT = s2.TYPE_CONTACT) 
        WHEN MATCHED THEN UPDATE SET s1.CONTACT_NO = p_contact_no
        WHEN NOT MATCHED THEN INSERT (CONTRAT_ID,CONTACT_NO,TYPE_CONTACT) 
                    values (s2.CONTRAT_ID,p_contact_no,s2.TYPE_CONTACT);
    end loop;
exception
    when others then 
    raise_application_error (-20001,'Section non dupliquée.');  
end duplicate_contact_section;
-----------------------------------------------------------------------------------
-- procedure pour dupliquer les contacts dans les nouveaux contrats du dossier (Modififier dossier)
-----------------------------------------------------------------------------------
procedure duplicate_contact_dossier(p_id_dossier inc_dossier.id%type
    ,p_id_contrat inc_contrat.id%type 
) is
  l_type_contrat      varchar2(1);
  l_cat_contrat_id    number;
  l_contrat_id        number;
  l_contact_no        varchar2(50);
begin
    -- données du contrat
    select  CONTRAT_CATEGORIE_ID, CODE_TYPE
    into    l_cat_contrat_id, l_type_contrat
    from    inc_contrat
    where   id = p_id_contrat;
    -- liste des sections a repliquer
    for rec_section in (select NOM_SECTION, 
                               case when NOM_SECTION = 'SEP_DEFUNT' then 'DEF'
                                    when NOM_SECTION = 'COM_CONTACT_BEN' then 'BEN'
                                    when NOM_SECTION = 'COM_AUTRE' then 'AUT'
                                    when NOM_SECTION = 'COM_CONCESSIONNR' then 'CON'
                                    when NOM_SECTION = 'COM_CONJOINT' then 'CNJ'
                                    when NOM_SECTION = 'SEP_CONTACT_MER' then 'MER'
                                    when NOM_SECTION = 'SEP_CONTACT_PER' then 'PER'
                                    when NOM_SECTION = 'COM_CONTACT_REF' then 'REF'
                                else null end type_contact
                        from   inc_section s, inc_element e, inc_gabarit g
                        where  ind_repliquer = 1
                        and    s.id = e.section_id
                        and    e.gabarit_id = g.id
                        and    g.CODE_TYPE_CONTRAT = l_type_contrat
                        and    g.CAT_CONTRAT_ID = l_cat_contrat_id)
    loop
        -- chercher un contrat qui contient cette section
        begin
            select contrat_id, CONTACT_NO
            into   l_contrat_id, l_contact_no
            from   inc_contact_contrat
            where  TYPE_CONTACT = rec_section.type_contact
            and    contrat_id in (select id from inc_contrat where dossier_id = p_id_dossier)
            and    rownum = 1;
            -- dupliquer la section pour le nouveau contrat
            INC_CONTRAT_API.duplicate_contact_section(rec_section.type_contact
                                                     ,p_id_dossier
                                                     ,l_contact_no
                                                     ,p_id_contrat);
        exception
            when others then null;
        end;
    end loop;
exception
    when others then null;
end duplicate_contact_dossier;


-----------------------------------------------------------------------------------
-- procedure qui redémarre les flows d'APEX et qui repositionne le contrat à "En Cours"
-- @out_statut : statut de retour (ERROR / SUCCESS)
-- @out_message : message retourné ou null si tout s'est bien passé
-----------------------------------------------------------------------------------
procedure redemarre_flow_contrat (
    p_contrat_id          in inc_contrat.id%type
   ,out_statut            out varchar2
   ,out_message           out varchar2
) as
    l_contrat               inc_contrat%rowtype;
    
    -- apex flows
    l_diag_flow_id          number := apex_util.get_session_state('G_FLOW_DIAGRAM_CONTRAT');
    l_process_id            number;
    l_subflow_id            number;
begin

    --> trouve les détails du contrat
    select * into l_contrat
    from inc_contrat
    where id = p_contrat_id;

    --> trouve l'ancien flux
    select flow_process_id
    into l_process_id
    from inc_contrat
    where id = p_contrat_id;
    
    --> efface l'ancien flux
    flow_api_pkg.flow_delete(
         p_process_id  => l_process_id
       , p_comment     => 'Réinitialisation après complétion'
    );
    
    --> crée un nouveau flux
    l_process_id := flow_api_pkg.flow_create( pi_dgrm_id   => l_diag_flow_id, pi_prcs_name => p_contrat_id);
    
    --> met à jour le contrat
    update inc_contrat
    set    flow_process_id =   l_process_id
    where  id = p_contrat_id;
    
    -- démarre le flow
    flow_api_pkg.flow_start(p_process_id => l_process_id);
    
    -- prépare le flow pour aller vers le statut en cours
    flow_process_vars.set_var( 
        pi_prcs_id   => l_process_id 
        , pi_var_name  => 'Soumission-validation:route' --> gateway 
        , pi_vc2_value => 'NonSoumission'               --> route
    );
    
    select max(sbfl_id) into l_subflow_id
    from  flow_task_inbox_vw
    where sbfl_dgrm_id = l_diag_flow_id
    and   sbfl_prcs_id = l_process_id;
    
    -- avancer le flow
    flow_api_pkg.flow_complete_step( p_process_id => l_process_id, p_subflow_id => l_subflow_id);    
    
    --> APEX FLOWS
    /*select max(sbfl_id)
    into  l_subflow_id
    from  flow_task_inbox_vw
    where sbfl_dgrm_id = l_diag_flow_id
    and   sbfl_prcs_id = l_contrat.flow_process_id;
    
    insum_debug.log_error('l_subflow_id ' || l_subflow_id );
    
    if l_subflow_id is null then
        out_statut := 'ERROR';
        out_message := 'Impossible de trouver le flux du service ' || l_contrat.contrat_no;
    else
        --> reinitialise le flow
        flow_api_pkg.flow_reset(
             p_process_id  => l_contrat.flow_process_id
           , p_comment     => 'Réinitialisation après complétion'
        );
        
        -- démarre le flow
        flow_api_pkg.flow_start(p_process_id => l_contrat.flow_process_id);
        
        -- avancer le flow
        flow_api_pkg.flow_complete_step( p_process_id => l_contrat.flow_process_id, p_subflow_id => l_subflow_id);
        
        -- préparer le flow pour aller vers le statut en cours
        flow_process_vars.set_var( 
            pi_prcs_id   => l_contrat.flow_process_id 
            , pi_var_name  => 'Soumission-validation:route' --> gateway 
            , pi_vc2_value => 'NonSoumission'               --> route
        );
        
        -- avancer le flow
        flow_api_pkg.flow_complete_step( p_process_id => l_contrat.flow_process_id, p_subflow_id => l_subflow_id);
    end if;*/
    
    --> succés
    out_statut := 'SUCCESS';
    
exception when others then
    out_statut := 'ERROR';
    out_message := 'Une erreur est survenue';
    insum_debug.log_error('Error occured : ' || sqlerrm );
end redemarre_flow_contrat;

-----------------------------------------------------------------------------------
-- procedure de mise à jour du statut du contrat à COMPLETER
-- Deux conditions nécessaires : 
--      1. tous les services sont rendus
--      2. tous les services sont payés
----------------------------------------------------------------------------------
procedure complete_contrat (
    p_contrat_id          in inc_contrat.id%type
   ,out_statut            out varchar2
   ,out_message           out varchar2
) as
    l_nb_services           number;
    l_contrat               inc_contrat%rowtype;
    
    -- apex flows
    l_diag_flow_id          number := apex_util.get_session_state('G_FLOW_DIAGRAM_CONTRAT');
    l_prcs_id               number;
    l_subflow_id            number;
    
    l_out_statut            varchar2(50);
    l_out_message           varchar2(2000);
begin

    --> savepoint
    --savepoint complete_contrat;
    
    --> les requêtes manuelles n'ont pas forcément de contrat
    if p_contrat_id is null then
        out_statut := 'SUCCESS';
        return;
    end if;
    
    --> les requêtes manuelles n'ont pas forcément de contrat
    if p_contrat_id is null then
        out_statut := 'SUCCESS';
        return;
    end if;
    
    --> trouve les détails du contrat
    select * into l_contrat
    from inc_contrat
    where id = p_contrat_id;
    
    ---insum_debug.log_error('****** complete_contrat : ' || l_contrat.contrat_no);
    
    --> vérifie le statut actuel
    if l_contrat.code_statut not in (inc_contrat_api.co_statut_completer, inc_contrat_api.co_statut_en_cours) then
        out_statut := 'SUCCESS';
        return;
        --out_statut := 'ERROR';
        --out_message := 'Le statut du service est invalide (' || l_contrat.code_statut || ')';
        --return;
    end if;
    
    --> pas de produit, on ne fait rien
    select count(1) into l_nb_services
    from inc_service
    where ind_supprime != 1
    and contrat_id = p_contrat_id;
    
    if l_nb_services = 0 then
        out_statut := 'SUCCESS';
        return;
    end if;
    
    --> pas de facture, on ne fait rien
    select count(1) into l_nb_services
    from inc_facture
    where dossier_id = l_contrat.dossier_id;
    
    if l_nb_services = 0 then
        out_statut := 'SUCCESS';
        return;
    end if;
    
    
    --> compte les services qui ne sont pas rendus ou pas payés
    select count(1) into l_nb_services
    from inc_service
    where ind_supprime != 1
    and contrat_id = p_contrat_id
    and (
        (code_statut_facturation != 'PAI' and solde != 0)
      or
        nvl(ind_service_rendu, 0) != 1
        --ind_service_rendu != 1
    );    
    
    ---insum_debug.log_error('l_nb_services : ' || l_nb_services );

    ---------------------------------------------------
    --> des services ne pas sont rendus ou pas payés
    ---------------------------------------------------
    if l_nb_services > 0 then
    
        --> si le contrat est complété, on doit le repasser à "En Cours"
        if l_contrat.code_statut = inc_contrat_api.co_statut_completer then
        
            -- change le statut
            inc_contrat_api.change_statut_contrat (
                p_contrat_id          => p_contrat_id
               ,p_nouveau_code_statut => inc_contrat_api.co_statut_en_cours
               ,out_statut            => l_out_statut
               ,out_err_message       => l_out_message
            );
        
            --> redémarre le APEX flows
            inc_contrat_api.redemarre_flow_contrat (
                p_contrat_id   => p_contrat_id
               ,out_statut     => l_out_statut
               ,out_message    => l_out_message
            );
       
           if l_out_statut is null or l_out_statut != 'SUCCESS' then
                --rollback to complete_contrat;
                out_statut := 'ERROR';
                out_message := l_out_message;
                return;
            end if;
            
        end if;
   
        /*out_statut := 'SUCCESS';
        return;*/
    
    -------------------------------------------------------------
    --> tous les services sont rendus et payés
    -------------------------------------------------------------
    else
    
        if l_contrat.code_statut != inc_contrat_api.co_statut_completer then
    
            -- complète le contrat
            inc_contrat_api.change_statut_contrat (
                p_contrat_id          => p_contrat_id
               ,p_nouveau_code_statut => inc_contrat_api.co_statut_completer
               ,out_statut            => l_out_statut
               ,out_err_message       => l_out_message
            );
            
            ---insum_debug.log_error('change_statut_contrat / l_out_statut : ' || l_out_statut );
            ---insum_debug.log_error('change_statut_contrat / l_out_message : ' || l_out_message );
            
            if l_out_statut is null or l_out_statut != 'SUCCESS' then
                --rollback to complete_contrat;
                out_statut := 'ERROR';
                out_message := l_out_message;
                return;
            end if;
        
            ---insum_debug.log_error('l_contrat.flow_process_id ' || l_contrat.flow_process_id );
            
            -------------------
            --> APEX FLOW
            -------------------
            select max(sbfl_id)
            into   l_subflow_id
            from  flow_task_inbox_vw
            where sbfl_dgrm_id = l_diag_flow_id
            and   sbfl_prcs_id = l_contrat.flow_process_id;
            
            ---insum_debug.log_error('complete_contrat > l_subflow_id ' || l_subflow_id );
            
            if l_subflow_id is null then
                --rollback to complete_contrat;
                out_statut := 'ERROR';
                out_message := 'Impossible de trouver le flux du service ' || l_contrat.contrat_no;
                --return;
            else
                -- avancer le flow pour avoir le statut "complété"
                flow_process_vars.set_var( 
                    pi_prcs_id   => l_contrat.flow_process_id
                    , pi_var_name  => 'AnnulerValidation:route' --> gateway id 
                    , pi_vc2_value => 'NonAnnuler'              --> route id 
                );
                
                ---insum_debug.log_error('set_var ');
                
                -- avancer dans le flow
                flow_api_pkg.flow_complete_step( p_process_id => l_contrat.flow_process_id, p_subflow_id => l_subflow_id);
                
                ---insum_debug.log_error('flow_complete_step ');
                
                
                -- avance vers la clotûre
                flow_process_vars.delete_var( pi_prcs_id => l_contrat.flow_process_id, pi_var_name => 'AnnulerValidation:route');
                flow_api_pkg.flow_complete_step( p_process_id => l_contrat.flow_process_id, p_subflow_id => l_subflow_id);
                
                ---insum_debug.log_error('LAST flow_complete_step ' );
            end if;
        end if;
    end if;
    
    
    -------------------------------------------------------------------------
    --> complète le dossier si tous les contrats du dossier sont complétés
    -------------------------------------------------------------------------
    inc_dossier_api.complete_dossier (
        p_dossier_id          => l_contrat.dossier_id
       ,out_statut            => l_out_statut
       ,out_message           => l_out_message
    );
    
    ---insum_debug.log_error('complete_dossier / l_out_statut : ' || l_out_statut );
    ---insum_debug.log_error('complete_dossier / l_out_message : ' || l_out_message );
    
    if l_out_statut is null or l_out_statut != 'SUCCESS' then
        --rollback to complete_contrat;
        out_statut := 'ERROR';
        out_message := l_out_message;
        return;
    end if;
    
    --> succés
    out_statut := 'SUCCESS';
    
exception when others then
    --rollback to complete_contrat;
    out_statut := 'ERROR';
    out_message := 'Une erreur est survenue';
    insum_debug.log_error('Error occured : ' || sqlerrm );
end complete_contrat;

-----------------------------------------------------------------------------------
-- procedure de mise à jour du statut du contrat à COMPLETER
-- Deux conditions nécessaires : 
--      1. tous les services sont rendus
--      2. tous les services sont payés
-----------------------------------------------------------------------------------
procedure complete_contrat_facture (
    p_facture_id          in inc_facture.id%type
   ,out_statut            out varchar2
   ,out_message           out varchar2
)as
    l_facture               inc_facture%rowtype;
    
    l_out_statut            varchar2(50);
    l_out_message           varchar2(2000);
begin

    --savepoint complete_contrat_facture;

    -- trouve les détails de la facture
    select * into l_facture
    from inc_facture
    where id = p_facture_id;
    
    ---insum_debug.log_error('****** complete_contrat_facture l_facture.id : ' || l_facture.id );
    ---insum_debug.log_error('****** l_facture.facture_no : ' || l_facture.facture_no );

    ----------------------------
    -- complète le contrat
    ----------------------------
    inc_dossier_api.complete_contrats_dossier (
        p_dossier_id           => l_facture.dossier_id,
        out_statut             => l_out_statut,
        out_message            => l_out_message
    );

    if l_out_statut is null or l_out_statut != 'SUCCESS' then
        --rollback to complete_contrat_facture;
        out_statut := 'ERROR';
        out_message := l_out_message;
        return;
    end if;    

    --> succés
    out_statut := 'SUCCESS';
    
exception when others then
    out_statut := 'ERROR';
    out_message := 'Une erreur est survenue';
    insum_debug.log_error('Error occured : ' || sqlerrm );
end complete_contrat_facture;

-----------------------------------------------------------------------------------
-- procedure de mise à jour du statut du contrat à COMPLETER
-- Deux conditions nécessaires : 
--      1. tous les services sont rendus
--      2. tous les services sont payés
-----------------------------------------------------------------------------------
procedure get_reservation_cal_business_hours
is
    l_start_date date;
    l_end_date date;
    l_min_time varchar2(10) := '08:00:00';
    l_max_time varchar2(10) := '18:00:00';
    l_min_date date;
    l_max_date date;
    l_obj json_object_t;
    l_business_hour json_array_t;
    l_delais number;
    l_duree number;
    l_type_inhumation number;
    l_type_reservation_id number;
    l_max_reservation number;
    l_maison_funeraire_id number;
    l_nb_reservation number;
    l_nb_reservation_hour number;
    l_code_section varchar2(5);
    l_concession_no varchar2(10);
    l_jour_num number;
    l_dow number;

    l_dummy number;
begin
    l_start_date := to_date(apex_application.g_x01, 'DD/MM/YYYY');
    l_end_date := to_date(apex_application.g_x02, 'DD/MM/YYYY');
    l_type_inhumation := apex_application.g_x03;
    l_type_reservation_id := apex_application.g_x04;
    l_maison_funeraire_id := apex_application.g_x05;
    l_code_section := apex_application.g_x06;
    l_concession_no := apex_application.g_x07;


    l_business_hour := new json_array_t('[]');

    if l_type_inhumation is not null then

        begin
            select delais, nvl(duree, 24)
            into l_delais, l_duree
            from inc_reservation_regle
            where date_debut <= l_start_date
            and date_fin >= l_start_date
            and type_id = l_type_reservation_id
            and type_inhumation = l_type_inhumation;
        exception when no_data_found then
            l_delais := 0;
            l_duree := 30;
        end;

        if l_start_date < sysdate then
            l_start_date := sysdate + l_delais / 24;
        end if;

   
        for rec in (
            with days as (
                select
                    l_start_date + level - 1 date_jour,
                    trim(to_char(l_start_date + level - 1, 'DAY', 'NLS_DATE_LANGUAGE = english')) jour_semaine,
                    to_char(l_start_date + level - 1, 'D') jour_semaine_num
                FROM dual
                connect BY level <= 1 + (l_end_date - l_start_date)
            )
            select * 
            from days d
            where not exists (
                select 1 
                from inc_conge c
                where trunc(c.datedebut) = trunc(d.date_jour)
            )
            and not exists (
                select 1
                from inc_fermeture_section
                where code_section = l_code_section
                and ( num_initial is null or num_initial <= to_number(substr(l_concession_no, 1, 5)) )
                and ( num_final is null or num_final >= to_number(substr(l_concession_no, 1, 5)) )
                and date_debut <= d.date_jour
                and date_fin >= d.date_jour
            )
        )
        loop
            l_jour_num := rec.jour_semaine_num;
            l_dow := l_jour_num - 1;
            apex_debug.message('>>> rec.date_jour ' || rec.date_jour);
            apex_debug.message('>>> rec.jour_semaine '||rec.jour_semaine);
            apex_debug.message('>>> l_jour_num '|| l_jour_num);
            /*Check first the max authorized*/
            begin
                select nvl(sum(irrd.nombre_max), 0)
                into l_max_reservation
                from inc_reservation_regle irr
                join inc_reservation_regle_detail irrd
                on irrd.reservation_regle_id = irr.id
                and irrd.jour = l_jour_num
                join inc_ref_valeur t
                on t.nom_table = 'INC_RESERVATION_REGLE_DETAIL'
                and t.nom_col = 'TYPE_ID'
                and t.code_valeur = 'RRD2'
                and t.id = irrd.type_id 
                where ( irrd.maison_funeraire_id is null 
                or irrd.maison_funeraire_id = l_maison_funeraire_id )
                and irr.type_id = l_type_reservation_id
                and irr.type_inhumation = l_type_inhumation
                and irr.date_debut <= rec.date_jour
                and irr.date_fin >= rec.date_jour;
                
                apex_debug.message('>>> l_max_reservation '||l_max_reservation);

                select count(*)
                into l_nb_reservation
                from inc_reservation ir
                where trunc(ir.date_debut) = trunc(rec.date_jour)
                and type_id = l_type_reservation_id
                and type_inhumation = l_type_inhumation;

                apex_debug.message('>>> l_nb_reservation '||l_nb_reservation);

                if l_nb_reservation >= l_max_reservation then
                    apex_debug.message('>>> Skip current iteration');
                    continue;
                end if;

            exception when no_data_found then
                apex_debug.message('>>> No max found');
            end;

            for rules in (
                with data as (
                    select 
                        case 
                            when trunc(to_date('19/10/2022', 'DD/MM/YYYY')) = trunc(l_start_date) 
                                and 
                                to_date(to_char(irrd.heure_debut, 'HH24:MI'), 'HH24:MI') < to_date(to_char(l_start_date, 'HH24:MI'), 'HH24:MI')
                            then to_char(l_start_date, 'HH24:MI')
                        else
                            to_char(irrd.heure_debut, 'HH24:MI') 
                        end as debut,
                        to_char(irrd.heure_fin, 'HH24:MI') as fin,
                        to_date(to_char(irrd.heure_debut, 'HH24:MI'), 'HH24:MI') as date_min,
                        to_date(to_char(irrd.heure_fin, 'HH24:MI'), 'HH24:MI') as date_max,
                        to_char(to_date(to_char(irrd.heure_debut, 'HH24:MI'), 'HH24:MI'), 'DD/MM/YYYY HH24:MI') as debug_heure_debut,
                        to_char(to_date(to_char(l_start_date, 'HH24:MI'), 'HH24:MI'), 'DD/MM/YYYY HH24:MI') as debug_start_date,
                        nombre_max,
                        date_specifique,
                        maison_funeraire_id
                    from inc_reservation_regle irr
                    join inc_reservation_regle_detail irrd
                    on irrd.reservation_regle_id = irr.id
                    and irrd.jour = l_jour_num
                    join inc_ref_valeur t
                    on t.nom_table = 'INC_RESERVATION_REGLE_DETAIL'
                    and t.nom_col = 'TYPE_ID'
                    and t.code_valeur = 'RRD1'
                    and t.id = irrd.type_id 
                    where irr.date_debut <= rec.date_jour
                    and irr.date_fin >= rec.date_jour
                    and irr.type_id = l_type_reservation_id
                    and irr.type_inhumation = l_type_inhumation
                    and (irrd.maison_funeraire_id is null or irrd.maison_funeraire_id = l_maison_funeraire_id)
                    and 
                        (
                            irrd.date_specifique is null or 
                            trunc(irrd.date_specifique) = trunc(trunc(rec.date_jour))
                        )
                ), dates as (
                    select debut, fin, date_min, date_max, debug_heure_debut, debug_start_date,
                        case when date_specifique is not null then 1 else 0 end as has_date_specique,
                        nombre_max
                    from data
                ), grouped_data as (
                    select debut, fin, date_min, date_max, debug_heure_debut, debug_start_date, has_date_specique, sum(nombre_max) as nombre_max
                    from dates
                    group by debut, fin, date_min, date_max, debug_heure_debut, debug_start_date, has_date_specique
                ), ordered_data as (
                    select debut, fin, date_min, date_max, debug_heure_debut, debug_start_date, has_date_specique, nombre_max,
                        row_number() over (partition by debut, fin order by 1) rownumber
                    from grouped_data
                    order by debut, fin, has_date_specique desc
                )
                select debut, fin, date_min, date_max, debug_heure_debut, debug_start_date, nombre_max 
                from ordered_data
                where rownumber = 1
                order by debut, fin
            ) 
            loop
                apex_debug.message('>>>>>> l_jour_num ' ||l_jour_num);
                apex_debug.message('>>>>>> rules.debut ' ||rules.debut);
                apex_debug.message('>>>>>> rules.fin ' ||rules.fin);
                apex_debug.message('>>>>>> rules.nombre_max ' || rules.nombre_max);
                apex_debug.message('>>>>>> debug_heure_debut '||rules.debug_heure_debut);
                apex_debug.message('>>>>>> debug_start_date '||rules.debug_start_date);

                if l_min_date is null or l_min_date > rules.date_min then
                l_min_date := rules.date_min;
                end if;
                if l_max_date is null or l_max_date < rules.date_max then
                l_max_date := rules.date_max;
                end if;

                if (to_date(rules.debut, 'HH24:MI') >= to_date(rules.fin, 'HH24:MI')) then
                    apex_debug.message('>>> Skip current iteration');
                    continue;
                end if;
            
                l_nb_reservation_hour := 0;

                if l_nb_reservation > 0 then
                    apex_debug.message('>>>> reservation exists check for these hours');
                    select count(*)
                    into l_nb_reservation_hour
                    from inc_reservation ir
                    where trunc(ir.date_debut) = trunc(rec.date_jour)
                    and type_id = l_type_reservation_id
                    and type_inhumation = l_type_inhumation
                    and to_date(to_char(ir.date_debut, 'HH24:MI'), 'HH24:MI') = rules.date_min;

                    apex_debug.message('>>>> l_nb_reservation_hour ' || l_nb_reservation_hour);

                    if l_nb_reservation_hour >= rules.nombre_max then
                        apex_debug.message('>>> Skip current iteration');
                        continue;
                    end if;
                end if;

                l_obj := new json_object_t('{}');
                l_obj.put('dow', treat(new json_array_t('['||l_dow||']') as json_element_t));
                l_obj.put('start', rules.debut);
                l_obj.put('end', rules.fin);
                l_business_hour.append(l_obj);
            
            end loop;
        end loop;

        if l_min_date is not null then  
            l_min_time := to_char(l_min_date, 'HH24:MI:SS');
        end if;
        if l_max_date is not null then 
            l_max_time := to_char(l_max_date,  'HH24:MI:SS');
        end if;

    end if;

    apex_json.open_object;
    apex_json.write('success', true);
    apex_json.write('minTime', l_min_time);
    apex_json.write('maxTime', l_max_time);
    apex_json.write('slotDuration', to_char(trunc(sysdate) + l_duree/1440, 'HH24:MI:SS'));
    apex_json.write('businessHours', l_business_hour.stringify());
    apex_json.close_object;
end;



-----------------------------------------------------------------------------------
-- function qui retourne le prix des services pour un contrat
-- utile pour les rétrocession 
/*
Prix de vente de la concession : ( valeur negative)    nonTX
 Mettre par défaut  le prix de vente  de la concession avant tx , après ecompte
Tps à la vente : ( valeur negative) nonTX
Mettre par défaut le montant  de TPS  du contrat de concession
Tvq à la vente : ( valeur negative) nonTX
Mettre par défaut  le montant de TVQ du contrat de concession 
Débit à la vente : ( valeur positive) nonTX
Mettre par défaut le montant de note de débit  du contrat de concession 
Crédit à la vente : ( valeur negative)  nonTX
Mettre par défaut le montant  de note de crédit   du contrat de concession
Frais d’annulation : ( valeur positive) 
 = 10% de le prix de vente (avant tx, après escompte,)  Taxable
*/
-----------------------------------------------------------------------------------
function get_prix_produit(
     --p_contrat_id       in inc_contrat.id%type
    p_type_contrat     in varchar2
    ,p_service_code     in inc_produit_service.code_prod_service%type 
    ,p_prix             in number default 0
    ,p_concession_no    in inc_concession.concession_no%type
    ,p_code_section     in inc_concession.code_section%type
    ,p_code_statut      in inc_concession.code_statut%type default null
) return number as
    l_contrat       inc_contrat%rowtype;    
    l_prix          number   := 0;
    l_taux_tps      number;
    l_taux_tvq      number;    
    l_prix_propose  inc_concession.prix_propose%type;
    l_prix_vente    inc_concession.prix_vente%type;
    --l_prix_services number;
    
    l_montant_ttc   inc_facture.montant_ttc%type;
    l_montant_ht    inc_facture.montant_ht%type;
    l_nc_montant_ht inc_note_credit.montant_ht%type;
    l_nd_montant_ht inc_note_debit.montant_ht%type;
    l_montant_tps   inc_facture_detail.montant_tps%type;
    l_montant_tvq   inc_facture_detail.montant_tvq%type;
    
begin

    if p_type_contrat not in ('RET') then 
        return p_prix;
    else
    
        --> détails de la concession : ne peut pas ne rien retourner, si c'est le cas on passe par l'exception finale
        select prix_vente, prix_propose into l_prix_vente, l_prix_propose
        from inc_concession c
        where c.concession_no = p_concession_no
        and c.code_section = p_code_section;
        
        --> cherche le dernier contrat de cette concession
        begin
            select * into l_contrat
            from inc_contrat c
            where c.code_categorie = 'CON'
            and c.code_statut not in ('SOUM', 'ANN')
            and c.concession_no = p_concession_no
            and c.code_section = p_code_section
            and c.cree_le = (
                select max(c.cree_le)
                from inc_contrat c
                where c.code_categorie = 'CON'
                and c.code_statut not in ('SOUM', 'ANN')
                and c.concession_no = p_concession_no
                and c.code_section = p_code_section
                --and c.id != p_contrat_id
            )
            and rownum = 1;
            
            --> cherche le montant des produits de concession dans les factures liées au dossier
            select nvl(sum(fd.montant_tps), 0), nvl(sum(fd.montant_tvq), 0)into l_montant_tps, l_montant_tvq
            from inc_dossier d
            join inc_contrat c
              on c.dossier_id = d.id
              and c.code_statut != 'ANN'
            join inc_facture f
              on d.id = f.dossier_id
              and f.code_statut != 'ANN'
            join inc_facture_detail fd
              on f.id = fd.facture_id
            join inc_service s
              on s.service_id = fd.service_id
              and s.contrat_id = c.id
            join inc_produit_service ps
              on s.service_id = ps.id
            join inc_contrat_categorie cc
              on s.contrat_categorie_id = cc.id_contrat_cat
              and cc.code_categorie = 'CON'
            where d.id = l_contrat.dossier_id;
            
        exception when no_data_found then
            return 0;
        end;
    
        --> taux TPS
        select tarif into l_taux_tps
        from inc_produit_service
        where code_prod_service = 'TPS';
        
        --> taux TVQ
        select tarif into l_taux_tvq
        from inc_produit_service
        where code_prod_service = 'TVQ';
        
        case p_service_code
        
            -- Prix de vente de la concession : prix avant tx, après escompte : (valeur negative - nonTX)
            when 'RETRO1' then 
                l_prix := nvl(l_prix_vente, l_prix_propose) * -1;
            when 'RETRO2' then l_prix := 0;
                l_prix := nvl(l_prix_vente, l_prix_propose) * -1;
            when 'RETRO3' then l_prix := 0;
                l_prix := nvl(l_prix_vente, l_prix_propose) * -1;
            when 'RETRO4' then l_prix := 0;
                l_prix := nvl(l_prix_vente, l_prix_propose) * -1;
            
            -- Tps à la vente : montant de TPS du contrat de concession : (valeur negative -  non Taxable)
            when 'RETROTPS' then 
                l_prix := l_montant_tps * -1;
            
            -- Tvq à la vente : montant de TVQ du contrat de concession  : (valeur negative -  non Taxable)
            when 'RETROTVQ' then
                l_prix := l_montant_tvq * -1;
            -- Crédit à la vente : montant de note de crédit du contrat de concession  : (valeur negative -  non Taxable)    
            when 'RETROCT' then 
            
                select nvl(sum(ncd.montant_ht), 0) into l_nc_montant_ht
                from inc_dossier d
                join inc_contrat c
                  on c.dossier_id = d.id
                  and c.code_statut != 'ANN'
                  and d.id = l_contrat.dossier_id
                join inc_facture f
                  on d.id = f.dossier_id
                  and f.code_statut != 'ANN'
                join inc_facture_detail fd
                  on fd.facture_id = f.id
                join inc_note_credit nc
                  on nc.facture_id = f.id 
                  and nc.code_statut  = 'DEP'
                join inc_note_credit_detail ncd
                  on nc.id = ncd.note_credit_id
                  and ncd.facture_detail_id = fd.id
                join inc_service s
                  on s.service_id = fd.service_id
                  and s.contrat_id = c.id
                join inc_produit_service ps
                  on s.service_id = ps.id
                join inc_contrat_categorie cc
                  on ps.contrat_categorie_id = cc.id_contrat_cat
                  and cc.code_categorie = 'CON';
                
                l_prix := l_nc_montant_ht * -1;
            
            -- Débit à la vente : montant de note de débit du contrat de concession : (valeur positive -  non Taxable)    
            when 'RETRODT' then l_prix := 0;
            
                select nvl(sum(nbd.montant_ht), 0) into l_nd_montant_ht
                from inc_dossier d
                join inc_contrat c
                  on c.dossier_id = d.id
                  and c.code_statut != 'ANN'
                  and d.id = l_contrat.dossier_id
                join inc_facture f
                  on d.id = f.dossier_id
                  and f.code_statut != 'ANN'
                join inc_facture_detail fd
                  on fd.facture_id = f.id 
                join inc_note_debit nd
                  on nd.facture_id = f.id 
                  and nd.code_statut != 'ANN'
                join inc_note_debit_detail nbd
                  on nd.id = nbd.note_debit_id
                  and nbd.facture_detail_id = fd.id
                join inc_service s
                  on s.service_id = fd.service_id
                  and s.contrat_id = c.id
                join inc_produit_service ps
                  on s.service_id = ps.id
                join inc_contrat_categorie cc
                  on s.contrat_categorie_id = cc.id_contrat_cat
                  and cc.code_categorie = 'CON';
                
                l_prix := l_nd_montant_ht;
                
            --> Frais d’annulation : 10% de le prix de vente (avant tx, après escompte : (valeur positive - Taxable )
            when 'FRAUT01' then 
                l_prix := nvl(l_prix_vente, l_prix_propose) * 10 / 100;
            
        end case;
        
        return l_prix;
    end if;
exception
    when others then return 0;
end ;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
end INC_CONTRAT_API;