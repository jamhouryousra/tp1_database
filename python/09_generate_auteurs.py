"""
Génération SQL pour AUTEURS_PUBLICATION
"""
import random

def generate_auteurs_sql():
    
    sql = "-- ============================================\n"
    sql += "-- INSERTION DES AUTEURS DE PUBLICATIONS\n"
    sql += "-- ============================================\n\n"
    
    nb_publications = 550
    
    for pub_id in range(1, nb_publications + 1):
        nb_auteurs = random.randint(1, 5)
        auteurs = random.sample(range(1, 221), nb_auteurs)
        
        for ordre, chercheur_id in enumerate(auteurs, 1):
            sql += f"INSERT INTO AUTEURS_PUBLICATION (id_publication, id_chercheur, ordre_auteur) VALUES\n"
            sql += f"({pub_id}, {chercheur_id}, {ordre});\n"
    
    sql += "\n"
    
    with open('../sql/10_insert_auteurs.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print("✅ Fichier généré : sql/10_insert_auteurs.sql")

if __name__ == "__main__":
    generate_auteurs_sql()