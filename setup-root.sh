#!/bin/bash

# Setup the LHCb environment and ROOT.

function setup_lhcb_env() {
    . /cvmfs/lhcb.cern.ch/lib/LbEnv-stable.sh
}

function setup_root_lhcb() {
    if [ ! -z "$ROOTENV" ] || [ "$(hostname)" = "ppelogin1.ppe.gla.ac.uk" ] || [ "$(hostname)" = "ppelogin2.ppe.gla.ac.uk" ] ; then
	return
    fi
    if [ -z "`which lb-run 2> /dev/null`" ]
    then
	setup_lhcb_env
    fi
    cmd="$($LHCBPROJECTUTILSROOT/find-lcg-root-version.py $@)"
    exitcode=$?
    if [ $exitcode = 0 ] ; then
	eval "$cmd"
    else 
	echo "Call of"
	echo "$LHCBPROJECTUTILSROOT/find-lcg-root-version.py $@"
	echo "failed with exit code $exitcode"
	echo "$cmd"
    fi
}

function setup_root5_lhcb() {
    setup_root_lhcb '5\..*'
}
