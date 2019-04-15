#!/bin/sh

# This creates a ~/.terminfo with all of the latest terminfo (including tmux*)

curl -L http://invisible-island.net/datafiles/current/terminfo.src.gz | \
  gunzip | \
  tic -x -
