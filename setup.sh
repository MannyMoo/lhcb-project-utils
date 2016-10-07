#!/bin/bash

if [ ! -e ~/lib/bash ] ; then
    mkdir -p ~/lib/bash
fi
cd ~/lib/bash

git clone git://github.com/MannyMoo/lhcb-project-utils.git

echo 'export LHCBPROJECTUTILSROOT=$HOME/lib/bash/lhcb-project-utils
source $LHCBPROJECTUTILSROOT/setup-root.sh
setup_root
' >> ~/.bashrc
echo 'if [ -e ~/.bashrc ] ; then
    source ~/.bashrc
fi
' >> ~/.bash_profile
source ~/.bash_profile
