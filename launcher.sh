#! /bin/bash
#
# Docker wrapper script for common commands.

CONFIG_FILENAME="config"
TAG="${TAG:=jasonish/centos-suricata:stable}"

if [ -e ${CONFIG_FILENAME} ]; then
    . ${CONFIG_FILENAME}
    DOCKER_ENV_FILE=${CONFIG_FILENAME}
fi

build() {
    docker build ${BUILD_OPTS} --rm -t ${TAG} image
}

run() {
    tty > /dev/null && tty="--tty=true" || tty="--tty=false"
    test -e "${CONFIG_FILENAME}" && env_file="--env-file=${CONFIG_FILENAME}"
    net="--net=${DOCKER_NET:=host}"
    volumes="-v $(pwd)/data:/data ${VOLUMES}"
    cidfile="--cidfile=${DOCKER_CIDFILE:=}"
    rm="--rm=${DOCKER_RM:=true}"
    entrypoint="--entrypoint=${DOCKER_ENTRYPOINT:=/tools/boot}"
    exec docker run -i \
	 ${tty} \
	 ${cidfile} \
	 ${rm} \
	 ${entrypoint} \
	 ${net} \
	 ${env_file} \
	 ${volumes} \
	 ${TAG} "$@"
}

supervisor() {
    run /usr/bin/supervisord --nodaemon -c /etc/supervisord.conf
}

update() {
    update_cidfile=".update-cid"
    rm -f ${update_cidfile}
    (DOCKER_CIDFILE="${update_cidfile}" \
	    DOCKER_RM=false \
	    DOCKER_ENTRYPOINT="/tools/boot" \
	    run /tools/update) && \
	echo "Committing." && \
	docker commit $(cat ${update_cidfile}) ${TAG}
    rm -f ${update_cidfile}
}

usage() {
cat <<EOF
usage: $0 <command> [args...]

commands:

    run [command]        - Default to a shell.
    build                - (Re)builds the container.
    update               - Update OS, Suricata, etc.
 
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
	update
	;;

    supervisor)
	supervisor
	;;

    *)
	usage
	;;

esac
