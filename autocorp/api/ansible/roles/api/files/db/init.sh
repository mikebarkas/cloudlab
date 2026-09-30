#!/bin/bash
set -e

AUTO_DATABASE="auto_db"
AUTO_TABLE="autos"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE DATABASE "$AUTO_DATABASE";
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$AUTO_DATABASE" <<-EOSQL
  CREATE TABLE IF NOT EXISTS "$AUTO_TABLE" (
    id serial PRIMARY KEY,
    year integer NOT NULL,
    make varchar(100) NOT NULL,
    model varchar(255) NOT NULL,
    color varchar(100),
    price money NOT NULL,
    mileage integer
  );
EOSQL
