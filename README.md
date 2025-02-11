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
The following command will display instructions about how to start schema validation.
```
python -m rdbmsdiff.schema.main -h
```

## Record Count Comparison
The following command will display instructions about how to start comparison of record count for particular tables.
```
python -m rdbmsdiff.recordcount.main -h
```

## Data Comparison
The following command will display instructions about how to start data validation.
```
python -m rdbmsdiff.data.main <config-file> -h
```

## Test Databases (Docker Images)