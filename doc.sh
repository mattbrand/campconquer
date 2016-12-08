#!/usr/bin/env bash
set -e

while getopts ":o" opt; do
  case $opt in
    o)
      openit=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


exe=../raml2html/bin/raml2html
out=public/campconquer-api.html

echo "Building $out..."
$exe campconquer.raml > $out

if [ -n "$openit" ]; then
    echo "Opening $out..."
    open $out
fi
