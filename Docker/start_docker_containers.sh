#!/bin/bash

docker run -d --rm --net bank-net -p 6666:5432 --name pgsqlcontainer jullmg:postgres

docker run -d --rm --net bank-net -p 5001:5000 --name bankflaskapp jullmg:thebankapp



## connect to pgsql running on docker
psql -h 127.0.0.1 -p 6666 -d thebank -U banker

## connect to pgsql running on Pod (from inside pod)
psql -d thebank -U banker -W