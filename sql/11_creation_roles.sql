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
