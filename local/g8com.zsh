function __get_target_addr() {
    echo ${TARGET_ADDR-sama5d2xplained}
}


function deploy_to_flashdrive() {
    if [[ $# != 1 ]]; then
        echo "deploy_to_flashdrive file";
        return 1;
    fi

    target=$1

    if [[ ! -f "$target" ]]; then
        echo "File does not exist '$target'"
        return 2;
    fi

    ssh deathstar $'
        dest=$(tail -n1 /etc/mtab | awk \'{print $2}\')
        if ! grep -q "^\\/media\\/$USER" <<< $dest; then
            echo "No flashdrive mounted"
            exit
        fi
        echo "copying to $dest"
        pv -f -s '$(wc -c < "${target}")' > "$dest/'"${target:t}"'"
        echo "Done"
        echo "Verifying"
        expected_hash="'$(md5sum "$target" | cut -d" " -f1)'"
        hash="$(md5sum "$dest/'"${target:t}"'" | cut -d" " -f1)"
        if [ "$hash" != "$expected_hash" ]; then
            echo "Copy failed"
            echo "Got hash $hash, but expected $expected_hash"
            exit
        fi
        echo "Done"
        echo "Unmounting"
        umount "$dest"
        echo "All Done"' < "$target"
}

function deploy_ipk() {
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
    local host=$(__get_target_addr)
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
        ssh -t root@$host "opkg install '/tmp/$ipk' --force-downgrade --force-reinstall ${@}; rm '/tmp/$ipk'"
    done
}

function deploy_itb() {
    usage="Usage: ${0:t} [-r] [-cr] [path/to/file.itb] [-H host] [-h|--help]

-r         rebuild
-cr        clean and rebuild
-H         specify destination host
-h|--help  show this help
"

    gen_env # Make sure env is up to date

    local itb="$builds/nant-g8-image/1.0-r1/rootfs/boot/sama5d2_xplained.itb"
    local host=$(__get_target_addr)
    local clean=false
    local rebuild=false
    while [[ $# != 0 ]]; do
        case $1 in
            -cr)
                clean=true
                rebuild=true
                ;;
            -r)
                rebuild=true
                ;;
            *.itb)
                itb="$1"
                ;;
            -H)
                shift;
                [[ $1 ]] || { echo -e "No host argument after '-h'\n$usage"; return 1; }
                host="$1"
                ;;
            -h|--help)
                echo "$usage"
                return
                ;;
            *)
                echo "Invalid argument '$1'"
                echo "$usage"
                return 1
                ;;
        esac
        shift
    done

    $rebuild && { (
        shift $# # must get rid of all arguments before source oe-init-build-env
        cd ~/poky
        source ./oe-init-build-env
        clean && bitbake -c clean -f linux-at91
        exec bitbake linux-at91
    ) || { echo "Build failed!"; return 1; } }

    ssh root@$host true || { echo "Cannot reach host '$host'"; return; }

    [[ -e $itb ]] || { echo "File '$itb' doesn't exist"; return 1; }
    scp $itb root@$host:/boot
}

function deploy_rootfs() {
    usage="Usage: ${0:t} [-r] -H [host] [-h|--help]

-r         rebuild
-H         specify destination host
-h|--help  show this help
"

    gen_env # Make sure env is up to date

    local host=$(__get_target_addr)
    local rebuild=false

    while [[ $# != 0 ]]; do
        case $1 in
            -r)
                rebuild=true
                ;;
            -H)
                shift;
                [[ $1 ]] || { echo -e "No host argument after '-h'\n$usage"; return 1; }
                host="$1"
                ;;
            -h|--help)
                echo "$usage"
                return
                ;;
            *)
                echo "Invalid argument '$1'"
                echo "$usage"
                return 1
                ;;
        esac
        shift
    done
    ssh root@$host true || { echo "Cannot reach host '$host'"; return; }

    $rebuild && { (
        shift $# # must get rid of all arguments before source oe-init-build-env
        cd ~/poky
        source ./oe-init-build-env
        exec bitbake nant-g8-image
    )  || { echo "Build failed"; return 1; } }

    local archive=$(ls -t $images/nant-g8-image-$(__get_machine)-*.rootfs.tar.gz | head -n1)
    [[ $archive ]] || { echo "Cannot find archive!"; return 1; }
    echo "Deploying '$archive'"

    scp $archive root@$host:~ || return 1

    archive=${archive:t}
    ssh root@$host "
        mount /dev/mmcblk0p2 /mnt && \
        cd /mnt && \
        echo 'Removing old installation files' && \
        rm -rf bin boot dev etc lib media mnt proc run sbin sys tmp usr var && \
        echo 'Installing new files' && \
        tar xf ~/'$archive' --warning=no-timestamp && \
        echo 'Removing ${archive}' && \
        rm -f ~/'$archive' && \
        echo 'Shutting down' && \
        shutdown -h now
    "
}

function setup_build_env() {
    if [[ -n $1 ]]; then
        if ! { cd "$builds/$1" || \
               cd "$builds/../cortexa5hf-neon-poky-linux-gnueabi/$1" || \
               cd "$builds/../all/$1"; } 2>/dev/null then
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
    export PATH="$__ZSHRC_LOCAL_DEFAULT_PATH:$PATH"
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
    host="${2-$(__get_target_addr)}"
    dest_dir="${3-/usr/bin}"
    scp $1 root@$host:/tmp
    ssh root@$host "chmod 755 /tmp/${1:t} && mkdir -p $dest_dir && mv /tmp/${1:t} $dest_dir && ls ${dest_dir}/${1:t}"
}

function gen_linux_tags() {
    (
        cd $linux || { echo "Linux not built"; exit 1 }
        setup_build_env
        make O=. ARCH=arm SUBARCH=at91 COMPILED_SOURCE=1 cscope
        #could also add tags
        cd ../git
        rm -f cscope.{files,out,out.in,out.po}
        ln -s "${linux:h}/build/cscope.files" cscope.files
        ln -s "${linux:h}/build/cscope.out" cscope.out
        ln -s "${linux:h}/build/cscope.out.in" cscope.out.in
        ln -s "${linux:h}/build/cscope.out.po" cscope.out.po
    )
}

export __ZSHRC_LOCAL_DEFAULT_PATH="$PATH"
# vim: ft=zsh
