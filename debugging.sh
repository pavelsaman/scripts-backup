#!/usr/bin/env bash

PS4="($BASH_SOURCE:$LINENO): "
# 9 FD will be this file
exec 9>"$0-debug.log"
# STDERR to 9 FD
exec 2>&9
# SET BASH TRACE FD to 9
BASH_XTRACEFD=9

# turn on tracing
set -x

echo "hai"
