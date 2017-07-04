#!/bin/bash 

# I get some super weird behaviour I haven't understood with splitting/not splitting
# args by whitespace ...

function bkk_get_lfns() {
    # Take the arguments of dirac-bookkeeping-get-files then echo a
    # list of lfns with all the other info stripped out.
    output=$(lb-run LHCbDirac/prod sh -c "dirac-bookkeeping-get-files $@")
    exitcode=$?
    if [ $exitcode != 0 ] ; then
	echo "$output"
	return $exitcode
    fi
    output=$(echo "$output" | grep "/lhcb")
    echo "$output" | awk '{print $1;}'
    # lfns=""
    # for lfn in $(echo "$output" | awk '{print $1;}') ; do
    #     lfns+="$lfn "
    # done
    # echo $lfns
}

function bkk_save_files() {
    outputfname=$1
    # bash arrays start at zero, zsh at 1 ...
    if [ "$outputfname" = "${@:1:1}" ] ; then
	bkargs=${@:2}
    else 
	bkargs=${@:1}
    fi
    lfns=$(bkk_get_lfns $bkargs)
    exitcode=$?
    if [ 0 != $exitcode ] || [ -z "$lfns" ] ; then 
	echo "Failed to get LFNs with args: 
lb-run LHCbDirac/prod dirac-bookkeeping-get-files $bkargs
$lfns"
	return 1
    fi
    echo "# lb-run LHCbDirac/prod dirac-bookkeeping-get-files $bkargs
" > $outputfname
    stats=$(lb-run LHCbDirac/prod sh -c "dirac-bookkeeping-get-stats $bkargs")
    echo "'''
$stats
'''
" >> $outputfname
    
    echo "
from Gaudi.Configuration import *
from GaudiConf import IOHelper
IOHelper('ROOT').inputFiles([" >> $outputfname
    for lfn in $(echo $lfns) ; do
        echo "'LFN:${lfn}'," >> $outputfname
    done
    echo "], clear=True)
" >> $outputfname
}

function bkk_gen_catalog() {
    local fname=$1
    local rdst=$(grep '\.rdst' $fname)
    if [ -z "$rdst" ] ; then
        local depth=1
    else
        local depth=2
    fi
    local cmd="lb-run LHCbDirac/prod dirac-bookkeeping-genXMLCatalog --Options=$fname --Catalog=tmpcatalog.xml --Depth=$depth"
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
