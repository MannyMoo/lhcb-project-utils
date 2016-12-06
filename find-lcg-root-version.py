#!/bin/env python

import os, sys, re
from collections import defaultdict

def get_lcg_releases() :
    lcgreleasedir = filter(lambda d : 'lcg/releases' in d, 
                           os.environ['LCG_release_area'].split(':'))[0]

    lcgdirs = filter(lambda d : os.path.isdir(os.path.join(lcgreleasedir, d)) and d.split(os.sep)[-1].find('LCG_') == 0, 
                     os.listdir(lcgreleasedir))
    confs = defaultdict(lambda : defaultdict(dict))
    for d in lcgdirs :
        d = os.path.join(lcgreleasedir, d)
        rootdir = os.path.join(d, 'ROOT')
        if not os.path.isdir(rootdir) :
            continue 
        rootver = os.listdir(rootdir)[0]
        if not rootver[0].isdigit() :
            continue
        cmtconfs = os.listdir(os.path.join(d, 'ROOT', rootver))
        for conf in cmtconfs :
            confs[conf][rootver] = d.split(os.sep)[-1].split('_')[-1]
    return confs
    
def main() :
    if not 'CMTCONFIG' in os.environ :
        print 'CMTCONFIG is not defined, can\'t find ROOT version!'
        sys.exit(1)
    confs = get_lcg_releases()
    cmtconf = os.environ['CMTCONFIG']
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
    print '. SetupProject.sh LCGCMT ' + conf[rootver] + ' ROOT pytools'
    
if __name__ == '__main__' :
    main()
