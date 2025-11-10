"""
Génération SQL pour JEUX_DONNEES (1100 datasets)
Adapté : titre VARCHAR(100), version_jd VARCHAR(20)
"""
from faker import Faker
import random
from datetime import timedelta

fake = Faker('fr_FR')

def generate_datasets_sql(nb=1100):
    
    conditions = ['Public', 'Restreint', 'Privé', 'Embargo']
    licences = ['CC-BY', 'CC0', 'CC-BY-SA', 'ODbL', None]
    statuts = ['En préparation', 'Déposé', 'Archivé']
    
    sql = "-- ============================================\n"
    sql += f"-- INSERTION DE {nb} JEUX DE DONNÉES\n"
    sql += "-- ============================================\n\n"
    
    for i in range(nb):
        # Titre limité à 100
        titre = f"Dataset {fake.word()}"[:100].replace("'", "''")
        
        description = fake.text(max_nb_chars=150).replace("'", "''")
        
        id_contrat = random.randint(1, 120)
        id_auteur = random.randint(1, 220)
        
        condition = random.choice(conditions)
        
        licence = random.choice(licences)
        licence_sql = f"'{licence}'" if licence else 'NULL'
        
        date_creation = fake.date_between(start_date='-3y', end_date='today')
        
        if random.random() < 0.7:
            statut = 'Déposé'
            date_depot = date_creation + timedelta(days=random.randint(10, 200))
            date_depot_sql = f"'{date_depot}'"
        else:
            statut = random.choice(['En préparation', 'Archivé'])
            date_depot_sql = 'NULL'
        
        # version_jd limité à 20
        version = f"v{random.randint(1,3)}.{random.randint(0,9)}"
        
        sql += f"INSERT INTO JEUX_DONNEES (titre, description, id_contrat, id_auteur, "
        sql += f"conditions_acces, licence, date_creation, date_depot, statut, version_jd) VALUES\n"
        sql += f"('{titre}', '{description}', {id_contrat}, {id_auteur}, '{condition}', "
        sql += f"{licence_sql}, '{date_creation}', {date_depot_sql}, '{statut}', '{version}');\n"
    
    sql += "\n"
    
    with open('../sql/08_insert_datasets.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print("✅ Fichier généré : sql/08_insert_datasets.sql")
    print(f"✅ {nb} datasets")

if __name__ == "__main__":
    generate_datasets_sql(1100)