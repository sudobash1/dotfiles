alias docker='sudo docker'

function dshell() {
  if [ $# -eq 0 ] || [ $# -gt 3 ]; then
    echo "Usage: dshell <container_name> [user_name] [shell]"
    return 1
  fi
  docker_ps=$(sudo docker ps -a | awk '$NF == "'"$1"'"')
  if [ "$docker_ps" ]; then
    sudo docker start "$1"

    user="eqware"
    if [ $# -ge 2 ]; then
      user=$2
    fi

    # Get the user's default shell
    shell="$(sudo docker exec "$1" getent passwd "$user" | cut -d: -f7)"
    if [ $# -eq 3 ]; then
      shell=$3
    fi

    sudo docker exec -it -e "TERM=$TERM" -u "$user" "$1" "$shell"
  else
    echo "No such docker container: $1"
  fi
}
