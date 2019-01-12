setopt cdablevars

function resource() {
    source ~/.shrc.local.sh
    source ~/.zshrc.local.zsh
}

function __get_lq_addr() {
    echo ${LQ2_ADDR-lq2}
}

function deploy() {
    local usage="Usage: ${0:t} path/to/file.ipk [file2.ipk ... fileN.ipk] [host] -- [opkg-arg [opkg-arg [...]]]"
    if [[ -z $1 || ${1:e} != "ipk" ]]; then
        echo $usage
        return 1
    fi
    local -a ipk_paths
    while [[ ${1:e} == "ipk" ]]; do
        if [[ ! -e $1 ]]; then
            echo "$1 doesn't exist"
            return 1
        fi
        ipk_paths+=$1
        shift 1
    done
    local host=$(__get_lq_addr)
    if [[ $1 == "--" ]]; then
        shift 1
    elif [[ -n $1 ]]; then
        host=$1
        shift 1
        if [[ $1 == "--" ]]; then
            shift 1
        elif [[ -n "$1" ]]; then
            echo "Unexpected argument: $1"
            echo $usage
            return 1
        fi
    fi
    for fullpath in $ipk_paths; do
        local ipk=${fullpath:t}
        scp "$fullpath" root@$host:/tmp
        ssh -t root@$host "ipkg install '/tmp/$ipk' --force-downgrade ${@}; rm '/tmp/$ipk'"
    done
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
    local host=${1-$(__get_lq_addr)}
    ssh root@$host "cd /etc/init.d && ./xserver-nodm restart; sleep 2 ./xserver-nodm start; sleep 3"
}

function gdb_run() {
    local usage="Usage: ${0:t} (<cmd>|file://<local_exe>) [host:[port]] [--env var=val [var2=val2 ...]] -- [arg1 [arg2 ...]]"
    if [[ -z $1 ]]; then
        echo $usage
        return
    fi
    local local_exe=$(sed -n 's%file://\(.*\)%\1%p' <<<$1)
    if [[ -n $local_exe && ! -e $local_exe ]]; then
        echo "No such file: $local_exe"
        return
    fi
    if [[ -n $local_exe ]]; then
        local cmd=${local_exe:t}
    else
        local cmd=$1
    fi
    local host=$(__get_lq_addr)
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
    if [[ -z $full_path ]]; then
        echo "No such remote executable: $cmd"
        return
    fi
    if [[ -z $local_exe ]]; then
        # Copy down the executable so gdb will have it
        scp "root@$host:$full_path" /tmp/$cmd.$$ || {
            echo "No such executable found: $cmd"
            return
        }
    else
        cp $local_exe /tmp/$cmd.$$
    fi

    local gdbserver_pid=$(ssh root@$host "$env gdbserver localhost:${port} $full_path $@ >/dev/null 2>&1 & echo \$!; disown")

    #ssh -nNT root@$host -L $port:$host:$port &
    ssh -nNT root@$host -L ${port}:localhost:${port} &
    local ssh_pid=$!

    cgdb -d arm-poky-linux-gnueabi-gdb /tmp/$cmd.$$ -ex "set sysroot $sysroot" -ex "target remote localhost:$port"
    #cgdb -d arm-poky-linux-gnueabi-gdb /tmp/$cmd.$$ -ex "set sysroot target:" -ex "target remote localhost:$port"
    rm /tmp/$cmd.$$

    # The gdbserver & ssh forward should get killed automatically when gdb exists, but just in case...
    ssh root@$host "kill $gdbserver_pid >/dev/null 2>/dev/null"
    kill $ssh_pid >/dev/null 2>&1
}

