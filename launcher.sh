#! /bin/sh
#
# Docker wrapper script for common commands.

TAG="jasonish/centos-suricata:2.0.7"

build() {
    docker build ${BUILD_OPTS} --rm -t ${TAG} image
}

run() {
    if tty > /dev/null; then
        tty="--tty"
    fi
    exec docker run ${tty} ${CIDFILE} -i --rm=${DOCKER_RUN_RM:=true} \
	 --entrypoint=${DOCKER_RUN_ENTRYPOINT:="/tools/boot"} \
	 --net=host ${ENV_FILE} \
	 -v $(pwd)/data:/data \
	 ${VOLUMES} \
	 ${DOCKER_ARGS} ${TAG} "$@"
}

run_commit() {
    (CIDFILE="--cidfile=cid" \
	    DOCKER_RUN_RM=false \
	    DOCKER_RUN_ENTRYPOINT="/tools/boot" \
	    run /tools/update) && \
	echo "Committing." && \
	docker commit $(cat cid) ${TAG} && \
	rm -f cid
}

usage() {
cat <<EOF
usage: $0 <command> [args...]

commands:

    run [command]        - Default to a shell.
    build                - (Re)builds the container.
 
EOF
EOF
}

case "$1" in

    build)
	build
	;;

    run)
	shift
	run "$@"
	;;

    update)
	run_commit /tools/update
	;;

    *)
	usage
	;;

esac
