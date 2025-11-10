"""
Génération SQL pour PROJETS (8 projets)
Adapté : titre VARCHAR(100), description VARCHAR(200)
"""
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker('fr_FR')

def generate_projets_sql():
    
    projets = [
        {
            'titre': 'IA Santé Environnement',  # Court pour VARCHAR(100)
            'acronyme': 'IA-SANTE-ENV',
            'discipline': 'Informatique',
            'description': 'Algo IA pour données médicales et environnementales'[:200]
        },
        {
            'titre': 'Biodiversité Marine Méditerranée',
            'acronyme': 'BIO-MED',
            'discipline': 'Bio Marine',
            'description': 'Etude et préservation biodiversité marine en Méditerranée'[:200]
        },
        {
            'titre': 'Climat et Ecosystèmes Insulaires',
            'acronyme': 'CLIMA-CORSE',
            'discipline': 'Ecologie',
            'description': 'Impact changement climatique sur écosystèmes corses'[:200]
        },
        {
            'titre': 'Energies Renouvelables Durables',
            'acronyme': 'ENER-DURABLE',
            'discipline': 'Physique',
            'description': 'Optimisation énergies renouvelables en territoires insulaires'[:200]
        },
        {
            'titre': 'Patrimoine et Identité',
            'acronyme': 'PATRI-IDENT',
            'discipline': 'Sciences Sociales',
            'description': 'Valorisation patrimoine culturel et linguistique corse'[:200]
        },
        {
            'titre': 'Aquaculture Durable',
            'acronyme': 'AQUA-DURABLE',
            'discipline': 'Bio Marine',
            'description': 'Développement aquaculture durable en Méditerranée'[:200]
        },
        {
            'titre': 'Modélisation Systèmes Complexes',
            'acronyme': 'MATH-COMPLEX',
            'discipline': 'Maths',
            'description': 'Modèles mathématiques pour systèmes biologiques'[:200]
        },
        {
            'titre': 'Chimie Verte Ressources Naturelles',
            'acronyme': 'CHIMIE-VERTE',
            'discipline': 'Chimie',
            'description': 'Extraction et valorisation molécules naturelles corses'[:200]
        }
    ]
    
    sql = "-- ============================================\n"
    sql += "-- INSERTION DES PROJETS\n"
    sql += "-- ============================================\n\n"
    
    responsables_ids = list(range(1, 9))
    
    for i, projet in enumerate(projets):
        date_debut = fake.date_between(start_date='-3y', end_date='today')
        duree_jours = random.randint(730, 1460)
        date_fin = date_debut + timedelta(days=duree_jours)
        
        budget = random.randint(80000, 300000)
        id_labo = random.randint(1, 5)
        id_responsable = responsables_ids[i]
        statut = random.choice(['En cours', 'En cours', 'Terminé'])
        capacite = random.choice([15, 20, 25, 30])
        
        titre = projet['titre'].replace("'", "''")[:100]
        description = projet['description'].replace("'", "''")[:200]
        
        sql += f"INSERT INTO PROJETS (titre, description, discipline, budget_annuel, date_debut, date_fin, "
        sql += f"id_laboratoire_pilote, id_responsable, acronyme, statut, capacite_max_participants) VALUES\n"
        sql += f"('{titre}', '{description}', '{projet['discipline']}', {budget}, "
        sql += f"'{date_debut}', '{date_fin}', {id_labo}, {id_responsable}, "
        sql += f"'{projet['acronyme']}', '{statut}', {capacite});\n\n"
    
    with open('../sql/05_insert_projets.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print("✅ Fichier généré : sql/05_insert_projets.sql")
    print(f"✅ {len(projets)} projets")

if __name__ == "__main__":
    generate_projets_sql()