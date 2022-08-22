#!/bin/bash

docker run -d --rm --net bank-net -p 6666:5432 --name pgsqlcontainer jullmg:postgres

docker run --rm --net bank-net -p 5001:5000 --name bankflaskapp jullmg:thebankapp



## connect to pgsql
psql -h 127.0.0.1 -p 6666 -d thebank -U banker