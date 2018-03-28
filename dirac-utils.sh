#!/bin/bash

function dirac() {
    eval "lb-run -c x86_64-slc6-gcc49-opt LHCbDirac/prod $@"
}

function dirac_check_proxy() {
    # Check time left on your dirac proxy, if it's less than the first argument 
    # in hours (default 12), then renew the proxy with 2 weeks validity.
    hrsleft=$(lhcb-proxy-info | grep timeleft | sed 's/:/ /g' | awk '{print $2;}')
    if [ ! -z "$1" ] ; then
	hrslimit="$1"
    else
	hrslimit="12"
    fi
    if [ "$hrsleft" -lt "$hrslimit" ] ; then
	lhcb-proxy-init -v "$[24*14]:00"
    fi
}

function dirac_get_lfns() {
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

function dirac_save_files() {
    # Save the LFNs from a BK query as an input file.
    outputfname=$1
    bkargs=${@:2}
    echo $bkargs
    lfns=$(dirac_get_lfns $bkargs)
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

function dirac_gen_catalog() {
    # Generate the xml catalog for a data file.
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

function dirac_get_data_settings() {
    # Get the settings for a data file from the production information:
    # DataType, InputType, CondDBtag, DDDBtag, Simulation.
    lfn=$(grep -o '/lhcb.*dst' $1 | head -n 1)
    echo "LFN: $lfn"
    bkpath=$(dirac dirac-bookkeeping-file-path -l $lfn | tail -n 1 | awk '{print $3;}')
    echo "Bk path: $bkpath"
    prod=$(dirac dirac-bookkeeping-prod4path -B $bkpath | grep -v 'Merge' | grep ':' | head -n 2 | tail -n 1 | sed 's/,/ /g' | awk '{print $NF;}')
    echo "Production: $prod"
    prodinfo=$(dirac dirac-bookkeeping-production-information $prod)
    opts=$(echo "$prodinfo" | grep 'OptionFiles.*DaVinci' | awk '{print $3}' | sed 's/;/ /g')
    settings="
'''
$prodinfo
'''

from Configurables import DaVinci
from Gaudi.Configuration import importOptions

"
    echo "Options:"
    for opt in $(echo ${opts/\$/\$}) ; do
	if [ ! -z "$(echo $opt | grep DataType)" ] ; then
	    settings+="importOptions('$opt')
"
	    echo "${opt/\$/\$}"
	fi
    done
    
    inputtype=$(python -c "print '$lfn'.split('.')[-1].upper()")
    echo "Input type: $inputtype"
    settings+="DaVinci().InputType = '$inputtype'
"

    dddb=$(echo "$prodinfo" | grep dddb | tail -n 1 | awk '{print $3;}')
    conddb=$(echo "$prodinfo" | grep CONDDB | tail -n 1 | awk '{print $3;}')
    
    echo "Tags: $dddb $conddb"
    settings+="DaVinci().CondDBtag = '$conddb'
DaVinci().DDDBtag = '$dddb'
"
    if [ ! -z "$(echo $conddb | grep sim)" ] ; then
	echo "Simulation: True"
	settings+="DaVinci().Simulation = True
"
    else
	echo "Simulation: False"
    fi
    echo "$settings" > ${1/\.py/_settings.py}
}