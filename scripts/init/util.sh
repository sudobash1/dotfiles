#!/bin/bash

shopt -s extglob

#
# choose_yn "prompt" ["yes_action"] ["no_action"] ["default"]
#
# Both yes_action and no_action default to do nothing
#
function choose_yn() {
  local prompt="${1?Error: choose_yn: prompt not set}"
  local yes_action="${2-":"}"
  local no_action="${3-":"}"
  local y="y"
  local n="n"
  local case_y="@(y|Y)"
  local case_n="@(n|N)"
  case "$4" in
    y|Y) case_y="@(y|Y|)"; y="Y" ;;
    n|N) case_n="@(n|N|)"; n="N" ;;
  esac
  while true; do
    read -p "$prompt [$y/$n]? " choice
    case "$choice" in
      $case_y) $yes_action ;;
      $case_n) $no_action ;;
      *) continue;;
    esac
    break
  done
}
