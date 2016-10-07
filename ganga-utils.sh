#!/bin/bash

# Functionality for using ganga. 

function ganga-at() {
    if [ ! -d "$1" ] ; then 
	mkdir -p "$1"
    fi
    logfile=$1/ganga.log
    if [ ! -e "$logfile" ] ; then
	touch $logfile
    else
	i=0
	while [ -e "${logfile}.${i}" ] ; do
	    let i+=1
	done
	mv $logfile ${logfile}.${i}
    fi
    #if [ "$SHELL" = '/bin/bash' ] ; then 
    if [ "${@:1:1}" = "$1" ] ; then
	ganga -o"[Configuration]gangadir=$1" -o"[Logging]_logfile=$logfile" "${@:2}"
    else 
	ganga -o"[Configuration]gangadir=$1" -o"[Logging]_logfile=$logfile" "${@:1}"
    fi
    unset logfile i
}

function ganga-here() {
    ganga-at `pwd`/gangadir $@
}

function lb-run-ganga-at() {
    lb-run Ganga bash -c "source $LHCBPROJECTUTILSROOT/ganga-utils.sh;ganga-at $@"
}

function lb-run-ganga-here() {
    lb-run Ganga bash -c "source $LHCBPROJECTUTILSROOT/ganga-utils.sh;ganga-here $@"
}
