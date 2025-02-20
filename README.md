# RDBMS Diff - Tools for Comparison of Relational Databases

## Introduction
RDBMS Diff is a set of tools allowing to compare two relational databases. The following comparisons are provided:
* Schema comparison.
* Record count comparison.
* Data comparison.

TODO:
- SQLAlchemy => meta-info about schema retrieved in vendor independent way
- drivers for some engines present in requirements.txt
- eventual need for customization of data validation
- source code organization (foundation aka commons + 3 other packages)
- test databases, Docker images

## Schema Comparison
The following command will display instructions about how to start schema comparison.
```
python -m rdbmsdiff.schema.main -h
```

## Record Count Comparison
The following command will display instructions about how to start comparison of record count for particular tables.
```
python -m rdbmsdiff.recordcount.main -h
```

## Data Comparison
The following command will display instructions about how to start data comparison.
```
python -m rdbmsdiff.data.main <config-file> -h
```

## Test Databases (Docker Images)
The [test-db](./test-db) directory structure contains Dockerfiles and SQL scripts that can be used to build Docker images with test databases based on various database engines. These databases can be used to test the tools comprising RDBMS Diff.
