-- ============================================
-- REQUÊTE R3 : Laboratoires sans Datasets Non Conformes en 2024
-- ============================================
-- Laboratoires où AUCUN dataset de 2024 n'est non conforme
-- VERSION AVEC VUE + VERSION SANS VUE + VERSION OPTIMISÉE
-- ============================================

-- ============================================
-- VERSION 1 : AVEC VUE (NOT EXISTS)
-- ============================================

CREATE OR REPLACE VIEW R3_VERSION1 AS
SELECT DISTINCT L.id_laboratoire,L.nom AS laboratoire,L.code_umr
FROM LABORATOIRES L
WHERE NOT EXISTS (
    SELECT *
    FROM CHERCHEURS C JOIN JEUX_DONNEES JD ON C.id_chercheur = JD.id_auteur
    WHERE C.id_laboratoire = L.id_laboratoire
        AND EXTRACT(YEAR FROM JD.date_creation) = 2021
        AND (JD.licence IS NULL OR JD.date_depot IS NULL)
)
ORDER BY laboratoire;

-- Test VERSION 1 AVEC VUE
SELECT '========== VERSION 1 : AVEC VUE (NOT EXISTS) ==========' AS titre;
EXPLAIN ANALYZE
SELECT * FROM R3_VERSION1;

-- ============================================
-- VERSION 2 : SANS VUE (EXCEPT)
-- ============================================

SELECT '========== VERSION 2 : SANS VUE (EXCEPT) ==========' AS titre;

EXPLAIN ANALYZE
SELECT L.id_laboratoire,L.nom AS laboratoire,L.code_umr
FROM LABORATOIRES L EXCEPT
	SELECT DISTINCT L.id_laboratoire,L.nom,L.code_umr
	FROM LABORATOIRES L
	JOIN CHERCHEURS C ON L.id_laboratoire = C.id_laboratoire
	JOIN JEUX_DONNEES JD ON C.id_chercheur = JD.id_auteur
	WHERE EXTRACT(YEAR FROM JD.date_creation) = 2021
	    AND (JD.licence IS NULL OR JD.date_depot IS NULL)
ORDER BY laboratoire;

-- ============================================
-- VERSION 3 : VUE OPTIMISÉE (LEFT JOIN + HAVING)
-- ============================================

CREATE OR REPLACE VIEW R3_VERSION3 AS
SELECT L.id_laboratoire,L.nom AS laboratoire,L.code_umr
FROM LABORATOIRES L
LEFT JOIN CHERCHEURS C ON L.id_laboratoire = C.id_laboratoire
LEFT JOIN JEUX_DONNEES JD ON C.id_chercheur = JD.id_auteur
    AND EXTRACT(YEAR FROM JD.date_creation) = 2021
    AND (JD.licence IS NULL OR JD.date_depot IS NULL)
GROUP BY L.id_laboratoire, L.nom, L.code_umr
HAVING COUNT(JD.id_dataset) = 0
ORDER BY laboratoire;

-- Test VERSION 3 VUE OPTIMISÉE
SELECT '========== VERSION 3 : VUE OPTIMISÉE (LEFT JOIN) ==========' AS titre;
EXPLAIN ANALYZE
SELECT * FROM R3_VERSION3;

-- ============================================
-- VERSION 4 : NON VUE JUST SELECT (LEFT JOIN + HAVING)
-- ============================================

EXPLAIN ANALYZE
SELECT L.id_laboratoire,L.nom AS laboratoire,L.code_umr
FROM LABORATOIRES L
LEFT JOIN CHERCHEURS C ON L.id_laboratoire = C.id_laboratoire
LEFT JOIN JEUX_DONNEES JD ON C.id_chercheur = JD.id_auteur
    AND EXTRACT(YEAR FROM JD.date_creation) = 2021
    AND (JD.licence IS NULL OR JD.date_depot IS NULL)
GROUP BY L.id_laboratoire, L.nom, L.code_umr
HAVING COUNT(JD.id_dataset) = 0
ORDER BY laboratoire;
-- ============================================
-- CRÉATION DES INDEX
-- ============================================

CREATE INDEX IF NOT EXISTS idx_jeux_donnees_annee_creation 
ON JEUX_DONNEES(EXTRACT(YEAR FROM date_creation));

CREATE INDEX IF NOT EXISTS idx_jeux_donnees_non_conformes 
ON JEUX_DONNEES(id_auteur, date_creation)
WHERE licence IS NULL OR date_depot IS NULL;

CREATE INDEX IF NOT EXISTS idx_jeux_donnees_id_auteur 
ON JEUX_DONNEES(id_auteur);


-- ============================================
-- RE-TESTS APRÈS INDEX
-- ============================================

SELECT '========== APRÈS INDEX : VERSION 1 (VUE - NOT EXISTS) ==========' AS titre;
EXPLAIN ANALYZE SELECT * FROM R3_VERSION1;

SELECT '========== APRÈS INDEX : VERSION 2 (SELECT - EXCEPT) ==========' AS titre;
EXPLAIN ANALYZE
SELECT L.id_laboratoire,L.nom AS laboratoire,L.code_umr
FROM LABORATOIRES L EXCEPT
SELECT DISTINCT L.id_laboratoire,L.nom,L.code_umr
FROM LABORATOIRES L
JOIN CHERCHEURS C ON L.id_laboratoire = C.id_laboratoire
JOIN JEUX_DONNEES JD ON C.id_chercheur = JD.id_auteur
WHERE EXTRACT(YEAR FROM JD.date_creation) = 2021
    AND (JD.licence IS NULL OR JD.date_depot IS NULL)
ORDER BY laboratoire;

SELECT '========== APRÈS INDEX : VERSION 3 (VUE OPTIMISÉE) ==========' AS titre;
EXPLAIN ANALYZE SELECT * FROM R3_VERSION3;

SELECT '========== APRÈS INDEX : VERSION 4 (SELECT - LEFT JOIN AND HAVING) ==========' AS titre;
EXPLAIN ANALYZE
SELECT L.id_laboratoire,L.nom AS laboratoire,L.code_umr
FROM LABORATOIRES L
LEFT JOIN CHERCHEURS C ON L.id_laboratoire = C.id_laboratoire
LEFT JOIN JEUX_DONNEES JD ON C.id_chercheur = JD.id_auteur
    AND EXTRACT(YEAR FROM JD.date_creation) = 2021
    AND (JD.licence IS NULL OR JD.date_depot IS NULL)
GROUP BY L.id_laboratoire, L.nom, L.code_umr
HAVING COUNT(JD.id_dataset) = 0
ORDER BY laboratoire;
-- ============================================
-- RÉSULTATS À NOTER
-- ============================================
/*
AVANT INDEX :
- VERSION 1 (VUE - NOT EXISTS) : ___ms
- VERSION 2 (SELECT - EXCEPT) : ___ms
- VERSION 3 (VUE - LEFT JOIN) : ___ms

APRÈS INDEX :
- VERSION 1 (VUE - NOT EXISTS) : ___ms (GAIN : ___%)
- VERSION 2 (SELECT - EXCEPT) : ___ms (GAIN : ___%)
- VERSION 3 (VUE - LEFT JOIN) : ___ms (GAIN : ___%)

MEILLEURE VERSION : _______
JUSTIFICATION : _______
*/

