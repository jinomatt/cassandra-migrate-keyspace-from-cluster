#!/bin/bash

tar_file=$1
bkp_name="bkp-$$"
localhostt=$(cat /etc/hosts |grep cassandra |awk '{print $1}')
if [ -z "${tar_file}" ]; then
        echo "Usage import.sh [tar file]"
            exit 1
    fi

    keyspace=$(basename "${tar_file}" ".tar.gz")

    mkdir -p "${bkp_name}"

    tar -xvzf "${tar_file}" -C "${bkp_name}"

    echo "Drop keyspace ${keyspace}"
    cqlsh --request-timeout="60" -u cassandra -p cassandra -e "drop keyspace \"${keyspace}\";"

    echo "Create empty keyspace: ${keyspace}"
    cat "${bkp_name}/${keyspace}.sql" | cqlsh -u cassandra -p cassandra

    for dir in "${bkp_name}/${keyspace}/"*; do
        ccdir=$(realpath ${dir})
            sstableloader -d "${localhostt}"  "${ccdir}" -u cassandra -pw cassandra
        done

