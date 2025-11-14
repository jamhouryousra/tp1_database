-- ============================================
-- REQUÊTE R2 : Projets sans Chercheurs Peu Productifs
-- ============================================
-- Pour le labo LISA en 2024 : projets où AUCUN chercheur
-- n'a moins de publications que la moyenne du labo
-- VERSION AVEC VUE + VERSION SANS VUE + VERSION OPTIMISÉE
-- ============================================

-- ============================================
-- VERSION 1 : AVEC VUE (NOT EXISTS)
-- ============================================

CREATE OR REPLACE VIEW R2_VERSION1 AS
WITH moyenne_labo AS (
    SELECT AVG(nb_pubs)::NUMERIC AS moyenne
    FROM (
        SELECT C.id_chercheur,COUNT(DISTINCT AP.id_publication) AS nb_pubs
        FROM CHERCHEURS C
        JOIN LABORATOIRES L ON C.id_laboratoire = L.id_laboratoire
        LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
        LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication 
        AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
        WHERE L.nom = 'LISA Identités Espaces'
        GROUP BY C.id_chercheur
    ) AS publications_par_chercheur
)
SELECT DISTINCT
    P.titre AS projet_titre,
	C_resp.nom || ' ' || C_resp.prenom AS responsable_nom
FROM PROJETS P
JOIN CHERCHEURS C_resp ON P.id_responsable = C_resp.id_chercheur
JOIN LABORATOIRES L ON P.id_laboratoire_pilote = L.id_laboratoire
WHERE 
    L.nom = 'LISA Identités Espaces'
    AND NOT EXISTS (
        SELECT 1
        FROM PARTICIPATION_PROJET PP
        JOIN CHERCHEURS C ON PP.id_chercheur = C.id_chercheur
        LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
        LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication
            AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
        WHERE 
            PP.id_projet = P.id_projet
        GROUP BY C.id_chercheur
        HAVING COUNT(DISTINCT PUB.id_publication) < (SELECT moyenne FROM moyenne_labo)
    )
ORDER BY projet_titre;

-- Test VERSION 1 AVEC VUE
SELECT '========== VERSION 1 : AVEC VUE (NOT EXISTS) ==========' AS titre;
EXPLAIN ANALYZE
SELECT * FROM R2_VERSION1;

-- ============================================
-- VERSION 2 : SANS VUE (MIN/HAVING)
-- ============================================

SELECT '========== VERSION 2 : SANS VUE (MIN/HAVING) ==========' AS titre;

EXPLAIN ANALYZE
WITH moyenne_labo AS (
    SELECT AVG(nb_pubs)::NUMERIC AS moyenne
    FROM (
        SELECT 
            C.id_chercheur,
            COUNT(DISTINCT AP.id_publication) AS nb_pubs
        FROM CHERCHEURS C
        JOIN LABORATOIRES L ON C.id_laboratoire = L.id_laboratoire
        LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
        LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication 
            AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
        WHERE L.nom = 'LISA Identités Espaces'
        GROUP BY C.id_chercheur
    ) AS pubs
),
chercheurs_publications AS (
    SELECT 
        PP.id_projet,
        C.id_chercheur,
        COUNT(DISTINCT PUB.id_publication) AS nb_publications_2024
    FROM PARTICIPATION_PROJET PP
    JOIN CHERCHEURS C ON PP.id_chercheur = C.id_chercheur
    LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
    LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication
        AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
    GROUP BY PP.id_projet, C.id_chercheur
),
projets_ok AS (
    SELECT id_projet
    FROM chercheurs_publications, moyenne_labo
    GROUP BY id_projet
    HAVING MIN(nb_publications_2024) >= (SELECT moyenne FROM moyenne_labo)
)
SELECT 
    P.titre AS projet_titre,
    C_resp.nom || ' ' || C_resp.prenom AS responsable_nom
FROM PROJETS P
JOIN CHERCHEURS C_resp ON P.id_responsable = C_resp.id_chercheur
JOIN LABORATOIRES L ON P.id_laboratoire_pilote = L.id_laboratoire
WHERE 
    L.nom = 'LISA Identités Espaces'
    AND P.id_projet IN (SELECT id_projet FROM projets_ok)
ORDER BY projet_titre;

-- ============================================
-- VERSION 3 : VUE OPTIMISÉE (MIN/HAVING)
-- ============================================

