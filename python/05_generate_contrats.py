"""
Génération SQL pour CONTRATS (120 contrats)
Adapté : financeur VARCHAR(50), intitule VARCHAR(100)
"""
from faker import Faker
import random
from datetime import timedelta

fake = Faker('fr_FR')

def generate_contrats_sql(nb=120):
    
    types_financement = ['ANR', 'H2020', 'Horizon Europe', 'Région', 'Europe', 'Privé', 'CIFRE']
    financeurs = {
        'ANR': 'ANR France',
        'H2020': 'Commission EU H2020',
        'Horizon Europe': 'Commission EU Horizon',
        'Région': 'Collectivité Corse',
        'Europe': 'Fonds EU',
        'Privé': ['TechCorp', 'InnovLabs', 'BioTech', 'GreenEnergy'],
        'CIFRE': 'ANRT CIFRE'
    }
    
    statuts_dmp = ['brouillon', 'soumis', 'validé']
    
    sql = "-- ============================================\n"
    sql += f"-- INSERTION DE {nb} CONTRATS\n"
    sql += "-- ============================================\n\n"
    
    for i in range(nb):
        type_fin = random.choice(types_financement)
        
        if type_fin == 'Privé':
            financeur = random.choice(financeurs['Privé'])
        else:
            financeur = financeurs[type_fin]
        
        # Intitulé limité à 100
        intitule = f"Contrat {type_fin} {fake.word()}"[:100].replace("'", "''")
        
        montant = random.randint(20000, 500000)
        montant_consomme = random.randint(0, int(montant * 0.8))
        
        date_debut = fake.date_between(start_date='-3y', end_date='today')
        duree_jours = random.randint(365, 1095)
        date_fin = date_debut + timedelta(days=duree_jours)
        
        id_projet = random.randint(1, 8)
        
        statut_dmp = random.choice(statuts_dmp)
        date_validation = ''
        if statut_dmp == 'validé':
            date_validation = f", '{fake.date_between(start_date=date_debut, end_date='today')}'"
        else:
            date_validation = ', NULL'
        
        reference = f"REF-{type_fin}-{random.randint(1000,9999)}"[:100]
        
        sql += f"INSERT INTO CONTRATS (type_financement, financeur, intitule, montant, date_debut, date_fin, "
        sql += f"id_projet, statut_dmp, date_validation_dmp, reference_contrat, montant_consomme) VALUES\n"
        sql += f"('{type_fin}', '{financeur}', '{intitule}', {montant}, '{date_debut}', '{date_fin}', "
        sql += f"{id_projet}, '{statut_dmp}'{date_validation}, '{reference}', {montant_consomme});\n"
    
    sql += "\n"
    
    with open('../sql/06_insert_contrats.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print("Fichier généré : sql/06_insert_contrats.sql")
    print(f" {nb} contrats")

if __name__ == "__main__":
    generate_contrats_sql(120)