function gdb_attach() {
    if [[ -z $1 ]]; then
        echo "Usage: ${0:t} <pid> [host[:port]]"
        echo "       ${0:t} <exec_name> [host[:port]]"
        echo "       ${0:t} file://<local_exe>[:pid] [host[:port]]"
        return
    fi
    local local_exe=$(sed -n 's%file://\([^:]*\).*%\1%p' <<<$1)
    local pid=$(sed -n 's%file://[^:]*:\([0-9]*\)$%\1%p' <<<$1)
    if [[ -n $local_exe && ! -e $local_exe ]]; then
        echo "No such file: $local_exe"
        return
    fi
    local host=$(__get_lq_addr)
    local port="1234"
    if [[ -n $2 ]]; then
        if [[ $2 =~ ":[0-9]+$" ]]; then
            host=$(awk -F: '{print $1}' <<< "$2")
            port=$(awk -F: '{print $2}' <<< "$2")
        else
            host="$2"
        fi
    fi
    if [[ -n $pid ]]; then
        # Already have the pid...
    elif [[ $1 =~ '^[0-9]+$' ]]; then
        local pid=$1
    else
        local get_pid_cmd="pgrep '$1'"
        if [[ -n $local_exe ]]; then
            get_pid_cmd="
for exe in \$(find /proc -maxdepth 2 -name exe);
    do if [ \$(basename \$(readlink \$exe || echo nosuchexe)) == '$(basename $local_exe)' ]; then
        echo \$exe | awk -F/ '{print \$3}'
    fi
done"
        fi
        pid="$(ssh root@$host "$get_pid_cmd")"
        if [[ $pid =~ $'\n' ]]; then
            echo "Multiple pids, please pick one:"
            ssh root@$host "ps" | grep "$1" --color=never
            return
        fi
    fi
    if [[ -z $pid ]]; then
        echo "Unable to find process to debug"
        return
    fi
    echo "Debugging pid: $pid"
    if [[ -n $local_exe ]]; then
        cp $local_exe /tmp/exe.$pid
    else
        # Copy down the executable so gdb will have it
        scp root@$host:/proc/$pid/exe /tmp/exe.$pid
    fi

    echo "Starting remote gdb server"
    local gdbserver_pid=$(ssh root@$host "gdbserver --attach localhost:${port} $pid >/dev/null 2>&1 & echo \$!; disown")

    echo "Starting ssh tunnel"
    #ssh -nNT root@$host -L $port:$host:$port &
    ssh -nNT -4 root@$host -L ${port}:localhost:${port} &
    local ssh_pid=$!

    echo "Starting gdb"

    #arm-poky-linux-gnueabi-gdb /tmp/exe.$pid -ex "target remote localhost:$port"
    cgdb -d arm-poky-linux-gnueabi-gdb /tmp/exe.$pid -ex "set sysroot $sysroot" -ex "target remote localhost:$port"
    rm /tmp/exe.$pid

    # The gdbserver & ssh forward should get killed automatically when gdb exists, but just in case...
    ssh root@$host "kill $gdbserver_pid >/dev/null 2>/dev/null"
    kill $ssh_pid >/dev/null 2>&1
}

function deploy_bin() {
    if [[ -z $1 ]]; then
        echo "Usage: ${0:t} <exe_path> [host] [dest-dir]"
        echo "dest-dir defaults to /usr/bin"
        return 1
    fi
    if [[ ! -e $1 ]]; then
        echo "File '$1' doesn't exist"
        return 1
    fi
    host="${2-$(__get_lq_addr)}"
    dest_dir="${3-/usr/bin}"
    scp $1 root@$host:/tmp
    ssh root@$host "chmod 755 /tmp/${1:t} && mkdir -p $dest_dir && mv /tmp/${1:t} $dest_dir"
}
function deploy_home() {
    if [[ -z $1 ]]; then
        echo "Usage: ${0:t} <exe_path> [host]"
        return 1
    fi
    scp $1 root@${2-$(__get_lq_addr)}:/home/root
}

