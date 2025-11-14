"""
Génération SQL pour PUBLICATIONS (550 publications)
Adapté : titre VARCHAR(100), type_publication VARCHAR(30)
"""
from faker import Faker
import random

fake = Faker('fr_FR')

def generate_publications_sql(nb=550):
    
    types_pub = ['Article', 'Conférence', 'Ouvrage', 'Chapitre', 'Thèse']
    
    sql = "-- ============================================\n"
    sql += f"-- INSERTION DE {nb} PUBLICATIONS\n"
    sql += "-- ============================================\n\n"
    
    for i in range(nb):
        # Titre limité à 100
        titre = fake.sentence(nb_words=6).replace("'", "''")[:100]
        
        doi = f"10.{random.randint(1000,9999)}/{fake.uuid4()[:8]}"[:100]
        
        date_pub = fake.date_between(start_date='-5y', end_date='today')
        
        taille = random.randint(5, 50)
        
        lien_hal = f"https://hal.science/hal-{random.randint(1000000,9999999)}"
        
        type_pub = random.choice(types_pub)
        
        nb_citations = random.randint(0, 150)
        
        id_projet = random.randint(1, 8) if random.random() < 0.8 else 'NULL'
        
        sql += f"INSERT INTO PUBLICATIONS (titre, doi, date_publication, taille_pages, lien_hal, "
        sql += f"type_publication, nb_citations, id_projet) VALUES\n"
        sql += f"('{titre}', '{doi}', '{date_pub}', {taille}, '{lien_hal}', "
        sql += f"'{type_pub}', {nb_citations}, {id_projet});\n"
    
    sql += "\n"
    
    with open('../sql/07_insert_publications.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print(" Fichier généré : sql/07_insert_publications.sql")
    print(f" {nb} publications")

if __name__ == "__main__":
    generate_publications_sql(550)