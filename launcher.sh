#! /bin/sh
#
# Docker wrapper script for common commands.

TAG="jasonish/centos-suricata:2.0.7"
CIDFILE=./cid

build() {
    docker build --rm -t ${TAG} image
}

run() {
    if tty > /dev/null; then
        tty="--tty"
    fi
    exec docker run ${tty} -i --rm --net=host ${ENV_FILE} \
	   -v $(pwd)/data:/data \
	   ${VOLUMES} \
	   ${DOCKER_ARGS} ${TAG} "$@"
}
# run() {
#     if is_running; then
# 	echo "error: container is already running."
# 	exit 1
#     fi

#     if [ "${RUN_IN_BACKGROUND}" = "yes" ]; then
# 	args="-i -t --detach"
#     else
# 	args="-i -t --rm"
#     fi

#     mkdir -p ./data
#     mkdir -p ./data/etc/suricata
#     touch ./data/etc/suricata/threshold.config
#     mkdir -p ./data/etc/suricata/rules
#     mkdir -p ./data/var/log/suricata
#     docker run --net=host --cidfile=cid \
# 	   -v $(pwd)/data:/data \
# 	   -v $(pwd)/data/etc/suricata/rules:/etc/suricata/rules \
# 	   -v $(pwd)/data/var/log:/var/log \
# 	   -v $(pwd)/data/var/tmp:/var/tmp \
# 	   ${args} ${TAG} "$@"
#     if [ "${RUN_IN_BACKGROUND}" != "yes" ]; then
# 	rm -f ${CIDFILE}
#     fi
# }


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

    *)
	usage
	;;

esac