function setup_build_env() {
    if [[ -n $1 ]]; then
        if ! cd $builds/$1; then
            echo "No such build: $1"
            return 1
        fi
        if ! cd ./*(/om[1]); then
            echo "Not built: $1"
            return 1
        fi
    fi
    local compile_script=$(
        while [[ $(pwd) != "/" ]]; do
            if [[ -f ./temp/run.do_compile ]]; then
                echo $(pwd)/temp/run.do_compile
            fi
            cd .. || exit
        done
    )
    if [[ -z $compile_script ]]; then
        echo "Never built or invalid directory"
        return 1
    fi
    source <( grep --color=never -E "^(export|cd '\/)" ${compile_script} )
}

#function __deploy() {
#    if [[ $(( $# % 3 )) != 1 || $# -lt 4 ]]; then
#        echo "Usage: $0:t <cmds> <src> <dest> <chmod> [<src> <dest> <chmod>] ..."
#        return 1
#    fi
#    cmds="$1"
#    shift 1
#    tmp=$(mktemp -d)
#    while [[ $# -ge 3 ]]; do
#        print "staging $1 to $2 (chmod '$3')"
#        mkdir -p "$tmp/$2:h"
#        cp "$1" "$tmp/$2"
#        if [[ -n "$3" ]]; then
#            chmod "$3" "$tmp/$2"
#        fi
#        shift 3
#    done
#    (
#        cd "$tmp"
#        tar czO **/* | ssh root@$(__get_lq_addr) "
#            dir=\$(mktemp -d)
#            cd \"\$dir\"
#            tar xvzf -
#            cd /
#            mv \"\$dir\"/* /
#            rm -rf \"\$dir\"
#            $cmds
#        "
#    )
#    rm -rf "$tmp"
#}

function deploy_ngi_bin() {
    echo "deploying to $(__get_lq_addr)"
    scp -C $builds/ngi-app/2.8.4+gitAUTOINC+1fb5b5797e-r*/git/src/.libs/ngi root@$(__get_lq_addr):/tmp && \
    scp -C $builds/ngi-app/2.8.4+gitAUTOINC+1fb5b5797e-r*/git/src/pages/.libs/liblqpages.so.0.0.0 root@$(__get_lq_addr):/tmp && \
    ssh root@$(__get_lq_addr) "mv /tmp/ngi /usr/bin; mv /tmp/liblqpages.so.0.0.0 /usr/lib; pkill ngi"
}

function deploy_sonify() {
#    __deploy "pkill sonify; pkill sonify_settings; DISPLAY=:0 sonify >/tmp/sonify.log 2>&1 &" \
#             $builds/sonify/0.1.0+git*/git/src/sonify /usr/bin 755 \
#             $builds/sonify/0.1.0+git*/git/src/sonify_settings /usr/bin 755 \
#             $builds/sonify/0.1.0+git*/git/po/es.gmo /usr/share/locale/es/LC_MESSAGES/sonify.mo "" \
#             $builds/sonify/0.1.0+git*/git/src/.libs/libsonify.so.0.0.0 /usr/lib 755 \
    scp $builds/sonify/0.1.0+gitAUTOINC+*/git/src/sonify root@$(__get_lq_addr):/tmp && \
    scp $builds/sonify/0.1.0+gitAUTOINC+*/git/src/sonify_settings root@$(__get_lq_addr):/tmp && \
    scp $builds/sonify/0.1.0+gitAUTOINC+*/git/po/es.gmo root@$(__get_lq_addr):/tmp/es.gmo && \
    scp $builds/sonify/0.1.0+gitAUTOINC+*/git/src/.libs/libsonify.so.0.0.0 root@$(__get_lq_addr):/tmp && \
    ssh root@$(__get_lq_addr) "
        mv /tmp/es.gmo /usr/share/locale/es/LC_MESSAGES/sonify.mo;
        chmod 755 /tmp/sonify_settings;
        mv /tmp/sonify_settings /usr/bin;
        pkill sonify_settings
        chmod 755 /tmp/sonify;
        mv /tmp/sonify /usr/bin;
        mv /tmp/libsonify.so.0.0.0 /usr/lib;
        ln -s /usr/lib/libsonify.so.0.0.0 /usr/lib/libsonify.so.0 2>/dev/null
        ln -s /usr/lib/libsonify.so.0.0.0 /usr/lib/libsonify.so 2>/dev/null
        pkill sonify
        DISPLAY=:0 sonify 1>/dev/console 2>&1 &" && \
    cp $builds/sonify/0.1.0+gitAUTOINC+*/git/src/libsonify.h $sysroot/usr/include
}

function deploy_krill() {
    scp $builds/krill/2.0.1+gitAUTOINC+*/git/src/krill-server root@$(__get_lq_addr):/tmp && \
    ssh root@$(__get_lq_addr) "
        /etc/apm/scripts.d/krill suspend
        cp /tmp/krill-server /usr/bin
        /etc/apm/scripts.d/krill resume
    "
}

function write_patch() {
    if [[ -z $1 ]]; then
        usage "${0} path/to/file.patch"
        return 1;
    fi
    if [[ ! -e "$1" || ! -h "${1}~" ]]; then
        echo "$1 and ${1}~ must exist!"
        echo "(${1}~ must be a symlink)"
        return 1;
    fi
    mv "$1" $(readlink -f "${1}~")
    mv "${1}~" "$1"
}
