#!/bin/sh
find $(realpath $(dirname $0)/files) -type f | \
xargs -I {} cp -vufs {} ~/
echo Done.
