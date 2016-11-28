# Install essential sw on a new CERNVM instance. 

sudo yum install screen
sudo yum install emacs
if [ ! -d ~/public/bin ] ; then 
    mkdir -p ~/public/bin
fi
scp lxplus.cern.ch:/usr/bin/k5reauth ~/public/bin
sudo yum install tmux
sudo yum install git

# x11
sudo yum install xorg-x11-server-Xorg
sudo yum install xorg-x11-xauth

# cvmfs
sudo yum-config-manager --add-repo http://cvmrepo.web.cern.ch/cvmrepo/yum/cernvm.repo
sudo curl -O http://cvmrepo.web.cern.ch/cvmrepo/yum/RPM-GPG-KEY-CernVM && mv RPM-GPG-KEY-CernVM /etc/pki/rpm-gpg
sudo yum install cvmfs cvmfs-config-default
sudo cvmfs_config setup
scp lxplus.cern.ch:/etc/cvmfs/default.local .
sudo mv default.local /etc/cvmfs
sudo yum install svn

# Necessary for grid. Presumably can be installed from some repo, but 
# couldn't work out which. 
scp -r lxplus.cern.ch:/etc/grid-security .
sudo mv grid-security /etc
