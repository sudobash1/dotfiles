# cd variables
shopt -s cdable_vars

export dip='/DIP-Linux-dip-layer'
export linux="$dip/build-rzn1d/tmp/work-shared/rzn1-snarc/kernel-source"
export devicetree="$linux/arch/arm/boot/dts"
export deploy="$dip/build-rzn1d/tmp/deploy/images/rzn1-snarc"
export build="$dip/build-rzn1d/tmp/work/rzn1_snarc-poky-linux-gnueabi/linux-rzn1/4.9.88+gitAUTOINC+889036bc99-r4/linux-rzn1_snarc-standard-build"
export vmlinux="$build/vmlinux"

alias linuxline="addr2line -e '$vmlinux'"

function deploy() {
  scp "$deploy/uImage-rzn1-snarc.bin" traveler:~/tftp/uImage-initramfs-rzn1.bin
  scp "$deploy/uImage-rzn1d400-snarc-bestla.dtb" traveler:~/tftp/uImage-snarc.dtb
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
