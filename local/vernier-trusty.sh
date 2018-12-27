export poky=~/poky
export build=$poky/build
export deploy=$build/tmp/deploy
export ipk=$deploy/ipk/cortexa8-vfp-neon
export builds=$build/tmp/work/cortexa8-vfp-neon-poky-linux-gnueabi
export vernier=$poky/meta-vernier
export blv=$poky/meta-blv
export scripts=$poky/meta-blv/scripts
export krill=$builds/krill/2.0.1+svnr1-r1/git
export espeak=$blv/recipes-blv/espeak
export patches=$krill/files/blv-bbs-and-patches
export sysroot=$build/tmp/sysroots/labquest2
export inc=$build/tmp/sysroots/labquest2/usr/include

export PATH="$PATH:$HOME/poky/build/tmp/sysroots/x86_64-linux/usr/bin/cortexa8-vfp-neon-poky-linux-gnueabi"
