#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

FILE_SCRIPT='/tmp/haproxy_ja4h.lua'
FILE_HTML='/tmp/index.html'

cd ..

if ! [ -L "$FILE_SCRIPT" ]
then
  echo '### LINKING SCRIPT ###'
  ln -s "$(pwd)/ja4h.lua" "$FILE_SCRIPT"
fi
if ! [ -L "$FILE_HTML" ]
then
  echo '### LINKING HTML ###'
  ln -s "$(pwd)/test/index.html" "$FILE_HTML"
fi

echo '### RUNNING ###'
haproxy -W -f test/haproxy_example.cfg
