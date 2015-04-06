#! /bin/sh

update_rules() {
    cd /etc/suricata && \
	curl -L -o - -s http://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz | tar zxvf -
}

usage() {
cat <<EOF
    suricata [args]        Run Suricata.
    shell                  Run a shell.
    update-rules           Update Suricata rules.
EOF
}

SURICATA_ARGS="-i eth0"
export SURICATA_ARGS

start() {
    echo "start: $@"
    exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
}

case "$1" in

    update-rules)
	update_rules
	;;

    shell)
	/bin/bash "$@"
	;;

    suricata)
	/usr/sbin/suricata "$@"
	;;

    start)
	shift
	start "$@"
	;;

    *)
	exec "$@"
	;;

esac
