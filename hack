#!/bin/sh

case $TERM in
    dumb) USE_TTY= ;;
    *) USE_TTY=-t ;;
esac

exec $HOME/.nix-profile/bin/emacsclient $USE_TTY --alternate-editor= "$@"
