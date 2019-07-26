#!/bin/zsh

BN="${0:t}"

usage() {
  echo "Usage: $BN path/to/file.ipk [file2.ipk ... fileN.ipk] [[username@]host] -- [opkg-arg [opkg-arg [...]]]"
  echo
  echo "Default username is root"
  echo
  echo "Gets default host from \$TARGET_ADDR, falling back to the content of /tmp/target_addr"
  exit 1
}

if [[ -z $1 || ${1:e} != "ipk" ]]; then
  usage
fi

declare -a ipk_paths
while [[ ${1:e} = "ipk" ]]; do
  if [[ ! -e $1 ]]; then
    echo "$1 doesn't exist"
    usage
  fi
  ipk_paths+=$1
  shift 1
done

host=${TARGET_ADDR:-$(cat /tmp/target_addr)}
if [[ $1 = "--" ]]; then
  shift 1
elif [[ -n $1 ]]; then
  host="$1"
  shift 1
  if [[ $1 = "--" ]]; then
    shift 1
  elif [[ -n "$1" ]]; then
    echo "Unexpected argument: $1"
    usage
  fi
fi

if [[ ! $host =~ @ ]]; then
  host="root@$host"
fi

for fullpath in "$ipk_paths"; do
  ipk="${fullpath:t}"
  scp "$fullpath" "$host":/tmp
  ssh -t "$host" "opkg install '/tmp/$ipk' --force-downgrade --force-reinstall ${@}; rm '/tmp/$ipk'"
done
