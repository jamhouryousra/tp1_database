-- ============================================
-- PARTIE 5 : TRIGGERS ET PROCÉDURES STOCKÉES
-- ============================================

-- ============================================
-- TRIGGER 1 : Limite de Participants à un Projet
-- ============================================

-- Fonction trigger
CREATE OR REPLACE FUNCTION verifier_capacite_projet()
RETURNS TRIGGER AS $$
DECLARE
    nb_participants INTEGER;
    capacite_max INTEGER;
BEGIN
    -- Récupérer la capacité max du projet (utiliser le nom exact de la colonne)
    SELECT P.capacite_max_participants INTO capacite_max
    FROM PROJETS P
    WHERE P.id_projet = NEW.id_projet;
    
    -- Compter le nombre actuel de participants (après insertion)
    SELECT COUNT(*) INTO nb_participants
    FROM PARTICIPATION_PROJET
    WHERE id_projet = NEW.id_projet;
    
    -- Vérifier si on dépasse la capacité
    IF nb_participants > capacite_max THEN
        RAISE EXCEPTION 'Capacité maximale atteinte pour le projet (max: %)', capacite_max;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger
CREATE TRIGGER trigger_capacite_projet
    AFTER INSERT ON PARTICIPATION_PROJET
    FOR EACH ROW
    EXECUTE FUNCTION verifier_capacite_projet();

-- Test du TRIGGER 1
SELECT '========== TEST TRIGGER 1 : Capacité Projet ==========' AS test;

-- Voir le nombre actuel de participants par projet
SELECT 
    P.id_projet,
    P.acronyme,
    P.capacite_max_participants AS capacite_max,
    COUNT(PP.id_chercheur) AS nb_participants_actuels,
    P.capacite_max_participants - COUNT(PP.id_chercheur) AS places_restantes
FROM PROJETS P
LEFT JOIN PARTICIPATION_PROJET PP ON P.id_projet = PP.id_projet
GROUP BY P.id_projet, P.acronyme, P.capacite_max_participants
ORDER BY places_restantes ASC
LIMIT 10;

-- Test : Forcer une erreur en réduisant la capacité

-- Exemple : Mettre capacité à 1 pour le projet 1
UPDATE PROJETS SET capacite_max_participants = 1 WHERE id_projet = 1;

-- Vérifier l'état actuel
SELECT 
    P.id_projet,
    P.acronyme,
    P.capacite_max_participants,
    COUNT(PP.id_chercheur) AS nb_participants
FROM PROJETS P
LEFT JOIN PARTICIPATION_PROJET PP ON P.id_projet = PP.id_projet
WHERE P.id_projet = 1
GROUP BY P.id_projet, P.acronyme, P.capacite_max_participants;

-- Essayer d'insérer un nouveau participant (devrait échouer si capacité déjà atteinte)
INSERT INTO PARTICIPATION_PROJET (id_projet, id_chercheur, role_participant)
VALUES (1, 109, 'Collaborateur');
-- Résultat attendu : ERREUR "Capacité maximale atteinte"

-- Restaurer la capacité normale
UPDATE PROJETS SET capacite_max_participants = 30 WHERE id_projet = 1;


-- ============================================
-- TRIGGER 2 : Vérification DMP d'un Jeu de Données
-- ============================================

-- Fonction trigger
CREATE OR REPLACE FUNCTION verifier_dmp_avant_depot()
RETURNS TRIGGER AS $$
DECLARE
    statut_dmp VARCHAR(50);
BEGIN
    -- Si on essaie de passer en statut "Déposé"
    IF NEW.statut = 'déposé' THEN
        -- Récupérer le statut du DMP du contrat associé
        SELECT C.statut_dmp INTO statut_dmp
        FROM CONTRATS C
        WHERE C.id_contrat = NEW.id_contrat;
        
        -- Vérifier que le DMP est validé
        IF statut_dmp IS NULL OR statut_dmp != 'validé' THEN
            RAISE EXCEPTION 'Impossible de déposer le dataset : le DMP du contrat doit être validé (statut actuel : %)', 
                COALESCE(statut_dmp, 'NULL');
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger
DROP TRIGGER IF EXISTS trigger_verif_dmp ON JEUX_DONNEES;
CREATE TRIGGER trigger_verif_dmp
    BEFORE INSERT OR UPDATE OF statut ON JEUX_DONNEES
    FOR EACH ROW
    EXECUTE FUNCTION verifier_dmp_avant_depot();

