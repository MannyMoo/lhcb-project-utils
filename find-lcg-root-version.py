#!/bin/env python

import os, sys, re, subprocess
from collections import defaultdict

def get_lcg_releases() :
    lcgreleasedir = os.environ['LCG_RELEASES']

    lcgdirs = filter(lambda d : os.path.isdir(os.path.join(lcgreleasedir, d)) and os.path.split(d)[-1].startswith('LCG_'),
                     os.listdir(lcgreleasedir))
    confs = defaultdict(lambda : defaultdict(list))
    for d in lcgdirs :
        lcgver = d[4:]
        # Avoid any non-standard releases and python3 (for now).
        if '_' in lcgver or 'python3' in lcgver:
            continue
        d = os.path.join(lcgreleasedir, d)
        rootdir = os.path.join(d, 'ROOT')
        if not os.path.isdir(rootdir) :
            continue 
        rootver = os.listdir(rootdir)[0]
        if not (rootver[0].isdigit() or (rootver.startswith('v') and rootver[1].isdigit())):
            continue
        cmtconfs = os.listdir(os.path.join(d, 'ROOT', rootver))
        for conf in cmtconfs :
            confs[conf][rootver.strip('v')].append(lcgver)
    return confs
    
def main() :
    if not 'CMTCONFIG' in os.environ :
        with open('/etc/redhat-release') as f:
            release = f.read()
        if 'CentOS' in release:
            cmtconf = 'x86_64-centos7-gcc9-opt'
        else:
            cmtconf = 'x86_64-slc6-gcc8-opt'
    else:
        cmtconf = os.environ['CMTCONFIG']
    confs = get_lcg_releases()
    if not cmtconf in confs :
        print 'Can\'t find ROOT version for CMTCONFIG', cmtconf + '!'
        sys.exit(1)
    conf = confs[cmtconf]
    if len(sys.argv) > 1 :
        rootver = sys.argv[1]
        if not rootver in conf :
            matchvers = filter(lambda ver : re.match(rootver, ver), conf)
            if not matchvers :
                print 'No match for ROOT version', rootver, ' for CMTCONFIG', cmtconf
                print 'Available versions are', sorted(conf.keys())
                sys.exit(1)
            rootver = sorted(matchvers)[-1]
    else :
        rootver = sorted(conf)[-1]
    args = ['lb-run', '--ext', 'root', '--ext', 'pytools', '--sh', '-c', cmtconf, 'LCG/' + sorted(conf[rootver])[-1]]
    proc = subprocess.Popen(args,
                            stdout = subprocess.PIPE,
                            stderr = subprocess.PIPE)
    stdout, stderr = proc.communicate()
    if proc.poll() != 0 :
        print 'Failed to call', ' '.join(args), ', exit code', proc.poll()
        print 'stdout:', stdout
        print 'stderr:', stderr
        sys.exit(1)
    # for line in stdout.split('\n') :
    #     # don't change the prompt.
    #     if 'PS1=' in line or '_=' in line :
    #         continue
    #     print line
    args.remove('--sh')
    args = ' '.join(args)
    print '''function root-env() {
    if [ $# -eq 0 ] ; then
        ROOTENV=1 %s $SHELL
    else
        ROOTENV=1 %s $@
    fi
}''' % (args, args)

if __name__ == '__main__' :
    main()
