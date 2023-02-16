create or replace PACKAGE "INC_CONTRAT_API" is
  
--------------------------------------------------------------------------------
-- ***** CONSTANTES *****
--------------------------------------------------------------------------------  
    co_type_r           constant varchar2(15)  := 'R';
    co_type_p           constant varchar2(15)  := 'P';
    
    co_statut_en_cours  constant varchar2(15)  := 'COUR';
    co_statut_soumis    constant varchar2(15)  := 'SOUM';
    co_statut_completer constant varchar2(15)  := 'COMP';
    co_statut_annuler   constant varchar2(15)  := 'ANN';
    co_statut_recuperer constant varchar2(15)  := 'RECUP'; 
    
    function get_co_type_r return varchar2 deterministic;
    function get_co_type_p return varchar2 deterministic;
    
    function get_co_statut_en_cours return varchar2 deterministic;
    function get_co_statut_soumis return varchar2 deterministic;
    function get_co_statut_completer return varchar2 deterministic;
    function get_co_statut_annuler return varchar2 deterministic;
    
    
--------------------------------------------------------------
-- fonction d'affectation pour la table inc_contrat
    function affect_contrat (p_valeurs       in     notes_data.t_table_valeurs
                            )            return     inc_contrat%rowtype;

--------------------------------------------------------------
-- procedure de creation pour la table inc_contrat
   procedure cre_contrat (p_contrat_rec in out inc_contrat%rowtype);

--------------------------------------------------------------
-- procedure de mise à jour pour table inc_contrat
   procedure mod_contrat (p_contrat_rec in out inc_contrat%rowtype
                         ,p_md5         in     varchar2 default null);

--------------------------------------------------------------
-- procedure de mise à jour du code statut dans la table inc_contrat
   procedure mod_statut (p_contrat_id  in number
                         ,p_code_statut in varchar2
                         ,p_raison      in varchar2 default null);

--------------------------------------------------------------
-- procedure de suppression pour table inc_contrat
   procedure sup_contrat (p_id in number);

--------------------------------------------------------------
--  fonction de creation/modification pour la table inc_contrat
    function merge_contrat (p_contrat_rec   in   notes_data.t_table_valeurs
                           ,p_donnees_compl in   varchar2
                           )            return   inc_contrat.id%type;

--------------------------------------------------------------
-- procedure de recherche pour table inc_contrat
   procedure trouver_contrat (p_id          in      number
                             ,p_notes_unid  in     varchar2
                             ,p_contrat_rec    out inc_contrat%rowtype);

--------------------------------------------------------------
-- procedure de recherche avec ancienne valeur MD5 pour table inc_contrat
   procedure trouver_contrat (p_id          in     number
                             ,p_notes_unid  in     varchar2
                             ,p_contrat_rec    out inc_contrat%rowtype
                             ,p_md5            out varchar2);

--------------------------------------------------------------
-- fonction de construction MD5 pour table inc_contrat
   function gen_contrat_md5 (p_contrat_rec in     inc_contrat%rowtype
                            )          return     varchar2;

-----------------------------------------------------------------------------
-- fonction generant un identifiant unique visible pour la table des contrats
   function gen_contrat_no  (p_code_type      in varchar2
                            ,p_code_categorie in varchar2 default null
                            )             return varchar2;

-----------------------------------------------------------------------------------------------------------------------------
--  Procédure permettant de transférer les données sur les conjoints de la table INC_CONTRAT à la table INC_CONTACT
    procedure transferer_conjoints (p_nbr_max    in number default 2000000
                                   ,p_contrat_id in number default null);

-----------------------------------------------------------------------------------
-- procedure de mise à jour du statut du contrat
   procedure change_statut_contrat (p_contrat_id          in inc_contrat.id%type
                                   ,p_nouveau_code_statut in inc_contrat.code_statut%type
                                   ,out_statut            out varchar2
                                   ,out_err_message       out varchar2);
-----------------------------------------------------------------------------------
-- procedure de récupération d'un contrat
   procedure recuperer_contrat (p_contrat_id            in  inc_contrat.id%type
                               ,p_new_contrat_id        out inc_contrat.id%type
                               ,p_flow_diagram_requete  in varchar2
                               ,out_statut              out varchar2
                               ,out_err_message         out varchar2);
-----------------------------------------------------------------------------------  
-- procedure de retour au PA lors de l'annulation d'un contrat  
   procedure retour_au_pa (p_contrat_id              in  inc_contrat.id%type);
