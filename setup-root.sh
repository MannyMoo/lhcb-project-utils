
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
    source /afs/cern.ch/lhcb/software/releases/LBSCRIPTS/prod/InstallArea/scripts/LbLogin.sh
}
