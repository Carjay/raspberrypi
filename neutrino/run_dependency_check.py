#!/usr/bin/env python

import os
import re
import sys
import subprocess

# dependencies as established with Raspian Buster
deps = [
    "libfreetype6",
    "libmad0",
    "libid3tag0",
    "libvorbisfile3",
    "libsigc++-2.0-0v5",
    ("libjpeg62-turbo", "libjpeg62"), # alternative libs but the first should be the default on Buster
    "libgif7",
    "liblua5.2-0",
    "libao4",
    "libopenthreads20",
    "libswresample3",
    "libswscale5",
    "libclutter-1.0-0",
    "libavformat58"
]

def main():
    print("Checking if your system has all necessary dependencies installed to run Neutrino")
    packages = []
    missing = []

    try:
        result = subprocess.check_output(["apt", "list", "--installed"], stderr=subprocess.STDOUT)
        installed = result.splitlines()
        for idx, l in enumerate(installed):
            m = re.match(r"""(.+?)/""", l.strip())
            if m is not None:
                packages.append(m.group(1))
        print("Currently, %d packages are installed." % len(packages))
        for d in deps:
            if isinstance(d, str): # allow alternatives
                pkg_alternatives = [d]
            else:
                pkg_alternatives = d
            found = False
            for p in pkg_alternatives: # only one entry needs to match
                if p in packages:
                    found = True
            if not found:
                missing.append(pkg_alternatives[0]) # just use the first alternative

    except Exception as exc:
        print("ERROR: Unable to check installed packages: %s" % str(exc))

    if missing:
        print("%d package%s still need%s to be installed:" % (len(missing), ['','s'][len(missing)>1], ['s',''][len(missing)>1]))
        for m in sorted(missing):
            print("    %s" % m)
        reply = raw_input("Shall they be installed now? (y/N) ")
        if reply.strip().lower() == "y":
            print("Installing. apt might prompt you for your password now.")
            try:
                result = subprocess.call([ "sudo", "apt", "-y", "install" ] + missing)
                if result != 0:
                    print("")
                    print("ERROR: apt did not finish successfully. It is possible that your system is out of sync with the list of dependencies.")
                    print("Unfortunately, you have to resolve this manually. You may also have to fiddle with the Dockerfile.")
            except Exception as exc:
                print("ERROR: installing missing packages with apt failed: %s" % (str(exc)))
        else:
            print("Skipping install.")
    else:
        print("Everything ok, all required packages are already installed. Nothing to do.")

try:
    main()
except KeyboardInterrupt:
    pass
