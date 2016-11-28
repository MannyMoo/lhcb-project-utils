Utilities for configuring your linux environment for doing PPE projects, assuming you're running on a Glasgow desktop or ppelx.

To get setup you should just need to do:

```shell
eval "$(curl -fsSL https://raw.github.com/MannyMoo/lhcb-project-utils/master/setup.sh)"
```

which will just clone the repository to ~/lib/bash and edit your ~/.bashrc to source setup-root.sh then configure a recent version of ROOT using the `setup_root` function. It'll also make your ~/.bash_profile source ~/.bashrc, since generally you want all login commands to be in ~/.bashrc. 

If you prefer, you can set up ROOT through the LHCb environment, which will generally give an even more recent version, with 

```shell
setup_root_lhcb
```

or if you want to stick with ROOT5, rather than ROOT6, you can use

```shell
setup_root5_lhcb
```
