-- ============================================
-- PARTIE 3.3 : ATTRIBUTION DES PRIVILÈGES
-- ============================================

-- ============================================
-- RÔLE : ADMINISTRATEUR
-- ============================================

-- Tous les privilèges sur les tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_administrateur;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_administrateur;

-- Droit de créer des objets
GRANT USAGE, CREATE ON SCHEMA public TO role_administrateur;

-- ============================================
-- RÔLE : DATA MANAGER
-- ============================================

-- Lecture sur toutes les tables
GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_data_manager;

-- Modification spécifique
GRANT SELECT, INSERT, UPDATE ON JEUX_DONNEES TO role_data_manager;
GRANT SELECT, UPDATE ON CONTRATS TO role_data_manager;

-- Accès aux séquences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_data_manager;

-- ============================================
-- RÔLE : CHERCHEUR
-- ============================================

-- Lecture sur tables de base
GRANT SELECT ON INSTITUTIONS TO role_chercheur;
GRANT SELECT ON LABORATOIRES TO role_chercheur;
GRANT SELECT ON CHERCHEURS TO role_chercheur;
GRANT SELECT ON PROJETS TO role_chercheur;
GRANT SELECT ON PUBLICATIONS TO role_chercheur;
GRANT SELECT ON JEUX_DONNEES TO role_chercheur;
GRANT SELECT ON CONTRATS TO role_chercheur;
GRANT SELECT ON AUTEURS_PUBLICATION TO role_chercheur;
GRANT SELECT ON PARTICIPATION_PROJET TO role_chercheur;

-- Accès aux vues
GRANT SELECT ON VUE_PUBLICATIONS_PROJET TO role_chercheur;
GRANT SELECT ON VUE_PROJETS_CHERCHEURS TO role_chercheur;

-- Modification de ses propres données
GRANT INSERT, UPDATE ON PUBLICATIONS TO role_chercheur;
GRANT INSERT, UPDATE ON AUTEURS_PUBLICATION TO role_chercheur;
GRANT INSERT, UPDATE ON JEUX_DONNEES TO role_chercheur;

-- Accès aux séquences
GRANT USAGE, SELECT ON SEQUENCE publications_id_publication_seq TO role_chercheur;
GRANT USAGE, SELECT ON SEQUENCE jeux_donnees_id_dataset_seq TO role_chercheur;

-- ============================================
-- VÉRIFICATION DES PRIVILÈGES
-- ============================================
SELECT 
    grantee AS role_name,
    table_name,
    STRING_AGG(privilege_type, ', ' ORDER BY privilege_type) AS privileges
FROM information_schema.table_privileges
WHERE grantee LIKE 'role_%'
GROUP BY grantee, table_name
ORDER BY grantee, table_name;