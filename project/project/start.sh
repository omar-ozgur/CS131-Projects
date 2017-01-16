#! /bin/bash

servers=`sed -n -e '/^SERVER_NAMES/p' conf.py | sed "s/^SERVER_NAMES//g" | tr -cs '[:alnum:]' '\n'`
for server in $servers
do
    python server.py $server & &> /dev/null
done
