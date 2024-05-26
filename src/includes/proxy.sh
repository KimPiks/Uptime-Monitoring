#!/bin/bash

function add_proxy () {
    PROXY_FILE=$1
    if [ -z $PROXY_FILE ]; then
        echo "Please provide a proxy file"
        exit 1
    fi

    if [ ! -f $PROXY_FILE ]; then
        echo "Proxy file not found"
        exit 1
    fi

    cat $PROXY_FILE >> $CONFIGS_DIR/proxy.list
}