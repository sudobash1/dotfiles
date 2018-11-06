setopt cdablevars

function resource() {
    source ~/.shrc.local.sh
    source ~/.zshrc.local.zsh
}

function deploy() {
    local usage="Usage: ${0:t} path/to/file.ipk [host]"
    if [[ -z $1 ]]; then
        echo $usage
        return
    fi
    local ipk=${1:t}
    local host=${2-lq2}
    scp "$1" root@$host:/tmp
    ssh root@$host "ipkg install '/tmp/$ipk' --force-downgrade; rm '/tmp/$ipk'"
}

function deploy_lqa() {
    dest=$(ssh deathstar 'echo /media/stephen.robinson/*' | awk '{print $1}')
    if [[ $dest =~ "\*" ]]; then
        echo "Insert a flash drive"
        return
    else
        echo "Deploying to $dest"
    fi
    ssh deathstar "rm $dest/*.lqa"
    scp "$1" "stephen.robinson@deathstar:/$dest"
    ssh deathstar "umount $dest"
}

function restart_x11() {
    local host=${1-lq2}
    ssh root@$host "cd /etc/init.d && ./xserver-nodm restart; sleep 2 ./xserver-nodm start; sleep 3"
}

function gdb_run() {
    local usage="Usage: ${0:t} <cmd> [host:[port]] [--env var=val [var2=val2 ...]] -- [arg1 [arg2 ...]]"
    if [[ -z $1 ]]; then
        echo $usage
        return
    fi
    local cmd=$1
    local host="10.0.0.75"
    local port="1234"
    shift 1
    if [[ $1 =~ "^[^-].+$" ]]; then
        if [[ $1 =~ ":[0-9]+$" ]]; then
            host=$(awk -F: '{print $1}' <<< "$1")
            port=$(awk -F: '{print $2}' <<< "$1")
        else
            host="$1"
        fi
        shift 1
    fi
    local env=""
    if [[ $1 == "--env" ]]; then
        shift 1
        while [[ $# != 0 && $1 != "--" ]]; do
            env="$env $1"
            shift 1
        done
    fi
    if [[ $1 == "--" ]]; then
        shift 1
    elif [[ -n $1 ]]; then
        echo $usage
        return
    fi

    local full_path="$cmd"
    if [[ "${cmd}" == "${cmd:t}" ]]; then
        full_path=$(ssh root@$host "which $cmd")
    fi
    # Copy down the executable so gdb will have it
    scp "root@$host:$full_path" /tmp/$cmd.$$ || {
        echo "No such executable found: $cmd"
        return
    }

    local gdbserver_pid=$(ssh root@$host "$env gdbserver localhost:${port} $full_path $@ >/dev/null 2>&1 & echo \$!; disown")

    cgdb -d arm-poky-linux-gnueabi-gdb /tmp/$cmd.$$ -ex "target remote $host:$port"
    rm /tmp/$cmd.$$

    # The gdbserver should get killed automatically when gdb exists, but just in case...
    ssh root@$host "kill $gdbserver_pid >/dev/null 2>/dev/null"
}

function gdb_attach() {
    if [[ -z $1 ]]; then
        echo "Usage: ${0:t} <pid> [host[:port]]"
        echo "       ${0:t} <exec_name> [host[:port]]"
        return
    fi
    local host="10.0.0.75"
    local port="1234"
    if [[ -n $2 ]]; then
        if [[ $2 =~ ":[0-9]+$" ]]; then
            host=$(awk -F: '{print $1}' <<< "$2")
            port=$(awk -F: '{print $2}' <<< "$2")
        else
            host="$2"
        fi
    fi
    if [[ $1 =~ '^[0-9]+$' ]]; then
        local pid=$1
    else
        local pid="$(ssh root@$host "pgrep '$1'")"
        if [[ $pid =~ $'\n' ]]; then
            echo "Multiple pids, please pick one:"
            ssh root@$host "ps" | grep "$1" --color=never
            return
        fi
    fi
    # Copy down the executable so gdb will have it
    scp root@$host:/proc/$pid/exe /tmp/exe.$pid

    local gdbserver_pid=$(ssh root@$host "gdbserver --attach localhost:${port} $pid >/dev/null 2>&1 & echo \$!; disown")

    cgdb -d arm-poky-linux-gnueabi-gdb /tmp/exe.$pid -ex "target remote $host:$port"
    rm /tmp/exe.$pid

    # The gdbserver should get killed automatically when gdb exists, but just in case...
    ssh root@$host "kill $gdbserver_pid >/dev/null 2>/dev/null"
}

function deploy_bin() {
    if [[ -z $1 ]]; then
        echo "Usage: ${0:t} <exe_path> [host]" 
        return 1
    fi
    scp $1 root@${2-lq2}:/usr/bin
}
function deploy_home() {
    if [[ -z $1 ]]; then
        echo "Usage: ${0:t} <exe_path> [host]" 
        return 1
    fi
    scp $1 root@${2-lq2}:/home/root
}
alias deploy_ngi_bin='scp ~/poky/build/tmp/work/cortexa8-vfp-neon-poky-linux-gnueabi/ngi-app/2.8.4+gitAUTOINC+1fb5b5797e-r*/git/src/.libs/ngi root@10.0.0.75:/tmp && ssh lq2 "mv /tmp/ngi /usr/bin; pkill ngi"'
alias deploy_sonify='scp ~/poky/build/tmp/work/cortexa8-vfp-neon-poky-linux-gnueabi/sonify/0.0.1+git*/git/src/sonify root@10.0.0.75:/tmp && ssh lq2 "chmod 755 /tmp/sonify; mv /tmp/sonify /usr/bin; pkill sonify; sonify >/tmp/sonify.log 2>&1 &"'
