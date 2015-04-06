#! /bin/sh
#
# A wrapper script around Docker to make sure the container is started
# in a usable way.  To be used as-is, or as a template for starting
# Docker yourself.

set -e
#set -x

TAG="jasonish/centos-suricata"
CIDFILE=./cid

build() {
    docker build --rm -t ${TAG} image
}

is_running() {
    if [ -e ${CIDFILE} ]; then
	if docker ps --no-trunc -q | grep -q $(cat ${CIDFILE}); then
	    # Is running.
	    return 0
	else
	    echo "Removing stale container ID file."
	    rm -f ${CIDFILE}
	fi
    fi

    # Is not running.
    return 1
}

ps() {
    do_exec "ps" "auxww"
}

run() {
    if is_running; then
	echo "error: container is already running."
	exit 1
    fi

    mkdir -p ./data
    mkdir -p ./data/etc/suricata/rules
    mkdir -p ./data/log/suricata
    docker run --rm --net=host --cidfile=cid \
	   -v $(pwd)/data:/data \
	   -v $(pwd)/data/etc/suricata/rules:/etc/suricata/rules \
	   -v $(pwd)/data/log:/var/log \
	   -i -t ${TAG} "$@"
    rm -f ${CIDFILE}
}

do_exec() {
    if [ ! -e "${CIDFILE}" ]; then
	echo "error: container is not running."
	exit 1
    fi
    docker exec -i -t $(cat cid) "$@"
}

exec_or_run() {
    if is_running; then
	echo "Running command in running container."
	do_exec "$@"
    else
	echo "Running command in new container."
	run "$@"
    fi
}

shell() {
    exec_or_run shell "$@"
}

update_rules() {
    exec_or_run /boot.sh update-rules
}

usage() {
cat <<EOF
    shell            Run with a shell.
    build            Build (or rebuild) the image.
EOF
}

case "$1" in

    build)
	build
	;;

    suricata)
	shift
	exec_or_run /usr/sbin/suricata "$@"
	;;

    shell)
	shift
	shell "$@"
	;;

    start)
	shift
	run start "$@"
	;;

    update-rules)
	update_rules
	;;

    ps)
	ps
	;;

    *)
	usage
	;;

esac