-----------------------------------------------------------------------------------
-- Modifie un contrat - table inc_contrat
procedure modifie_contrat (
    p_contrat              in inc_contrat%rowtype,
    out_statut             out varchar2,
    out_message            out varchar2
);
-----------------------------------------------------------------------------------
-- function de recherche de la valeur de un specficite par code ou id, et id du contrat
function get_spec_val_code (p_code_spec            in inc_specificites.code_spec%type
                           ,p_contrat_id           in inc_contrat.id%type
                           ) return inc_spec_data.valeur%type;
-----------------------------------------------------------------------------------
-- function qui calcule le prix des services pour un contrat
-----------------------------------------------------------------------------------
function get_prix_service(
     p_dossier_id       in inc_dossier.id%type default null
    ,p_contrat_id       in inc_contrat.id%type default null
    ,p_service_id       in inc_service.id%type default null
    ,p_type_montant     in varchar2 default 'PRIX_TAXE'
) return number;
-----------------------------------------------------------------------------------
-- function qui vérifie si la section est dupliqué ou non
-----------------------------------------------------------------------------------
function section_is_duplicated(p_nom_section in inc_section.nom_section%type
) return boolean;
-----------------------------------------------------------------------------------
-- procedure pour dupliquer le contact dans les contrats du dossier
-----------------------------------------------------------------------------------
procedure duplicate_contact_section(p_type_contact in varchar2
    ,p_id_dossier inc_dossier.id%type
    ,p_contact_no inc_contact.contact_no%type
    ,p_id_contrat inc_contrat.id%type default null
);
-----------------------------------------------------------------------------------
-- procedure pour dupliquer les contacts dans les nouveaux contrats du dossier (Modififier dossier)
-----------------------------------------------------------------------------------
procedure duplicate_contact_dossier(p_id_dossier inc_dossier.id%type
    ,p_id_contrat inc_contrat.id%type 
);

-----------------------------------------------------------------------------------
-- procedure qui redémarre les flows d'APEX et qui repositionne le contrat à "En Cours"
-- @p_contrat_id : ID du contrat
-- @out_statut : statut de retour (ERROR / SUCCESS)
-- @out_message : message retourné ou null si tout s'est bien passé
-----------------------------------------------------------------------------------
procedure redemarre_flow_contrat (
    p_contrat_id          in inc_contrat.id%type
   ,out_statut            out varchar2
   ,out_message           out varchar2
);

-----------------------------------------------------------------------------------
-- procedure de mise à jour du statut du contrat à COMPLETER
-- Deux conditions nécessaires : 
--      1. tous les services sont rendus
--      2. tous les services sont payés
-- @p_contrat_id : ID du contrat
-- @out_statut : statut de retour (ERROR / SUCCESS)
-- @out_message : message retourné ou null si tout s'est bien passé
-----------------------------------------------------------------------------------
procedure complete_contrat (
    p_contrat_id          in inc_contrat.id%type
   ,out_statut            out varchar2
   ,out_message           out varchar2
);
-----------------------------------------------------------------------------------
-- procedure de mise à jour du statut du contrat à COMPLETER
-- Deux conditions nécessaires : 
--      1. tous les services sont rendus
--      2. tous les services sont payés
-- @p_facture_id : ID de la facture
-- @out_statut : statut de retour (ERROR / SUCCESS)
-- @out_message : message retourné ou null si tout s'est bien passé
-----------------------------------------------------------------------------------
procedure complete_contrat_facture (
    p_facture_id          in inc_facture.id%type
   ,out_statut            out varchar2
   ,out_message           out varchar2
);

-----------------------------------------------------------------------------------
-- procedure utilisée dans la page 500 pour gérer les règles de réservations
-- des calendriers d'inhumations
-----------------------------------------------------------------------------------
procedure get_reservation_cal_business_hours;

-----------------------------------------------------------------------------------
-- function qui retourne le prix des services pour un contrat
-- utile pour les rétrocession
-----------------------------------------------------------------------------------
function get_prix_produit(
--     p_contrat_id       in inc_contrat.id%type
     p_type_contrat     in varchar2
    ,p_service_code     in inc_produit_service.code_prod_service%type 
    ,p_prix             in number default 0
    ,p_concession_no    in inc_concession.concession_no%type
    ,p_code_section     in inc_concession.code_section%type
    ,p_code_statut      in inc_concession.code_statut%type default null
) return number;


-----------------------------------------------------------------------------------
end INC_CONTRAT_API;

