#! /bin/bash

servers=`sed -n -e '/^SERVER_NAMES/p' conf.py | sed "s/^SERVER_NAMES\s//g" | tr -cs '[:alnum:]' '\n'`
for server in $servers
do
    kill -15 `ps aux | grep "[p]ython server.py $server" | grep "$USER" | awk {'print $2'} | head -n1` &> /dev/null
done