-- Test du TRIGGER 2
SELECT '========== TEST TRIGGER 2 : Vérification DMP ==========' AS test;

-- Voir les contrats et leur statut DMP
SELECT 
    C.id_contrat,
    C.intitule,
    C.statut_dmp,
    COUNT(JD.id_dataset) AS nb_datasets
FROM CONTRATS C
LEFT JOIN JEUX_DONNEES JD ON C.id_contrat = JD.id_contrat
GROUP BY C.id_contrat, C.intitule, C.statut_dmp
ORDER BY C.id_contrat
LIMIT 10;

-- Statistiques DMP
SELECT 
    statut_dmp,
    COUNT(*) AS nb_contrats
FROM CONTRATS
GROUP BY statut_dmp
ORDER BY nb_contrats DESC;

-- Test 1 : Essayer de déposer un dataset sur un contrat SANS DMP validé

-- Trouver un contrat sans DMP validé
SELECT id_contrat, intitule, statut_dmp 
FROM CONTRATS 
WHERE statut_dmp IS NULL OR statut_dmp != 'validé' 
LIMIT 1;

-- Essayer d'insérer un dataset "Déposé" (devrait échouer)
-- Remplacer [id_contrat_non_valide] et [id_chercheur] par des valeurs réelles
INSERT INTO JEUX_DONNEES (titre, description, id_contrat, id_auteur, 
    statut, date_creation, licence) VALUES (
    'Test Dataset Sans DMP','Ce dataset devrait être rejeté',2,
    1,  -- ID chercheur existant
    'déposé', 
    CURRENT_DATE,
    'CC-BY-4.0'
);

-- Résultat attendu : ERREUR "DMP doit être validé"


-- ============================================
-- FONCTION 1 : Nombre de Publications d'un Projet
-- ============================================

CREATE OR REPLACE FUNCTION nb_publications_projet(
    p_id_projet INTEGER,
    p_annee INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    nb_pubs INTEGER;
BEGIN
    SELECT COUNT(DISTINCT PUB.id_publication)
    INTO nb_pubs
    FROM PROJETS P
    JOIN PARTICIPATION_PROJET PP ON P.id_projet = PP.id_projet
    JOIN CHERCHEURS C ON PP.id_chercheur = C.id_chercheur
    JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
    JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication
    WHERE P.id_projet = p_id_projet
      AND EXTRACT(YEAR FROM PUB.date_publication) = p_annee;
    
    RETURN COALESCE(nb_pubs, 0);
END;
$$ LANGUAGE plpgsql;

-- Test FONCTION 1
SELECT '========== TEST FONCTION 1 : Nombre Publications ==========' AS test;

-- Tester avec différents projets et années
SELECT 
    P.id_projet,P.acronyme,
    nb_publications_projet(P.id_projet, 2024) AS nb_pubs_2024,
    nb_publications_projet(P.id_projet, 2023) AS nb_pubs_2023,
    nb_publications_projet(P.id_projet, 2022) AS nb_pubs_2022
FROM PROJETS P
ORDER BY P.id_projet
LIMIT 10;

-- ============================================
-- PROCÉDURE 2 : Préparation du Bilan d'un Projet
-- ============================================

-- Créer la table de bilan si elle n'existe pas
CREATE TABLE IF NOT EXISTS BILAN_PROJETS (
    id_projet INTEGER,
    annee INTEGER,
    nb_publications INTEGER DEFAULT 0,
    nb_datasets INTEGER DEFAULT 0,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_projet, annee)
);


-- Procédure de mise à jour du bilan
UPDATE JEUX_DONNEES
SET statut = 'Déposé'
WHERE LOWER(statut) = 'déposé';


