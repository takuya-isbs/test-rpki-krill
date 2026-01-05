#!/bin/bash

read -p "Do you want to proceed? (y/n): " answer

case "$answer" in
    [yY]*)
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
