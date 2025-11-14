import random

def generate_participations_sql():
    roles = ['Responsable', 'Co-responsable', 'Participant', 'Collaborateur']
    nb_projets = 8
    capacite_max = 30
    total_chercheurs = 220

    sql = "-- ============================================\n"
    sql += "-- INSERTION DES PARTICIPATIONS PROJET\n"
    sql += "-- ============================================\n\n"

    # Étape 1 : Responsables — 1 par projet
    for i in range(1, nb_projets + 1):
        sql += f"INSERT INTO PARTICIPATION_PROJET (id_chercheur, id_projet, role_participant) VALUES\n"
        sql += f"({i}, {i}, 'Responsable');\n"

    sql += "\n"

    # Étape 2 : Répartition contrôlée des autres chercheurs
    chercheur_id = nb_projets + 1
    participations = {i: 1 for i in range(1, nb_projets + 1)}  # 1 responsable déjà présent

    while chercheur_id <= total_chercheurs:
        # Sélectionne un projet qui n’a pas atteint sa capacité
        projets_disponibles = [p for p, count in participations.items() if count < capacite_max]
        if not projets_disponibles:
            break  # tous les projets sont pleins

        projet_id = random.choice(projets_disponibles)
        role = random.choice(['Participant', 'Collaborateur', 'Participant', 'Participant'])

        sql += f"INSERT INTO PARTICIPATION_PROJET (id_chercheur, id_projet, role_participant) VALUES\n"
        sql += f"({chercheur_id}, {projet_id}, '{role}');\n"

        participations[projet_id] += 1
        chercheur_id += 1

    sql += "\n"

    with open('../sql/09_insert_participations.sql', 'w', encoding='utf-8') as f:
        f.write(sql)

    total_inserted = sum(participations.values())
    print(f"Fichier généré : sql/09_insert_participations.sql")
    print(f"{total_inserted} participations générées (max {capacite_max} par projet)")
    for pid, count in participations.items():
        print(f"   → Projet {pid}: {count} participants")

if __name__ == "__main__":
    generate_participations_sql()
