#!/bin/bash

function dirac() {
    eval "lb-run -c x86_64-slc6-gcc49-opt LHCbDirac/prod $@"
}

function get_lfns() {
    # Take the arguments of dirac-bookkeeping-get-files then echo a
    # list of lfns with all the other info stripped out.
    output=$(dirac dirac-bookkeeping-get-files $@ | grep '/lhcb')
    exitcode=$?
    if [ $exitcode != 0 ] ; then
	echo "$output"
	return $exitcode
    fi
    echo "$output" | awk '{print $1;}'
}

function save_files() {
    outputfname=$1
    bkargs=${@:2}
    echo $bkargs
    lfns=$(get_lfns $bkargs)
    echo "# lb-run LHCbDirac/prod dirac-bookkeeping-get-files $bkargs

from Gaudi.Configuration import *
from GaudiConf import IOHelper
IOHelper('ROOT').inputFiles([" > $outputfname
    # Need to use eval else the list of lfns isn't split.
    for lfn in $(echo $lfns) ; do
        echo "'LFN:${lfn}'," >> $outputfname
    done
    echo "], clear=True)
" >> $outputfname
}

function gen_catalog() {
    local fname=$1
    local rdst=$(grep '\.rdst' $fname)
    if [ -z "$rdst" ] ; then
        local depth=1
    else
        local depth=2
    fi
    local cmd="dirac dirac-bookkeeping-genXMLCatalog --Options=$fname --Catalog=tmpcatalog.xml --Depth=$depth ${@:2}"
    eval "$cmd"
    local xmlcode=$?
    if [ 0 != $xmlcode ] ; then
        echo 'Failed to generate xml catalog using:'
        echo "$cmd"
        return $xmlcode
    fi
    if [ -e tmpcatalog.py ] ; then
        rm tmpcatalog.py
    fi
    local xmlname="${fname/\.py/.xml}"
    mv tmpcatalog.xml $xmlname
    if [ -z "$(grep $xmlname $fname)" ] ; then
        echo "
from Gaudi.Configuration import FileCatalog

FileCatalog().Catalogs += [ 'xmlcatalog_file:${PWD}/${xmlname}', 'xmlcatalog_file:${xmlname}' ]
" >> $fname
    fi
}
