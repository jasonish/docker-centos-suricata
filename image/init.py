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

def start(args):

    parser = argparse.ArgumentParser("start")
    parser.add_argument("--suricata", help="Suricata program arguments")
    args = parser.parse_args(args)
 
    if args.suricata:
        suricata_args = args.suricata
    if not args.suricata:
        interface = find_first_ether_device()
        if not interface:
            print_colour(
                "Failed to find interface to run Suricata on. Exiting.",
                colour=RED)
            return 1
        print_colour("Using interface: %s" % (interface), colour=YELLOW)
        suricata_args = "--af-packet=%s" % (interface)

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
        
    usage()
    return 1

if __name__ == "__main__":
    sys.exit(main())








