# Test Database - MariaDB

## Introduction
The Dockerfile and the SQL script present in this directory can be used to create a Docker image with MariaDB database which can be used for testing purposes. The SQL script creates a representative schema with several tables, views and sequences. The tables cover various datatypes, and they are enhanced with various constraints and indexes. Besides creating the schema, the script also inserts records into the database tables. In other words, the test database can be used to test schema validation as well as data validation.

## How to Build the Docker Image
The following command can be used to build the Docker image.
```bash
docker build -t rdbmsdiff/test-mariadb .
```

## How to Start the Docker Container
The following command can be used to start the Docker container based on the above described Docker image. This command maps the container port to the host port 3306. 
```bash
docker run -p 3306:3306 --env MARIADB_DB=rdbms_diff --env MARIADB_ROOT_PASSWORD=test-pwd  rdbmsdiff/test-mariadb:latest
```

You can also use a different host port. The following command illustrates how to use the host port 13306.
```bash
docker run -p 13306:3306 --env MARIADB_DB=rdbms_diff --env MARIADB_ROOT_PASSWORD=test-pwd  rdbmsdiff/test-mariadb:latest
```

The [config.ini](./config.ini) file is a configuration that can be used for testing purposes. It uses the two databases started by the two `docker run` commands above. The source database uses the host port 3306, the target database uses the host port 13306.


## Modifications of Schema
The following SQL commands can be used to modify the schema, for instance when you want to test the schema comparison, and you would like to have some schema discrepancies.
```sql
CREATE TABLE t_persons (
    id bigint NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    CONSTRAINT t_persons_pk PRIMARY KEY(id)
);


ALTER TABLE t_means_of_transport ADD COLUMN description VARCHAR(100);

ALTER TABLE t_stations ADD COLUMN description VARCHAR(100);

ALTER TABLE t_lines ADD COLUMN night_line BOOLEAN NOT NULL DEFAULT false;

DROP SEQUENCE s_dummy_5;

CREATE SEQUENCE s_extra_sequence INCREMENT BY 1 NO MAXVALUE START WITH 1 NO CYCLE;

DROP VIEW v_lines;

DROP INDEX i_log_entry_timestamp;
```

## Modifications of Data
The following SQL commands can be used to modify the data, for instance when you want to test data comparison, and you would like to have some data discrepancies.
```sql
INSERT INTO t_means_of_transport (uuid, identifier) VALUES ('9a7b5c46-d42e-4441-8950-bf24f846ef17', 'Trolleybus');

UPDATE t_means_of_transport SET identifier = 'Strassenbahn' where identifier = 'Tram';

INSERT INTO t_stations (uuid, "name") VALUES ('31019303-f882-4e27-97c1-efcab885cb29', 'Dummy');
```
