"""
Génération SQL pour LABORATOIRES (5 laboratoires)
Adapté : VARCHAR(50) pour nom, directeur_nom, email
"""

def generate_laboratoires_sql():
    
    laboratoires = [
        ('SPE Sciences Environnement', 'UMR CNRS 6134', 'Dr. A. Luciani', 'spe@univ-corse.fr', 1),
        ('LISA Identités Espaces', 'UMR CNRS 6240', 'Dr. M. Antoinetti', 'lisa@univ-corse.fr', 1),
        ('Stella Mare', 'UMR CNRS 6134', 'Dr. P. Lejeune', 'stellamare@univ-corse.fr', 1),
        ('Labo Informatique Appliquée', 'UMR CNRS 7890', 'Dr. J-F. Santucci', 'lia@univ-corse.fr', 1),
        ('Centre Recherche Bio Marine', 'UMR CNRS 8123', 'Dr. S. Mattei', 'crbm@univ-corse.fr', 1)
    ]
    
    sql = "-- ============================================\n"
    sql += "-- INSERTION DES LABORATOIRES\n"
    sql += "-- ============================================\n\n"
    
    for labo in laboratoires:
        sql += f"INSERT INTO LABORATOIRES (nom, code_umr, directeur_nom, email, id_institution) VALUES\n"
        sql += f"('{labo[0]}', '{labo[1]}', '{labo[2]}', '{labo[3]}', {labo[4]});\n\n"
    
    with open('../sql/03_insert_laboratoires.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    
    print("✅ Fichier généré : sql/03_insert_laboratoires.sql")
    print(f"✅ {len(laboratoires)} laboratoires")

if __name__ == "__main__":
    generate_laboratoires_sql()