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