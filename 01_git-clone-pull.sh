#!/bin/sh
set -eu
set -x

URL=https://github.com/NLnetLabs/krill.git
DIR=krill

if [ -e $DIR ]; then
    cd $DIR
    git pull
else
    git clone $URL $DIR
    cd $DIR
fi
