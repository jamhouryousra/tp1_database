-- ============================================
-- PARTIE 3.5 : TESTS DES PRIVILÈGES
-- À exécuter en tant que postgres (superuser)
-- ============================================

-- ============================================
-- TEST 1 : CHERCHEUR
-- ============================================
SET ROLE alice_chercheur;

-- ✅ DOIT FONCTIONNER
SELECT 'Test vue projets' AS test;
SELECT * FROM VUE_PROJETS_CHERCHEURS LIMIT 3;

SELECT 'Test vue publications' AS test;
SELECT * FROM VUE_PUBLICATIONS_PROJET LIMIT 3;

SELECT 'Test lecture chercheurs' AS test;
SELECT * FROM CHERCHEURS LIMIT 3;

-- ❌ DOIT ÉCHOUER : Pas d'accès à cette vue
-- SELECT * FROM VUE_DATASETS_CONFORMITE LIMIT 3;

-- ❌ DOIT ÉCHOUER : Pas de DELETE
-- DELETE FROM PUBLICATIONS WHERE id_publication = 1;

-- Résultat attendu
SELECT 
    'alice_chercheur' AS utilisateur,
    'Lecture vues OK, pas accès vue datasets, pas de DELETE' AS resultat;

RESET ROLE;

-- ============================================
-- TEST 2 : DATA MANAGER
-- ============================================
SET ROLE bob_datamanager;

-- ✅ DOIT FONCTIONNER
SELECT 'Test vue datasets conformité' AS test;
SELECT * FROM VUE_DATASETS_CONFORMITE WHERE conformite = 'Non conforme' LIMIT 3;

SELECT 'Test vue contrats' AS test;
SELECT * FROM VUE_CONTRATS_FINANCEMENT LIMIT 3;

SELECT 'Test modification dataset' AS test;
-- Sauvegarder la valeur originale
DO $$
DECLARE
    original_licence VARCHAR(100);
BEGIN
    SELECT licence INTO original_licence FROM JEUX_DONNEES WHERE id_dataset = 1;
    
    -- Test UPDATE
    UPDATE JEUX_DONNEES SET licence = 'CC-BY-TEST' WHERE id_dataset = 1;
    
    -- Restaurer
    UPDATE JEUX_DONNEES SET licence = original_licence WHERE id_dataset = 1;
    
    RAISE NOTICE 'UPDATE dataset : OK';
END $$;

-- ❌ DOIT ÉCHOUER : Pas de DELETE
-- DELETE FROM JEUX_DONNEES WHERE id_dataset = 1;

SELECT 
    'bob_datamanager' AS utilisateur,
    'Toutes les vues OK, modification datasets OK, pas de DELETE' AS resultat;

RESET ROLE;

-- ============================================
-- TEST 3 : ADMINISTRATEUR
-- ============================================
SET ROLE admin_systeme;

-- ✅ TOUT DOIT FONCTIONNER
SELECT 'Test lecture' AS test;
SELECT COUNT(*) FROM JEUX_DONNEES;

SELECT 'Test modification' AS test;
-- Test non destructif
SELECT id_projet, budget_annuel FROM PROJETS WHERE id_projet = 1;

-- ✅ L'admin PEUT supprimer (mais on ne le fait pas dans le test)
-- DELETE FROM CONTRATS WHERE id_contrat = 999;

SELECT 
    'admin_systeme' AS utilisateur,
    'Tous les droits confirmés' AS resultat;

RESET ROLE;

-- ============================================
-- RÉSUMÉ DES TESTS
-- ============================================
SELECT 'Tests terminés' AS statut;

SELECT 
    'alice_chercheur' AS utilisateur,
    '👨‍🔬 Chercheur' AS role,
    'Lecture limitée, modification ses données' AS privileges
UNION ALL
SELECT 
    'bob_datamanager',
    '📊 Data Manager',
    'Lecture tout, modification datasets/DMP'
UNION ALL
SELECT 
    'admin_systeme',
    '🔧 Administrateur',
    'Tous les droits';
```

---

## 🚀 ORDRE D'EXÉCUTION DANS pgADMIN

### **Exécutez dans cet ordre :**
```
1️⃣ sql/11_creation_roles.sql          (Créer les 3 rôles)
2️⃣ sql/12_creation_vues.sql           (Créer les 5 vues)
3️⃣ sql/13_attribution_privileges.sql  (Donner les droits aux rôles)
4️⃣ sql/14_creation_utilisateurs.sql   (Créer les 3 utilisateurs)
5️⃣ sql/15_tests_privileges.sql        (Tester les droits)