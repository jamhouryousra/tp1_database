-- ============================================
-- PARTIE 3.1 : CRÉATION DES RÔLES
-- ============================================

-- ============================================
-- CRÉATION DES RÔLES (sans LOGIN)
-- ============================================

-- RÔLE 1 : CHERCHEUR
CREATE ROLE role_chercheur NOLOGIN;

COMMENT ON ROLE role_chercheur IS 
'Chercheur : Accès en lecture à ses propres projets, publications et datasets.';

-- RÔLE 2 : DATA MANAGER
CREATE ROLE role_data_manager NOLOGIN;

COMMENT ON ROLE role_data_manager IS 
'Data Manager : Accès en lecture à toutes les métadonnées, modification datasets et DMP.';

-- RÔLE 3 : ADMINISTRATEUR
CREATE ROLE role_administrateur NOLOGIN;

COMMENT ON ROLE role_administrateur IS 
'Administrateur : Accès complet sur toutes les tables.';

-- ============================================
-- VÉRIFICATION
-- ============================================
SELECT 
    rolname AS role_name, 
    rolcanlogin AS can_login,
    CASE 
        WHEN rolname = 'role_administrateur' THEN 'Administrateur'
        WHEN rolname = 'role_data_manager' THEN 'Data Manager'
        WHEN rolname = 'role_chercheur' THEN 'Chercheur'
    END AS description
FROM pg_roles 
WHERE rolname LIKE 'role_%'
ORDER BY rolname;