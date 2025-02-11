# Test Database - Postgres

## Introduction

## How to Build the Docker Image
```
docker build -t rdbmsdiff/test-mysql .
```

## How to Start the Docker Container
```
docker run -p 3306:3306 --env MYSQL_DB=rdbms-diff --env MYSQL_USER=test-user --env MYSQL_PASSWORD=test-pwd  rdbmsdiff/test-mysql:latest
```
