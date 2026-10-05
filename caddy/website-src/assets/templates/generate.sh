#!/bin/sh

if [ ! -f ./generate ]; then
    echo "Please run the script from its own directory.";
    exit 1;
fi

./generate ../.. ../../../website

exit;