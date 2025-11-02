## Database scripts — 0x01

This folder contains SQL queries and Data Definition Language (DDL) statements used to create the database entities for the Airbnb clone project. The scripts define tables, constraints, relationships, and indexes required for local development and testing.

### Files

- `schema.sql` — primary SQL script that creates the database schema (tables, keys, constraints, and indexes).

### Purpose

These scripts provide a repeatable way to provision the PostgreSQL schema used by the Airbnb clone. Use them to create a fresh database for development, testing, or to inspect the schema design.

### Quick usage

1. Ensure PostgreSQL is installed and `psql` is available on your PATH.
2. Create a database (example uses `airbnb_clone`):

```powershell
psql -U postgres -c "CREATE DATABASE airbnb_clone;"
```

3. Run the schema script against the database:

```powershell
psql -U postgres -d airbnb_clone -f schema.sql
```

Adjust the `-U` user, database name, and file path as needed for your environment.

### Assumptions & notes

- Scripts are written for PostgreSQL. Some SQL might require minor edits for other engines.
- The executing user must have privileges to create objects in the target database.
- Running the script on an existing database may fail if objects already exist; consider dropping or using a clean database when testing.
- See the repository `normalization.md` for the schema's normalization rationale and `ERD/requirements.md` for entity relationship details.

### Contact

If you have questions about the schema or need changes, open an issue or contact the repository owner.

