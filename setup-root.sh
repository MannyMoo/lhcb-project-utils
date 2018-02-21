
# CERN AFS is deprecated.
#LHCBRELEASEDIR=/afs/cern.ch/lhcb/software/releases/
LHCBRELEASEDIR=/cvmfs/lhcb.cern.ch/lib/lhcb/


function _setup_root() {
    local CMTCONFIG="$1"
    local GCCVERSION="$2"
    local PYTHONVERSION="$3"
    local ROOTVERSION="$4"
    # Need to add the blank argument after setup.sh as it checks "$1" for a user defined gcc home dir.
    . /afs/cern.ch/sw/lcg/external/gcc/${GCCVERSION}/${CMTCONFIG}/setup.sh ""
    export PATH="/afs/cern.ch/sw/lcg/external/Python/${PYTHONVERSION}/${CMTCONFIG}/bin:${PATH}"
    export LD_LIBRARY_PATH="/afs/cern.ch/sw/lcg/external/Python/${PYTHONVERSION}/${CMTCONFIG}/lib:${LD_LIBRARY_PATH}"
    cd "/afs/cern.ch/sw/lcg/app/releases/ROOT/${ROOTVERSION}/${CMTCONFIG}/root/"
    . ./bin/thisroot.sh;
    cd -
}

function setup_root_slc5() {
    CMTCONFIG=x86_64-slc5-gcc47-opt
    GCCVERSION=4.7.2p1
    PYTHONVERSION=2.7.3
    ROOTVERSION=5.34.26
    _setup_root $CMTCONFIG $GCCVERSION $PYTHONVERSION $ROOTVERSION
}

function setup_root_slc6() {
    # From SetupProject LCGCMT 72a ROOT pytools (latest version that doesn't use ROOT 6.X)
    CMTCONFIG=x86_64-slc6-gcc48-opt
    GCCVERSION=4.8.1
    PYTHONVERSION=2.7.4
    ROOTVERSION=5.34.34
    _setup_root $CMTCONFIG $GCCVERSION $PYTHONVERSION $ROOTVERSION
}

function setup_root() {
    local RELEASE="`cat /etc/redhat-release`"
    if [ `expr match "$RELEASE" ".*5\."` -ne 0 ] ; then
	setup_root_slc5
    else
	setup_root_slc6
    fi
}

function setup_lhcb_env() {
    local RELEASE="`cat /etc/redhat-release`"
    local releasedir=
    # Use a newer version of python than default if we're on slc5.
    if [ `expr match "$RELEASE" ".*5\."` -ne 0 ] ; then
        # The latest version of LbScripts uses python syntax that's not supported by the ancient
        # version used by default on ppelx (2.4) so use this one.
	source ${LHCBRELEASEDIR}/LBSCRIPTS/LBSCRIPTS_v8r4p3/InstallArea/scripts/LbLogin.sh
    else
	source ${LHCBRELEASEDIR}/LBSCRIPTS/prod/InstallArea/scripts/LbLogin.sh
    fi
}

function setup_root_lhcb() {
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
    fi
}

function setup_root5_lhcb() {
    setup_root_lhcb '5\..*'
}
