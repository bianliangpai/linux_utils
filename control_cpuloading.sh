#! /bin/bash

source ./common.sh

PROGRAM=bash

#trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
  while [[ $( pidof $PAROGRAM ) ]]; do
    pkill $PROGRAM
    printf "\nkilling $PROGRAM\n"
  done
  exit 1
}

function task() {
  while true; do
    true
  done
}

function main() {
  current_cpuloading=$(( $( get_current_cpu_loading | xargs -0 printf "%.0f" ) ))
  expected_cpuloading=$1
  printf "current cpuloading:  $current_cpuloading\n"
  printf "expected_cpuloading: $expected_cpuloading\n"

  if [ $(( expected_cpuloading )) -gt 100 ]; then
    printf "input should between 0 and 100\n"
    exit 0
  elif [ $(( current_cpuloading )) -gt $(( expected_cpuloading )) ]; then
    printf "current loading already greater than expected\n"
    exit 0
  else
    pre_task_id=$( pidof $PROGRAM )
    thread_cnt=0
    cpu_number=$( get_cpucore_number )

    while [ $(( cpu_number )) -gt $(( thread_cnt )) ]; do
      task &
      thread_cnt=$(( thread_cnt+1 ))
    done
    post_task_id=$( pidof $PROGRAM )
    task_pid=$( echo $post_task_id $pre_task_id $pre_task_id | \
                tr ' ' '\n' | sort | uniq -u )
    for pid in $task_pid; do
      addon=$(( $expected_cpuloading - $current_cpuloading ))
      printf "process $pid will take $addon percentage of one cpu\n"
      cpulimit -p $pid -l $addon &
    done
    wait
  fi
}

main $1