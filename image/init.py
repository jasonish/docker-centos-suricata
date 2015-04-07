#! /usr/bin/env python

from __future__ import print_function

import sys
import os
import argparse
import subprocess
import re

# Console print colours.
BLUE   = "\033[36m"
YELLOW = "\033[93m"
RED    = "\033[91m"
RESET  = "\033[0m"

def print_colour(msg, fileobj=sys.stdout, colour=BLUE):
    fileobj.write(colour + msg + RESET + "\n")
    fileobj.flush()

def find_first_ether_device():
    output = subprocess.check_output("ip -o link show", shell=True)
    m = re.search("^\d+: (.*):.*link\/ether.*$", output, re.M)
    if m:
        return m.group(1)

def get_rules_md5(directory):
    return subprocess.check_output(
        "find %s -type f -exec cat {} \; | md5sum" % (directory), shell=True)

def update_rules(restart=True):
    pre_md5=None
    post_md5=None

    if restart:
        pre_md5 = get_rules_md5("/data/etc/suricata/rules").strip()
    subprocess.Popen("idstools-surirule", shell=True).wait()
    if restart:
        post_md5 = get_rules_md5("/data/etc/suricata/rules").strip()
        if pre_md5 == post_md5:
            print("Not restarting Suricata, rules have not changed.")
        else:
            print("Restarting Suricata.")
            subprocess.Popen(
                "supervisorctl restart suricata", shell=True).wait()

def start(args):

    if not os.path.exists("/etc/suricata/rules/classification.config"):
        print_colour("Updating rules.", colour=BLUE)
        update_rules(restart=False)

    parser = argparse.ArgumentParser("start")
    parser.add_argument("--suricata", metavar="<args>",
                        help="Suricata program arguments")
    args = parser.parse_args(args)

    default_suricata_args = []
    default_suricata_args += ["--pidfile", "/var/run/suricata.pid"]
 
    if args.suricata:
        suricata_args = "%s %s" % (
            " ".join(default_suricata_args), args.suricata)
    if not args.suricata:
        interface = find_first_ether_device()
        if not interface:
            print_colour(
                "Failed to find interface to run Suricata on. Exiting.",
                colour=RED)
            return 1
        print_colour("Using interface: %s" % (interface), colour=YELLOW)
        suricata_args = "%s --af-packet=%s" % (
            " ".join(default_suricata_args), interface)

    # Supervisord command.
    command = ["/usr/bin/supervisord",
               "-c", "/etc/supervisord.conf",
               "--nodaemon"]

    print_colour(
        "Running Suricata with arguments: %s" % (suricata_args), colour=BLUE)

    # Supervisor environment.
    environ = {}
    environ["SURICATA_ARGS"] = suricata_args

    # Exec.
    return os.execve(command[0], command, environ)

def usage():
    print("""
usage: <command> [args...]

commands:
    shell          - Run a shell.
    start          - Start the container.
""")

def main():
    args = list(sys.argv)
    progname = args.pop(0)
    command = None
    if args:
        command = args.pop(0)

    if command:
        if command == "shell":
            return os.execv("/bin/bash", ["/bin/bash"] + args)

        if command == "start":
            return start(args)

        if command == "update-rules":
            return update_rules()
        
    usage()
    return 1

if __name__ == "__main__":
    sys.exit(main())
