#!/bin/sh

# This creates a ~/.terminfo with all of the latest terminfo (including tmux*)

SRC_URL=http://invisible-island.net/datafiles/current/terminfo.src.gz
{
  if command -v curl >/dev/null; then
    curl -L $SRC_URL
  elif command -v wget >/dev/null; then
    wget -O- $SRC_URL
  else
    echo "Could not find curl or wget" >&2
    exit 1
  fi
} | \
  gunzip | \
  tic -x -
