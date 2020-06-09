#!/bin/bash

if [ ! -z $ENABLE_DEBUG ] ; then
    set -x
fi

wait_for_mongodb() {
  for i in `seq 20` ; do
    nc -z "$MONGODB_HOST" "$MONGODB_PORT" > /dev/null 2>&1
    result=$?
    if [ $result -eq 0 ] ; then
      return
    fi
    sleep 1
  done
  echo "Operation timed out" >&2
  exit 1
}


ensure_resquest_ok() {
    todo="Try to insert"
    echo $todo
    mongo $QOVERY_DATABASE_MY_DDB_CONNECTION_URI $1
    if [ $? -ne 0 ] ; then
        echo "Error while trying to perform: $todo"
        exit 1
    fi
}

echo "Waiting for mongodb"
wait_for_mongodb

# Perform mongo actions
ensure_resquest_ok insert.json
ensure_resquest_ok select.json

echo "Everything work, open port 1234."
mini_http -d / -p 1234
