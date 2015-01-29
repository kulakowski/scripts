#!/bin/sh

dir=~/foo/.markdown
mkdir -p "${dir}"

file="${dir}"/"${1}".html
markdown "${@}" > "${file}"
exec open -a Google\ Chrome "${file}"