-------------------
CREATE OR REPLACE PROCEDURE maj_bilan_projet(
    p_annee INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Supprimer les anciennes données pour cette année
    DELETE FROM BILAN_PROJETS WHERE annee = p_annee;
    
    -- Insérer les nouvelles données
    INSERT INTO BILAN_PROJETS (id_projet, annee, nb_publications, nb_datasets)
    SELECT 
        P.id_projet,
        p_annee,
        COUNT(DISTINCT PUB.id_publication) AS nb_publications,
        COUNT(DISTINCT JD.id_dataset) AS nb_datasets
    FROM PROJETS P
    LEFT JOIN PARTICIPATION_PROJET PP ON P.id_projet = PP.id_projet
    LEFT JOIN CHERCHEURS C ON PP.id_chercheur = C.id_chercheur
    LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
    LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication
        AND EXTRACT(YEAR FROM PUB.date_publication) = p_annee
    LEFT JOIN CONTRATS CT ON P.id_projet = CT.id_projet
    LEFT JOIN JEUX_DONNEES JD ON CT.id_contrat = JD.id_contrat
        AND EXTRACT(YEAR FROM JD.date_depot) = p_annee
        AND JD.statut = 'Déposé'
    GROUP BY P.id_projet;
    
    RAISE NOTICE 'Bilan mis à jour pour l''année %', p_annee;
END;
$$;

-- Test PROCÉDURE 2
SELECT '========== TEST PROCÉDURE 2 : Bilan Projet ==========' AS test;

-- Exécuter la procédure pour 2024
CALL maj_bilan_projet(2024);

-- Vérifier le contenu de la table de bilan
SELECT 
    BP.*,
    P.acronyme
FROM BILAN_PROJETS BP
JOIN PROJETS P ON BP.id_projet = P.id_projet
ORDER BY BP.id_projet, BP.annee 
LIMIT 10;

-- Statistiques du bilan
SELECT 
    annee,
    COUNT(*) AS nb_projets,
    SUM(nb_publications) AS total_publications,
    SUM(nb_datasets) AS total_datasets,
    ROUND(AVG(nb_publications), 2) AS moy_pubs,
    ROUND(AVG(nb_datasets), 2) AS moy_datasets
FROM BILAN_PROJETS
GROUP BY annee
ORDER BY annee DESC;




-- ============================================
-- FONCTION 3 : Fiche Projet
-- ============================================

CREATE OR REPLACE FUNCTION fiche_projet(p_id_projet INTEGER)
RETURNS TABLE (
    type_element VARCHAR,
    titre VARCHAR,
    annee INTEGER,
    details TEXT
) AS $$
BEGIN
    -- Retourner les publications du projet
    RETURN QUERY
    SELECT 
        'Publication'::VARCHAR AS type_element,
        PUB.titre::VARCHAR,
        EXTRACT(YEAR FROM PUB.date_publication)::INTEGER AS annee,
        ('DOI: ' || COALESCE(PUB.doi, 'N/A') || ' | Type: ' || PUB.type_publication)::TEXT AS details
    FROM PROJETS P
    JOIN PARTICIPATION_PROJET PP ON P.id_projet = PP.id_projet
    JOIN CHERCHEURS C ON PP.id_chercheur = C.id_chercheur
    JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
    JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication
    WHERE P.id_projet = p_id_projet
    
    UNION ALL
    
    -- Retourner les datasets du projet
    SELECT 
        'Dataset'::VARCHAR AS type_element,
        JD.titre::VARCHAR,
        EXTRACT(YEAR FROM JD.date_creation)::INTEGER AS annee,
        ('Statut: ' || JD.statut || ' | Licence: ' || COALESCE(JD.licence, 'N/A'))::TEXT AS details
    FROM PROJETS P
    JOIN CONTRATS CT ON P.id_projet = CT.id_projet
    JOIN JEUX_DONNEES JD ON CT.id_contrat = JD.id_contrat
    WHERE P.id_projet = p_id_projet
    
    ORDER BY annee DESC, type_element;
END;
$$ LANGUAGE plpgsql;

-- Test FONCTION 3
SELECT '========== TEST FONCTION 3 : Fiche Projet ==========' AS test;

-- Afficher la fiche des premiers projets
SELECT 
    P.id_projet,
    P.acronyme,
    '--- Fiche détaillée ---' AS separateur
FROM PROJETS P
ORDER BY P.id_projet
LIMIT 3;

-- Exemple : Fiche complète du projet 1
SELECT * FROM fiche_projet(1);

-- Compter les éléments par projet
SELECT 
    P.id_projet,
    P.acronyme,
    COUNT(CASE WHEN FP.type_element = 'Publication' THEN 1 END) AS nb_publications,
    COUNT(CASE WHEN FP.type_element = 'Dataset' THEN 1 END) AS nb_datasets
FROM PROJETS P
CROSS JOIN LATERAL fiche_projet(P.id_projet) FP
GROUP BY P.id_projet, P.acronyme
ORDER BY P.id_projet
LIMIT 10;

-- ============================================
-- PROCÉDURE 4 : Archivage des Contrats Échus
-- ============================================

-- Créer la table d'archives si elle n'existe pas
CREATE TABLE IF NOT EXISTS CONTRATS_ARCHIVES (
    LIKE CONTRATS INCLUDING ALL
);

-- Ajouter une colonne date_archivage
ALTER TABLE CONTRATS_ARCHIVES 
ADD COLUMN date_archivage TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Procédure d'archivage
CREATE OR REPLACE PROCEDURE archiver_contrats_echus(
    p_date_seuil DATE
)
LANGUAGE plpgsql AS $$
DECLARE
    nb_archives INTEGER;
BEGIN
    -- Insérer les contrats échus dans la table d'archives
    INSERT INTO CONTRATS_ARCHIVES (
        id_contrat, 
        type_financement,    -- ✅ CORRIGÉ
        financeur, 
        intitule, 
        montant, 
        date_debut, 
        date_fin, 
        id_projet, 
        statut_dmp, 
        date_validation_dmp, 
        lien_document_dmp,   -- ✅ CORRIGÉ
        reference_contrat,   -- ✅ AJOUTÉ
        montant_consomme,    -- ✅ AJOUTÉ
        date_archivage
    )
    SELECT 
        id_contrat, 
        type_financement,
        financeur, 
        intitule, 
        montant,
        date_debut, 
        date_fin, 
        id_projet, 
        statut_dmp,
        date_validation_dmp, 
        lien_document_dmp,
        reference_contrat,
        montant_consomme,
        CURRENT_TIMESTAMP
    FROM CONTRATS
    WHERE date_fin < p_date_seuil
      AND id_contrat NOT IN (SELECT id_contrat FROM CONTRATS_ARCHIVES);
    
    GET DIAGNOSTICS nb_archives = ROW_COUNT;
    
    -- Supprimer les contrats archivés de la table principale
    DELETE FROM CONTRATS
    WHERE date_fin < p_date_seuil;
    
    RAISE NOTICE '% contrats archivés et supprimés de la table CONTRATS', nb_archives;
END;
$$;

-- Test PROCÉDURE 4
SELECT '========== TEST PROCÉDURE 4 : Archivage Contrats ==========' AS test;

-- Voir les contrats échus (avant 2023)
SELECT 
    id_contrat,
    intitule,
    date_debut,
    date_fin,
    CURRENT_DATE - date_fin AS jours_depuis_fin,
    CASE 
        WHEN date_fin < CURRENT_DATE THEN 'Échu'
        ELSE ' En cours'
    END AS statut
FROM CONTRATS
WHERE date_fin < '2025-01-01'
ORDER BY date_fin
LIMIT 10;

-- Compter les contrats échus par année
SELECT 
    EXTRACT(YEAR FROM date_fin) AS annee_fin,
    COUNT(*) AS nb_contrats_echus
FROM CONTRATS
WHERE date_fin < CURRENT_DATE
GROUP BY EXTRACT(YEAR FROM date_fin)
ORDER BY annee_fin DESC;

-- Archiver les contrats terminés avant 2025
-- Cette commande SUPPRIME les contrats de la table principale !
-------------------**********************
--  une COPIE
CREATE TABLE CONTRATS_BACKUP AS SELECT * FROM CONTRATS;

-- Faire vos tests d'archivage
CALL archiver_contrats_echus('2025-01-01');

-- Si problème, restaurer :
DELETE FROM CONTRATS;
INSERT INTO CONTRATS SELECT * FROM CONTRATS_BACKUP;
DROP TABLE CONTRATS_BACKUP;

SELECT '========================================' AS separateur;
SELECT '       ✅ PARTIE 5 TERMINÉE            ' AS titre;
SELECT '========================================' AS separateur;