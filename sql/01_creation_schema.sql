-- ============================================
-- SCRIPT 
-- Écosystème de la Recherche Universitaire
-- ============================================


-- TABLE 1 : INSTITUTIONS
-- ============================================
CREATE TABLE INSTITUTIONS (
    id_institution SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    type_inst VARCHAR(30) NOT NULL CHECK (type_inst IN ('Université', 'Organisme de recherche', 'Partenaire privé')),
    adresse VARCHAR(50) NOT NULL,
    -- AJOUTS STRATÉGIQUES
    ville VARCHAR(20),
    email_contact VARCHAR(50)
);

-- ============================================
-- TABLE 2 : LABORATOIRES
-- ============================================
CREATE TABLE LABORATOIRES (
    id_laboratoire SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    id_institution INTEGER NOT NULL REFERENCES INSTITUTIONS(id_institution) ON DELETE CASCADE,
    -- AJOUTS STRATÉGIQUES
    code_umr VARCHAR(50) UNIQUE,
    directeur_nom VARCHAR(50),
    email VARCHAR(50)
);

-- ============================================
-- TABLE 3 : CHERCHEURS
-- ============================================
CREATE TABLE CHERCHEURS (
    id_chercheur SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    discipline VARCHAR(50) NOT NULL,
    id_laboratoire INTEGER NOT NULL REFERENCES LABORATOIRES(id_laboratoire) ON DELETE CASCADE,
    -- AJOUTS STRATÉGIQUES
    email VARCHAR(50) UNIQUE,
    statut VARCHAR(20) CHECK (statut IN ('Doctorant', 'Post-doc', 'MCF', 'PR', 'DR', 'CR', 'Ingénieur')),
    orcid VARCHAR(50) UNIQUE
);

-- ============================================
-- TABLE 4 : PROJETS
-- ============================================
CREATE TABLE PROJETS (
    id_projet SERIAL PRIMARY KEY,
    titre VARCHAR(100) NOT NULL,
    description VARCHAR(200),
    discipline VARCHAR(100),
    budget_annuel DECIMAL(12,2),
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    id_laboratoire_pilote INTEGER NOT NULL REFERENCES LABORATOIRES(id_laboratoire) ON DELETE CASCADE,
    id_responsable INTEGER NOT NULL REFERENCES CHERCHEURS(id_chercheur) ON DELETE RESTRICT,
    -- AJOUTS STRATÉGIQUES
    acronyme VARCHAR(50),
    statut VARCHAR(50) DEFAULT 'En cours' CHECK (statut IN ('En préparation', 'En cours', 'Terminé', 'Suspendu')),
    capacite_max_participants INTEGER DEFAULT 20,
    CHECK (date_fin > date_debut)
);

-- ============================================
-- TABLE 5 : CONTRATS
-- ============================================
CREATE TABLE CONTRATS (
    id_contrat SERIAL PRIMARY KEY,
    type_financement VARCHAR(50) NOT NULL CHECK (type_financement IN ('ANR', 'H2020', 'Horizon Europe', 'Région', 'Europe', 'Privé', 'CIFRE')),
    financeur VARCHAR(50) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    montant DECIMAL(12,2) NOT NULL CHECK (montant > 0),
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    id_projet INTEGER NOT NULL REFERENCES PROJETS(id_projet) ON DELETE CASCADE,
    statut_dmp VARCHAR(20) DEFAULT 'brouillon' CHECK (statut_dmp IN ('brouillon', 'soumis', 'validé')),
    date_validation_dmp DATE,
    lien_document_dmp VARCHAR(255),
    -- AJOUTS STRATÉGIQUES
    reference_contrat VARCHAR(100) UNIQUE,
    montant_consomme DECIMAL(12,2) DEFAULT 0 CHECK (montant_consomme >= 0 AND montant_consomme <= montant),
    CHECK (date_fin > date_debut)
);

-- ============================================
-- TABLE 6 : PUBLICATIONS
-- ============================================
CREATE TABLE PUBLICATIONS (
    id_publication SERIAL PRIMARY KEY,
    titre VARCHAR(100) NOT NULL,
    doi VARCHAR(100) UNIQUE,
    date_publication DATE NOT NULL,
    taille_pages INTEGER,
    lien_hal VARCHAR(255),
    -- AJOUTS STRATÉGIQUES
    type_publication VARCHAR(30) CHECK (type_publication IN ('Article', 'Conférence', 'Ouvrage', 'Chapitre', 'Thèse')),
    nb_citations INTEGER DEFAULT 0,
    id_projet INTEGER REFERENCES PROJETS(id_projet) ON DELETE SET NULL
);

-- ============================================
-- TABLE 7 : JEUX_DONNEES
-- ============================================
CREATE TABLE JEUX_DONNEES (
    id_dataset SERIAL PRIMARY KEY,
    titre VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    id_contrat INTEGER NOT NULL REFERENCES CONTRATS(id_contrat) ON DELETE CASCADE,
    id_auteur INTEGER NOT NULL REFERENCES CHERCHEURS(id_chercheur) ON DELETE RESTRICT,
    conditions_acces VARCHAR(50) CHECK (conditions_acces IN ('Public', 'Restreint', 'Privé', 'Embargo')),
    licence VARCHAR(100),
    date_depot DATE,
    -- AJOUTS STRATÉGIQUES
    date_creation DATE NOT NULL DEFAULT CURRENT_DATE,
    statut VARCHAR(50) DEFAULT 'En préparation' CHECK (statut IN ('En préparation', 'Déposé', 'Archivé')),
    version_jd VARCHAR(20) DEFAULT 'v1.0'
);

-- ============================================
-- TABLE 8 : PARTICIPATION_PROJET (1-N) on a cree la liaison parce que nous avons le role ce qui va
--perturber les tables donc on a fait une table de liaison sinon on ajoute juste la cle primaire du chercheur
--a la table du projet
-- ============================================
CREATE TABLE PARTICIPATION_PROJET (
    id_chercheur INTEGER REFERENCES CHERCHEURS(id_chercheur) ON DELETE CASCADE,
    id_projet INTEGER REFERENCES PROJETS(id_projet) ON DELETE CASCADE,
    -- AJOUT STRATÉGIQUE
    role_participant VARCHAR(50) DEFAULT 'Participant' CHECK (role_participant IN ('Responsable', 'Co-responsable', 'Participant', 'Collaborateur')),
    PRIMARY KEY (id_chercheur, id_projet)
);

-- ============================================
-- TABLE 9 : AUTEURS_PUBLICATION (N-N)
-- ============================================
CREATE TABLE AUTEURS_PUBLICATION (
    id_publication INTEGER REFERENCES PUBLICATIONS(id_publication) ON DELETE CASCADE,
    id_chercheur INTEGER REFERENCES CHERCHEURS(id_chercheur) ON DELETE CASCADE,
    -- AJOUT STRATÉGIQUE
    ordre_auteur INTEGER NOT NULL CHECK (ordre_auteur > 0),
    PRIMARY KEY (id_publication, id_chercheur),
    UNIQUE (id_publication, ordre_auteur)
);


-- ============================================
-- FIN DU SCRIPT
-- ============================================

