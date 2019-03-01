#!/bin/sh

if [ "$1" != 'calledFromInTmuxConf' ] || [ ! "$TMUX" ]; then
  echo "This file is not to be called manually." 1>&2
  echo "It is to be called only by tmux in tmux.conf." 1>&2
  exit 1
fi

tmux_socket_path=$(echo $TMUX | sed 's/,.*//')

# No stdout/err
rm -f "${tmux_socket_path}_version_source_log"
exec 1>>"${tmux_socket_path}_version_source_log"
exec 2>>"${tmux_socket_path}_version_source_log"

tmux_pid=$(echo $TMUX | cut -d, -f2)
tmux_ver=$(/proc/$tmux_pid/exe -V | cut -d' ' -f2)
tmux_socket_cmd="/proc/$tmux_pid/exe -S '$tmux_socket_path'"
conf_dir="$DOTFILES_REPO/scripts/tmux/tmux_version_conf"

echo "Setting up for tmux v$tmux_ver"

cd $conf_dir
for file in *; do
  echo $file
done | awk -F "_v" '
  {
    if ($2<='"$tmux_ver"' && $2>vers[$1]) {
      vers[$1]=$2;
    }
  }
  END {
    for(f in vers) {
      if(vers[f]) {
        print "sourcing '"$conf_dir/"'" f "_v" vers[f];
        system("'"$tmux_socket_cmd"' source '"$conf_dir/"'" f "_v" vers[f]);
      } else {
        print "sourcing '"$conf_dir/"'" f;
        system("'"$tmux_socket_cmd"' source '"$conf_dir/"'" f);
    }
  }
}'