CREATE OR REPLACE VIEW R2_VERSION3 AS
WITH moyenne_labo AS (
    SELECT AVG(nb_pubs)::NUMERIC AS moyenne
    FROM (
        SELECT 
            C.id_chercheur,
            COUNT(DISTINCT AP.id_publication) AS nb_pubs
        FROM CHERCHEURS C
        JOIN LABORATOIRES L ON C.id_laboratoire = L.id_laboratoire
        LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
        LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication 
            AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
        WHERE L.nom = 'LISA Identités Espaces'
        GROUP BY C.id_chercheur
    ) AS pubs
),
chercheurs_publications AS (
    SELECT 
        PP.id_projet,
        C.id_chercheur,
        COUNT(DISTINCT PUB.id_publication) AS nb_publications_2024
    FROM PARTICIPATION_PROJET PP
    JOIN CHERCHEURS C ON PP.id_chercheur = C.id_chercheur
    LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
    LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication
        AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
    GROUP BY PP.id_projet, C.id_chercheur
),
projets_ok AS (
    SELECT id_projet
    FROM chercheurs_publications, moyenne_labo
    GROUP BY id_projet
    HAVING MIN(nb_publications_2024) >= (SELECT moyenne FROM moyenne_labo)
)
SELECT 
    P.titre AS projet_titre,
    C_resp.nom || ' ' || C_resp.prenom AS responsable_nom
FROM PROJETS P
JOIN CHERCHEURS C_resp ON P.id_responsable = C_resp.id_chercheur
JOIN LABORATOIRES L ON P.id_laboratoire_pilote = L.id_laboratoire
WHERE 
    L.nom = 'LISA Identités Espaces'
    AND P.id_projet IN (SELECT id_projet FROM projets_ok)
ORDER BY projet_titre;

-- Test VERSION 3 VUE OPTIMISÉE
SELECT '========== VERSION 3 : VUE OPTIMISÉE (MIN/HAVING) ==========' AS titre;
EXPLAIN ANALYZE
SELECT * FROM R2_VERSION3;

-- ============================================
-- CRÉATION DES INDEX
-- ============================================

-- Index fonctionnel sur l'année de publication
CREATE INDEX IF NOT EXISTS idx_publications_annee ON PUBLICATIONS(EXTRACT(YEAR FROM date_publication));

-- Index sur le nom du laboratoire (filtre WHERE L.nom = 'Stella Mare')
CREATE INDEX IF NOT EXISTS idx_laboratoires_nom ON LABORATOIRES(nom);

-- Mise à jour des statistiques
ANALYZE PUBLICATIONS;
ANALYZE LABORATOIRES;
ANALYZE AUTEURS_PUBLICATION;
ANALYZE PARTICIPATION_PROJET;


-- ============================================
-- RE-TESTS APRÈS INDEX
-- ============================================

SELECT '========== APRÈS INDEX : VERSION 1 (VUE - NOT EXISTS) ==========' AS titre;
EXPLAIN ANALYZE SELECT * FROM R2_VERSION1;

SELECT '========== APRÈS INDEX : VERSION 2 (SELECT - MIN/HAVING) ==========' AS titre;
EXPLAIN ANALYZE
WITH moyenne_labo AS (
    SELECT AVG(nb_pubs)::NUMERIC AS moyenne
    FROM (
        SELECT 
            C.id_chercheur,
            COUNT(DISTINCT AP.id_publication) AS nb_pubs
        FROM CHERCHEURS C
        JOIN LABORATOIRES L ON C.id_laboratoire = L.id_laboratoire
        LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
        LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication 
            AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
        WHERE L.nom = 'LISA Identités Espaces'
        GROUP BY C.id_chercheur
    ) AS pubs
),
chercheurs_publications AS (
    SELECT 
        PP.id_projet,
        C.id_chercheur,
        COUNT(DISTINCT PUB.id_publication) AS nb_publications_2024
    FROM PARTICIPATION_PROJET PP
    JOIN CHERCHEURS C ON PP.id_chercheur = C.id_chercheur
    LEFT JOIN AUTEURS_PUBLICATION AP ON C.id_chercheur = AP.id_chercheur
    LEFT JOIN PUBLICATIONS PUB ON AP.id_publication = PUB.id_publication
        AND EXTRACT(YEAR FROM PUB.date_publication) = 2024
    GROUP BY PP.id_projet, C.id_chercheur
),
projets_ok AS (
    SELECT id_projet
    FROM chercheurs_publications, moyenne_labo
    GROUP BY id_projet
    HAVING MIN(nb_publications_2024) >= (SELECT moyenne FROM moyenne_labo)
)
SELECT 
    P.titre AS projet_titre,
    C_resp.nom || ' ' || C_resp.prenom AS responsable_nom
FROM PROJETS P
JOIN CHERCHEURS C_resp ON P.id_responsable = C_resp.id_chercheur
JOIN LABORATOIRES L ON P.id_laboratoire_pilote = L.id_laboratoire
WHERE 
    L.nom = 'LISA Identités Espaces'
    AND P.id_projet IN (SELECT id_projet FROM projets_ok)
ORDER BY projet_titre;

SELECT '========== APRÈS INDEX : VERSION 3 (VUE OPTIMISÉE) ==========' AS titre;
EXPLAIN ANALYZE SELECT * FROM R2_VERSION3;
