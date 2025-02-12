# Test Database - Postgres

## Introduction
The Dockerfile and the SQL script present in this directory can be used to create a Docker image with MySQL database which can be used for testing purposes. The SQL script creates a representative schema with several tables, views and sequences. The tables cover various datatypes, and they are enhanced with various constraints and indexes.

## How to Build the Docker Image
The following command can be used to build the Docker image.
```bash
docker build -t rdbmsdiff/test-mysql .
```

## How to Start the Docker Container
The following command can be used to start the Docker container based on the above described Docker image. This command maps the container port to the host port 3306. 
```bash
docker run -p 3306:3306 --env MYSQL_DB=rdbms-diff --env MYSQL_USER=test-user --env MYSQL_ROOT_PASSWORD=test-pwd  rdbmsdiff/test-mysql:latest
```

You can also use a different host port. The following command illustrates how to use the host port 13306.
```bash
docker run -p 13306:3306 --env MYSQL_DB=rdbms-diff --env MYSQL_USER=test-user --env MYSQL_ROOT_PASSWORD=test-pwd  rdbmsdiff/test-mysql:latest
```

## Modifications of Schema
The following commands can be used to modify the schema, for instance when you want to test the schema validation, and you would like to have some schema discrepancies.
```sql
```
