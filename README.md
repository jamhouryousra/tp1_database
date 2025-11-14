# TP1 : Écosystème de la Recherche Universitaire

## Description
Base de données PostgreSQL pour la gestion des données de recherche.

## Structure
- `sql/` : Scripts SQL
- `python/` : Scripts Python Faker
- `docs/` : Documentation
- `tests/` : Tests

## Installation

### Créer la base
```sql
CREATE DATABASE projet_database;
```

### Créer le schéma
```bash
psql -U postgres -d projet_database -f sql/01_creation_schema.sql
```

## Auteurs
- JAMHOUR Yousra et KARKACHE El Mehdi et WAHAB Mohamed
- M1 DFS-DENG 2025-2026#