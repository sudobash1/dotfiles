TRAPUSR1() {
  if [[ -o INTERACTIVE ]]; then
     {echo; echo "Restarting ${SHELL}"; } 1>&2
     exec "${SHELL}"
  fi
}
