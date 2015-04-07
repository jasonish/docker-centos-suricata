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

    if [ "${RUN_IN_BACKGROUND}" = "yes" ]; then
	args="-i -t --detach"
    else
	args="-i -t --rm"
    fi

    mkdir -p ./data
    mkdir -p ./data/etc/suricata
    touch ./data/etc/suricata/threshold.config
    mkdir -p ./data/etc/suricata/rules
    mkdir -p ./data/var/log/suricata
    docker run --net=host --cidfile=cid \
	   -v $(pwd)/data:/data \
	   -v $(pwd)/data/etc/suricata/rules:/etc/suricata/rules \
	   -v $(pwd)/data/var/log:/var/log \
	   -v $(pwd)/data/var/tmp:/var/tmp \
	   ${args} ${TAG} "$@"
    if [ "${RUN_IN_BACKGROUND}" != "yes" ]; then
	rm -f ${CIDFILE}
    fi
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
	do_exec /init.py "$@"
    else
	echo "Running command in new container."
	run "$@"
    fi
}

shell() {
    exec_or_run "shell" "$@"
}

usage() {
cat <<EOF
    start [-h]         Start the container.
    start-background   Start the container in the background.
    stop               Stop the running container.
    shell              Run a shell in the image. If container is running, the
                       shell will be executing in the running container.
    build              Build (or rebuild) the image.
EOF
}

case "$1" in

    build)
	build
	;;

    shell)
	shift
	shell "$@"
	;;

    start)
	shift
	run start "$@"
	;;

    start-background)
	shift
	RUN_IN_BACKGROUND=yes run start "$@"
	;;

    stop)
	if is_running; then
	    docker stop $(cat cid)
	else
	    echo "error: container is not running."
	fi
	;;

    ps)
	ps
	;;

    *)
	usage
	;;

esac
