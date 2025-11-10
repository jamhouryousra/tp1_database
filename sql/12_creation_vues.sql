-- ============================================
-- PARTIE 3.2 : CRÉATION DES VUES
-- ============================================

-- ============================================
-- VUE 1 : VUE_PROJETS_CHERCHEURS
-- ============================================
CREATE OR REPLACE VIEW VUE_PROJETS_CHERCHEURS AS
SELECT 
    P.id_projet,
    P.acronyme,
    P.titre,
    P.discipline,
    P.statut AS statut_projet,
    P.date_debut,
    P.date_fin,
    L.nom AS laboratoire_pilote,
    C_resp.nom || ' ' || C_resp.prenom AS responsable_projet,
    COUNT(DISTINCT PP.id_chercheur) AS nb_participants,
    P.capacite_max_participants,
    P.budget_annuel
FROM PROJETS P
LEFT JOIN LABORATOIRES L ON P.id_laboratoire_pilote = L.id_laboratoire
LEFT JOIN CHERCHEURS C_resp ON P.id_responsable = C_resp.id_chercheur
LEFT JOIN PARTICIPATION_PROJET PP ON P.id_projet = PP.id_projet
GROUP BY P.id_projet, P.acronyme, P.titre, P.discipline, P.statut, 
         P.date_debut, P.date_fin, L.nom, C_resp.nom, C_resp.prenom, 
         P.capacite_max_participants, P.budget_annuel;

-- ============================================
-- VUE 2 : VUE_PUBLICATIONS_PROJET
-- ============================================
CREATE OR REPLACE VIEW VUE_PUBLICATIONS_PROJET AS
SELECT 
    PUB.id_publication,
    PUB.titre AS titre_publication,
    PUB.doi,
    PUB.date_publication,
    PUB.type_publication,
    PUB.nb_citations,
    P.acronyme AS projet_acronyme,
    P.titre AS projet_titre,
    STRING_AGG(C.nom || ' ' || C.prenom, ', ' ORDER BY AP.ordre_auteur) AS auteurs
FROM PUBLICATIONS PUB
LEFT JOIN PROJETS P ON PUB.id_projet = P.id_projet
LEFT JOIN AUTEURS_PUBLICATION AP ON PUB.id_publication = AP.id_publication
LEFT JOIN CHERCHEURS C ON AP.id_chercheur = C.id_chercheur
GROUP BY PUB.id_publication, PUB.titre, PUB.doi, PUB.date_publication, 
         PUB.type_publication, PUB.nb_citations, P.acronyme, P.titre;

-- ============================================
-- VUE 3 : VUE_DATASETS_CONFORMITE
-- ============================================
CREATE OR REPLACE VIEW VUE_DATASETS_CONFORMITE AS
SELECT 
    JD.id_dataset,
    JD.titre AS titre_dataset,
    JD.statut,
    JD.date_creation,
    JD.date_depot,
    JD.licence,
    JD.conditions_acces,
    JD.version_jd,
    C_auteur.nom || ' ' || C_auteur.prenom AS auteur,
    CONT.reference_contrat,
    CONT.statut_dmp,
    P.acronyme AS projet_acronyme,
    CASE 
        WHEN JD.licence IS NULL OR JD.date_depot IS NULL THEN 'Non conforme'
        ELSE 'Conforme'
    END AS conformite,
    CASE 
        WHEN JD.statut = 'Déposé' AND CONT.statut_dmp != 'validé' THEN 'Alerte DMP'
        WHEN JD.statut = 'Déposé' AND (JD.licence IS NULL OR JD.date_depot IS NULL) THEN 'Alerte Métadonnées'
        ELSE 'OK'
    END AS alerte
FROM JEUX_DONNEES JD
JOIN CHERCHEURS C_auteur ON JD.id_auteur = C_auteur.id_chercheur
JOIN CONTRATS CONT ON JD.id_contrat = CONT.id_contrat
JOIN PROJETS P ON CONT.id_projet = P.id_projet;

-- ============================================
-- VUE 4 : VUE_CONTRATS_FINANCEMENT
-- ============================================
CREATE OR REPLACE VIEW VUE_CONTRATS_FINANCEMENT AS
SELECT 
    CONT.id_contrat,
    CONT.reference_contrat,
    CONT.type_financement,
    CONT.financeur,
    CONT.intitule,
    CONT.montant,
    CONT.montant_consomme,
    CONT.montant - CONT.montant_consomme AS montant_restant,
    ROUND((CONT.montant_consomme::NUMERIC / CONT.montant) * 100, 2) AS taux_consommation,
    CONT.date_debut,
    CONT.date_fin,
    CONT.statut_dmp,
    CONT.date_validation_dmp,
    P.acronyme AS projet_acronyme,
    P.titre AS projet_titre,
    COUNT(JD.id_dataset) AS nb_datasets
FROM CONTRATS CONT
JOIN PROJETS P ON CONT.id_projet = P.id_projet
LEFT JOIN JEUX_DONNEES JD ON CONT.id_contrat = JD.id_contrat
GROUP BY CONT.id_contrat, CONT.reference_contrat, CONT.type_financement, 
         CONT.financeur, CONT.intitule, CONT.montant, CONT.montant_consomme,
         CONT.date_debut, CONT.date_fin, CONT.statut_dmp, CONT.date_validation_dmp,
         P.acronyme, P.titre;

-- ============================================
-- VUE 5 : VUE_CHERCHEURS_ACTIVITE
-- ============================================
CREATE OR REPLACE VIEW VUE_CHERCHEURS_ACTIVITE AS
SELECT 
    C.id_chercheur,
    C.nom,
    C.prenom,
    C.email,
    C.statut,
    C.discipline,
    L.nom AS laboratoire,
    L.code_umr,
    COUNT(DISTINCT AP.id_publication) AS nb_publications,
    COUNT(DISTINCT JD.id_dataset) AS nb_datasets,
    COUNT(DISTINCT PP.id_projet) AS nb_projets,
    STRING_AGG(DISTINCT P.acronyme, ', ') AS projets_actuels
FROM CHERCHEURS C
LEFT JOIN LABORATOIRES L ON C.id_laboratoire = L.id_laboratoire
LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
LEFT JOIN JEUX_DONNEES JD ON C.id_chercheur = JD.id_auteur
LEFT JOIN PARTICIPATION_PROJET PP ON C.id_chercheur = PP.id_chercheur
LEFT JOIN PROJETS P ON PP.id_projet = P.id_projet
GROUP BY C.id_chercheur, C.nom, C.prenom, C.email, C.statut, 
         C.discipline, L.nom, L.code_umr;

-- ============================================
-- VÉRIFICATION
-- ============================================
SELECT 
    table_name,
    'Vue créée' AS statut
FROM information_schema.views 
WHERE table_schema = 'public' 
  AND table_name LIKE 'vue_%'
ORDER BY table_name;