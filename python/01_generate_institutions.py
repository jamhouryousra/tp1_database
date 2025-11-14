"""
Génération SQL pour INSTITUTIONS (5 institutions)
Adapté aux contraintes : VARCHAR(50) pour nom et adresse
"""
from faker import Faker

fake = Faker('fr_FR')

def generate_institutions_sql():
    
    institutions = [
        ('Université de Corse', 'Université', '7 Avenue Jean Nicoli', 'Corte', 'contact@univ-corse.fr'),
        ('CNRS', 'Organisme de recherche', '3 rue Michel-Ange', 'Paris', 'contact@cnrs.fr'),
        ('INSERM', 'Organisme de recherche', '101 rue de Tolbiac', 'Paris', 'contact@inserm.fr'),
        ('TechCorp Solutions', 'Partenaire privé', '15 Boulevard Tech', 'Lyon', 'research@techcorp.com'),
        ('Innovation Labs SA', 'Partenaire privé', '8 Rue Innovation', 'Marseille', 'contact@innovlabs.fr')
    ]
    
    sql = "-- ============================================\n"
    sql += "-- INSERTION DES INSTITUTIONS\n"
    sql += "-- ============================================\n\n"
    
    for inst in institutions:
        sql += f"INSERT INTO INSTITUTIONS (nom, type_inst, adresse, ville, email_contact) VALUES\n"
        sql += f"('{inst[0]}', '{inst[1]}', '{inst[2]}', '{inst[3]}', '{inst[4]}');\n\n"
    
    with open('../sql/02_insert_institutions.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print(" Fichier généré : sql/02_insert_institutions.sql")
    print(f" {len(institutions)} institutions")

if __name__ == "__main__":
    generate_institutions_sql()