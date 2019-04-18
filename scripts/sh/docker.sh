alias docker='sudo docker'

alias dtime_refresh='sudo docker run --rm --privileged alpine hwclock -s'

function dshell() {
  if [ "$1" = "-h" ]; then
    echo "Usage: dshell <container_name> [user_name] [shell [shell arguments]]"
    return 0
  fi
  if [ $# -eq 0 ]; then
    sudo docker ps -a
    return 1
  fi
  local docker="$1"
  local docker_ps="$(sudo docker ps -a | awk '$NF == "'"$docker"'"')"
  if [ "$docker_ps" ]; then
    sudo docker start "$docker"

    local user="eqware"
    if [ $# -ge 2 ]; then
      local user="$2"
    fi

    # Get the user's default shell
    local shell="$(sudo docker exec "$docker" getent passwd "$user" | cut -d: -f7)"
    if [ $# -ge 3 ]; then
      local shell="$3"
    fi
    [ $# -gt 3 ] && shift 3 || shift $#

    sudo docker exec -it -e "TZ=US/Pacific" -e "TERM=$TERM" -u "$user" "$docker" "$shell" "$@"
  else
    echo "No such docker container: $1"
  fi
}
