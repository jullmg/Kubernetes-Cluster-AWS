#!/bin/bash

docker run --rm --net bank-net -p 6666:5432 --name pgsqlcontainer jullmg:postgres

docker run --rm --net bank-net --name bankflaskapp jullmg:thebankapp
