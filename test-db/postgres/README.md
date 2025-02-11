# Test Database - Postgres

## Introduction
The Dockerfile and the SQL script present in this directory can be used to create a Docker image with Postgres database which can be used for testing purposes. The SQL script creates a representative schema with several tables, views and sequences. The tables cover various datatypes, and they are enhanced with various constraints and indexes.

## How to Build the Docker Image
```bash
docker build -t rdbmsdiff/test-postgres .
```

## How to Start the Docker Container
```bash
docker run -p 5432:5432 --env POSTGRES_DB=rdbms-diff --env POSTGRES_USER=test-user --env POSTGRES_PASSWORD=test-pwd  rdbmsdiff/test-postgres:latest
```

## Modifications of Schema
```sql
```
