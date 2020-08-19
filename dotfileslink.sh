#!/bin/sh
find $(realpath $(dirname $0)/files) -mindepth 1 -maxdepth 1 \
    | xargs -I {} ln -vfs {} ~/
echo Done.
