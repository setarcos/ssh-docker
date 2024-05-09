#!/bin/bash

case $1 in
    "build")
        docker build -t ssh .
        ;;
    "init")
        docker run -d --name ssh --rm --volume="$PWD:/mnt" ssh
        docker exec -it ssh /bin/cp -a /etc /mnt
        docker exec -it ssh /bin/cp -a /home /mnt
        docker kill ssh
        ;;
    "run")
        docker run -d -p 2222:22 --name ssh --rm --hostname myssh \
            --volume="$PWD/etc:/etc" \
            --volume="$PWD/home:/home" \
            ssh
        ;;
    "stop")
        docker kill ssh
        ;;
    "adduser")
        docker exec -it ssh /usr/sbin/adduser -D $2 -G nobody
        docker exec -it ssh /bin/su $2 -c "/usr/sbin/addkey \"$3\""
        docker exec -it ssh /bin/sed -i "s/$2:!/$2:*/g" /etc/shadow
        ;;
    *)
        echo "Usage: ./ssh.sh [init|run|build|stop]"
        ;;
esac
