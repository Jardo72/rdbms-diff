# Test Database - Postgres

## Introduction
The Dockerfile and the SQL script present in this directory can be used to create a Docker image with Postgres database which can be used for testing purposes. The SQL script creates a representative schema with several tables, views and sequences. The tables cover various datatypes, and they are enhanced with various constraints and indexes.

## How to Build the Docker Image
The following command can be used to build the Docker image.
```bash
docker build -t rdbmsdiff/test-postgres .
```

## How to Start the Docker Container
The following command can be used to start the Docker container based on the above described Docker image. This command maps the container port to the host port 5432. 
```bash
docker run -p 5432:5432 --env POSTGRES_DB=rdbms-diff --env POSTGRES_USER=test-user --env POSTGRES_PASSWORD=test-pwd  rdbmsdiff/test-postgres:latest
```

You can also use a different host port. The following command illustrates how to use the host port 15432.
```bash
docker run -p 15432:5432 --env POSTGRES_DB=rdbms-diff --env POSTGRES_USER=test-user --env POSTGRES_PASSWORD=test-pwd  rdbmsdiff/test-postgres:latest
```


## Modifications of Schema
The following commands can be used to modify the schema, for instance when you want to test the schema validation, and you would like to have some schema discrepancies.
```sql
ALTER TABLE t_means_of_transport ADD COLUMN description VARCHAR(100);

ALTER TABLE t_stations ADD COLUMN description VARCHAR(100);

ALTER TABLE t_lines ADD COLUMN night_line BOOLEAN NOT NULL DEFAULT false;
```
