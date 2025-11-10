-- ============================================
-- PARTIE 3.4 : CRÉATION DES UTILISATEURS
-- ============================================

-- ============================================
-- UTILISATEUR 1 : CHERCHEUR
-- ============================================
CREATE USER alice_chercheur WITH 
    LOGIN 
    PASSWORD 'chercheur123'
    IN ROLE role_chercheur;

GRANT CONNECT ON DATABASE projet_database TO alice_chercheur;

COMMENT ON ROLE alice_chercheur IS 
'Alice Dupont - Chercheuse en biologie marine';

-- ============================================
-- UTILISATEUR 2 : DATA MANAGER
-- ============================================
CREATE USER bob_datamanager WITH 
    LOGIN 
    PASSWORD 'datamanager123'
    IN ROLE role_data_manager;

GRANT CONNECT ON DATABASE projet_database TO bob_datamanager;

COMMENT ON ROLE bob_datamanager IS 
'Bob Martin - Gestionnaire de données';

-- ============================================
-- UTILISATEUR 3 : ADMINISTRATEUR
-- ============================================
CREATE USER admin_systeme WITH 
    LOGIN 
    PASSWORD 'admin123'
    IN ROLE role_administrateur;

GRANT CONNECT ON DATABASE projet_database TO admin_systeme;

COMMENT ON ROLE admin_systeme IS 
'Administrateur système de la base de données';

-- ============================================
-- VÉRIFICATION
-- ============================================
SELECT 
    u.usename AS username,
    u.usesuper AS is_superuser,
    STRING_AGG(r.rolname, ', ' ORDER BY r.rolname) AS member_of_roles
FROM pg_user u
LEFT JOIN pg_auth_members m ON u.usesysid = m.member
LEFT JOIN pg_roles r ON m.roleid = r.oid
WHERE u.usename IN ('alice_chercheur', 'bob_datamanager', 'admin_systeme')
GROUP BY u.usename, u.usesuper
ORDER BY u.usename;