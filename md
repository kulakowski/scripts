#!/bin/sh

file=~/foo/"${1}".html
markdown "${@}" > "${file}"
exec open -a Google\ Chrome "${file}"
