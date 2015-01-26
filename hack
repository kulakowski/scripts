#!/bin/sh

case $TERM in
    dumb) USE_TTY='' ;;
    *) USE_TTY=-t ;;
esac

exec emacsclient $USE_TTY --alternate-editor= "$@"
