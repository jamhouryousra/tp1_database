"""
Génération SQL pour CHERCHEURS (220 chercheurs)
Adapté : VARCHAR(50) pour nom, prenom, discipline, email, orcid
         VARCHAR(20) pour statut
"""
from faker import Faker
import random

fake = Faker('fr_FR')

def generate_chercheurs_sql(nb=220):
    
    disciplines = ['Informatique', 'Bio Marine', 'Chimie', 'Ecologie', 
                   'Geologie', 'Physique', 'Maths', 'Sciences Sociales']
    
    statuts = ['Doctorant', 'Post-doc', 'MCF', 'PR', 'DR', 'CR', 'Ingénieur']
    statut_weights = [30, 15, 25, 15, 10, 3, 2]
    
    sql = "-- ============================================\n"
    sql += f"-- INSERTION DE {nb} CHERCHEURS\n"
    sql += "-- ============================================\n\n"
    
    for i in range(nb):
        nom = fake.last_name().replace("'", "''")[:50]
        prenom = fake.first_name().replace("'", "''")[:50]
        discipline = random.choice(disciplines)
        id_labo = random.randint(1, 5)
        
        # Email limité à 50 caractères
        email_base = f"{prenom[:10].lower()}.{nom[:10].lower()}@univ.fr"
        email = email_base[:50]
        
        statut = random.choices(statuts, weights=statut_weights)[0]
        
        # ORCID limité à 50 caractères
        orcid = f"0000-{random.randint(1000,9999)}-{random.randint(1000,9999)}-{random.randint(1000,9999)}"
        
        sql += f"INSERT INTO CHERCHEURS (nom, prenom, discipline, id_laboratoire, email, statut, orcid) VALUES\n"
        sql += f"('{nom}', '{prenom}', '{discipline}', {id_labo}, '{email}', '{statut}', '{orcid}');\n"
    
    sql += "\n"
    
    with open('../sql/04_insert_chercheurs.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print("✅ Fichier généré : sql/04_insert_chercheurs.sql")
    print(f"✅ {nb} chercheurs")

if __name__ == "__main__":
    generate_chercheurs_sql(220)