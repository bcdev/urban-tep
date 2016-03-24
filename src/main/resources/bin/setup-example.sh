#!/bin/bash

rootdir=$(dirname $(dirname $0))

if [ -e ./example ] ; then 
    echo "./example exists. Copy aborted."
    exit 1
fi

cp -r $rootdir/example .

