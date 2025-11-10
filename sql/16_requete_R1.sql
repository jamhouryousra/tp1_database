-- ============================================
-- REQUÊTE R1 : Datasets par Projet et Année
-- ============================================
-- VERSION AVEC VUE + VERSION SANS VUE
-- Tests 
-- ============================================

-- ============================================
-- VERSION 1 : AVEC VUE
-- ============================================

CREATE OR REPLACE VIEW R1_VERSION1 AS
SELECT P.acronyme AS projet,EXTRACT(YEAR FROM JD.date_depot) AS annee,
    COUNT(JD.id_dataset) AS nb_datasets_deposes,
    ROUND(AVG(JD.date_depot - JD.date_creation), 2) AS delai_moyen_jours
FROM JEUX_DONNEES JD
JOIN CONTRATS C ON JD.id_contrat = C.id_contrat
JOIN PROJETS P ON C.id_projet = P.id_projet
WHERE 
    JD.date_depot IS NOT NULL
    AND P.id_projet IN (
        SELECT PP.id_projet
        FROM PARTICIPATION_PROJET PP
        JOIN PROJETS P2 ON PP.id_projet = P2.id_projet
        WHERE P2.date_debut >= '2018-01-01'
        GROUP BY PP.id_projet
        HAVING COUNT(DISTINCT PP.id_chercheur) > 5
    )
GROUP BY P.id_projet, P.acronyme, EXTRACT(YEAR FROM JD.date_depot)
ORDER BY projet, annee;

-- Test VERSION 1 AVEC VUE
SELECT '========== VERSION 1 : AVEC VUE (Sous-requête IN) ==========' AS titre;
EXPLAIN ANALYZE
SELECT * FROM R1_VERSION1;

-- ============================================
-- VERSION 2 : SANS VUE (SELECT direct)
-- ============================================

SELECT '========== VERSION 2 : SANS VUE (JOIN + HAVING) ==========' AS titre;

EXPLAIN ANALYZE
select   pr.acronyme,EXTRACT(YEAR FROM jd.date_depot) AS annee,
count(jd.id_dataset) as nbre_total_jeux_donnees,
ROUND(AVG(JD.date_depot - JD.date_creation), 2)
from jeux_donnees jd 
join contrats cr on jd.id_contrat=cr.id_contrat
join projets pr on cr.id_projet=pr.id_projet
join participation_projet part_pr on pr.id_projet=part_pr.id_projet
where pr.date_debut>='2018-01-01' and jd.date_depot is not null
group by pr.id_projet,EXTRACT(YEAR FROM jd.date_depot),pr.acronyme
having count(distinct part_pr.id_chercheur)>5
ORDER BY pr.acronyme, annee;

-- ============================================
-- VERSION 3 : AVEC VUE 
-- ============================================
CREATE OR REPLACE VIEW R1_VERSION1_INDEXED AS
SELECT P.acronyme AS projet, EXTRACT(YEAR FROM JD.date_depot) AS annee,
    COUNT(JD.id_dataset) AS nb_datasets_deposes,
    ROUND(AVG(JD.date_depot - JD.date_creation), 2) AS delai_moyen_jours
FROM JEUX_DONNEES JD
JOIN CONTRATS C ON JD.id_contrat = C.id_contrat
JOIN PROJETS P ON C.id_projet = P.id_projet
JOIN PARTICIPATION_PROJET PP ON P.id_projet = PP.id_projet
WHERE JD.date_depot IS NOT NULL AND P.date_debut >= '2018-01-01'
GROUP BY P.id_projet, P.acronyme, EXTRACT(YEAR FROM JD.date_depot)
HAVING COUNT(DISTINCT PP.id_chercheur) > 5
ORDER BY projet, annee;

-- Test VERSION 3 AVEC VUE
EXPLAIN ANALYZE SELECT * FROM R1_VERSION1_INDEXED;

-- ============================================
-- CRÉATION DES INDEX
-- ============================================

CREATE INDEX IF NOT EXISTS idx_projets_date_debut ON PROJETS(date_debut);
CREATE INDEX IF NOT EXISTS idx_jeux_donnees_dates ON JEUX_DONNEES(date_creation, date_depot);
CREATE INDEX IF NOT EXISTS idx_jeux_donnees_date_depot ON JEUX_DONNEES(date_depot) WHERE date_depot IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_contrats_id_projet ON CONTRATS(id_projet);
CREATE INDEX IF NOT EXISTS idx_jeux_donnees_id_contrat ON JEUX_DONNEES(id_contrat);
CREATE INDEX IF NOT EXISTS idx_participation_id_projet ON PARTICIPATION_PROJET(id_projet);


-- ============================================
-- RE-TESTS APRÈS INDEX
-- ============================================

SELECT '========== APRÈS INDEX : VERSION 1 (VUE) ==========' AS titre;
EXPLAIN ANALYZE SELECT * FROM R1_VERSION1;

SELECT '========== APRÈS INDEX : VERSION 2 (SELECT) ==========' AS titre;
EXPLAIN ANALYZE
select   pr.acronyme,EXTRACT(YEAR FROM jd.date_depot) AS annee,
count(jd.id_dataset) as nbre_total_jeux_donnees,
ROUND(AVG(JD.date_depot - JD.date_creation), 2)
from jeux_donnees jd 
join contrats cr on jd.id_contrat=cr.id_contrat
join projets pr on cr.id_projet=pr.id_projet
join participation_projet part_pr on pr.id_projet=part_pr.id_projet
where pr.date_debut>='2018-01-01' and jd.date_depot is not null
group by pr.id_projet,EXTRACT(YEAR FROM jd.date_depot),pr.acronyme
having count(distinct part_pr.id_chercheur)>5
ORDER BY pr.acronyme, annee;

SELECT '========== APRÈS INDEX : VERSION 3 (SELECT ET VIEW) ==========' AS titre;
EXPLAIN ANALYZE SELECT * FROM R1_VERSION1_INDEXED;
-- ============================================
-- RÉSULTATS À NOTER
-- ============================================
/*
AVANT INDEX :
- VERSION 1 (VUE) : ___ms
- VERSION 2 (SELECT) : ___ms

APRÈS INDEX :
- VERSION 1 (VUE) : ___ms
- VERSION 2 (SELECT) : ___ms

MEILLEURE VERSION : _______
JUSTIFICATION : _______
*/






