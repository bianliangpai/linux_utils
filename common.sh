#! /bin/bash

apt_clear() {
    sudo killall apt
    sudo rm /var/lib/apt/lists/lock
    sudo rm /var/cache/apt/archives/lock
    sudo rm /var/lib/dpkg/lock*
    sudo dpkg --configure -a
}

apt_refresh() {
    apt_clear

    sudo apt-get update
    echo Y | sudo apt-get upgrade
}

cl() {
    FILEPATHS=$(find | grep -P '^((?!/build/.)*$')
    cnt=0
    while read -r line; do
        if [ ! -d $line ]; then
            cur=$(cat $line | wc -l)
            printf "%6d $line\n" $cur

            cnt=$(expr $cnt + $cur)
        fi
    done <<< "$FILEPATHS"

    printf "%6d total\n" $cnt
}

function get_cpucore_number() {
  printf $( grep ^processor /proc/cpuinfo | \
          wc -l |                           \
          awk '{print $1}' )
}

#
# $ cat /proc/stat
# cpu  15543 334  4963   142337 3413   0   180    0     0 0
#      user  nice system idle   iowait irq softrq steal
#
# CPU Usage = 1 - (△idle+△iowait) / △total_time
#           = 1 - (idle2+iowait2-idle1-iowait1) / (total_time2-total_time1)
#
# tips: totol_time=user+nice+system+idle+iowait+irq+sortrq
#
function get_current_cpu_loading() {
  # printf $( top -bn1 | grep "Cpu(s)" |        \
  #         sed "s/.*, *\([0-9.]*\) id.*/\1/" | \
  #         awk '{print 100-$1}' )
  stat1=$( head -1 /proc/stat )
  IFS=" " read _1 user1 nice1 system1 idle1 iowait1 irq1 softrq1 steal1 __1 ___1 <<< "$stat1"
  total_time1=$(( $user1+$nice1+$system1+$idle1+$iowait1+$irq1+$softrq1 ))
  sleep 3
  stat2=$( head -1 /proc/stat )
  IFS=" " read _2 user2 nice2 system2 idle2 iowait2 irq2 softrq2 steal2 __2 ___2 <<< "$stat2"
  total_time2=$(( $user2+$nice2+$system2+$idle2+$iowait2+$irq2+$softrq2 ))

  printf %.10f "$(( ( 10000 - ((10000 * ($idle2+$iowait2-$idle1-$iowait1)) / ($total_time2-$total_time1)) ) / 100 ))"
}
