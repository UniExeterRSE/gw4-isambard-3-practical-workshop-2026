# Installing Softwares

TODO: hero slide

# Available softwares

```sh
# list loaded softwares
module list
# list all available softwares
module avail
# search
module avail emacs
# load
module load brics/emacs
# unload specific one
module unload brics/emacs
# reset to defaults
module reset
```

# How

Quick show of hand: how do you install softwares on a remote computer?

- copy and paste whatever command
- brew
- mise
- conda/mamba/pixi
- spack
- others

# Trust

mention supply chain attack risk when using mise, brew, etc.

# Cloning our repo (fork)

TODO: envoy -> main

- Generates SSH key:

    ```sh
    ssh-keygen -t ssh-ed25519 -C "${ISAMBARD_HOST}"
    . <(ssh-agent -s)
    ssh-add ~/.ssh/id_ed25519
    ```

- Install `gh` and authenticate with GitHub

    ```sh
    bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026/refs/heads/envoy/bootstrap/install/gh.sh) install
    gh auth login --git-protocol ssh --web
    ```
- Go to workshop repo: <https://github.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026>
- Click Fork
- In your Fork, click Code > SSH > copy
    -   which should have copied something like `git@github.com:UniExeterRSE/gw4-isambard-3-practical-workshop-2026.git`

Then run,

```bash
mkdir -p ~/git
cd ~/git
# replace with your Fork copy. I.e. replace UniExeterRSE with your GitHub username
git clone git@github.com:UniExeterRSE/gw4-isambard-3-practical-workshop-2026.git
cd gw4-isambard-3-practical-workshop-2026
# This is where your workshop repo is
pwd
```

# Cloning our repo (read-only)

- Go to workshop repo: <https://github.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026>

Then run,

```bash
mkdir -p ~/git
cd ~/git
git clone https://github.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026.git
cd gw4-isambard-3-practical-workshop-2026
# This is where your workshop repo is
pwd
```

# More softwares

```sh
# from now on we assume you are in this directory
cd bootstrap
# VSCode CLI: you should have this already, if not, run
install/code.sh install
# install mamba, a drop-in replacement alternative of conda by the open source/scientific community  <- TODO: improve short intro on whom they are
install/mamba.sh install
# install some more binaries through conda-forge
NAME=system install/mamba-env.sh install
```

# Anaconda vs. conda vs. mamba vs. pixi

TODO: enough time?

# Unpacking

`install/mamba.sh install` installed a **base** conda environment. You should never touch this. To upgrade, to latest version, rerun this script.

`NAME=system install/mamba-env.sh install` installed an environment named `system`. You can see from a list of softwares inside it: `bootstrap/conda/system_linux-aarch64.yml`

```sh
# list available environments:
mamba list --envs
# load
mamba activate system
# list installed packages in this environment
mamba list
```

# Create your first environment

```sh
# create and wait
mamba env create -f conda/py314_linux-aarch64.yml -y
# load
mamba activate py314
which python
# try
python
```


Or play around with your own environment

```sh
mamba create -n my_fancy_env python=3.14 numpy numba
```

# Pixi

- direnv
- pixi in this project

# Others

- [Spack](https://docs.isambard.ac.uk/user-documentation/guides/spack/)
- [Containers](https://docs.isambard.ac.uk/user-documentation/guides/containers/)
- [More examples from official documentation](https://docs.isambard.ac.uk/user-documentation/tutorials/intro-tour/)
