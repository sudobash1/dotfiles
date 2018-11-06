poky=~/poky
build=$poky/build
deploy=$build/tmp/deploy
ipk=$deploy/ipk/cortexa8-vfp-neon
builds=$build/tmp/work/cortexa8-vfp-neon-poky-linux-gnueabi
vernier=$poky/meta-vernier
blv=$poky/meta-blv
scripts=$poky/meta-blv/scripts
krill=$blv/recipes-blv/krill
espeak=$blv/recipes-blv/espeak
patches=$krill/files/blv-bbs-and-patches

export PATH="$PATH:$HOME/poky/build/tmp/sysroots/x86_64-linux/usr/bin/cortexa8-vfp-neon-poky-linux-gnueabi"
