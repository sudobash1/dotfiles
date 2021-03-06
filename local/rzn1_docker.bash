# cd variables
shopt -s cdable_vars

export dip='/DIP-Linux-dip-layer'
export rzn1d="$dip/build-rzn1d"
export linux="$rzn1d/tmp/work-shared/rzn1-snarc/kernel-source"
export devicetree="$linux/arch/arm/boot/dts"
export deploy="$rzn1d/tmp/deploy/images/rzn1-snarc"
export build="$rzn1d/tmp/work/rzn1_snarc-poky-linux-gnueabi/linux-rzn1/4.9.88+gitAUTOINC+889036bc99-r4/linux-rzn1_snarc-standard-build"
export vmlinux="$build/vmlinux"

alias linuxline="addr2line -e '$vmlinux'"

function deploy() {
  scp "$deploy/uImage-initramfs-rzn1-snarc.bin" traveler:~/tftp/uImage-initramfs-rzn1.bin
  scp "$deploy/uImage-rzn1d400-snarc-bestla.dtb" traveler:~/tftp/uImage-snarc.dtb
  echo "enter traveler sudo password when prompted"
  if [[ $1 ]]; then
    echo "$2" | ssh traveler "cat > ~/tftp/notes.txt"
    ssh traveler -t \
      "sudo mkdir -p /var/lib/tftpboot/sbr/$1/ && " \
      "sudo mv ~/tftp/* /var/lib/tftpboot/sbr/$1/"
  else
    ssh traveler -t "sudo cp ~/tftp/* /var/lib/tftpboot"
  fi
}

function traveler_load() {
  if [[ ! $1 ]]; then
    echo "Argument required"
    return 1
  fi
  echo "enter traveler sudo password when prompted"
  ssh traveler -t "sudo cp /var/lib/tftpboot/sbr/$1/* /var/lib/tftpboot"
}

function poky_init() {
  cd "$dip"
  echo "source sources/poky/oe-init-build-env build-rzn1d/"
  source sources/poky/oe-init-build-env build-rzn1d/
  touch conf/sanity.conf
  echo
  echo "run 'bitbake dip-image' to build"
  echo
}

function gen_linux_tags() {
  cd $build
  if [ $? != 0 ]; then
    echo "Error: linux not built"
    return 1
  fi
  make O=. ARCH=arm SUBARCH=rzn1 COMPILED_SOURCE=1 cscope tags
}
