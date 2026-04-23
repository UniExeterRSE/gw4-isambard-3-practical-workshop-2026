This directory is partially copied from <https://github.com/ickc/envoy/> and adapted to the workshop. See `LICENSE`.

# curl-bash

``` sh
bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop/refs/heads/main/bootstrap/install/clifton.sh) install
bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop/refs/heads/main/bootstrap/install/code.sh) install
bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop/refs/heads/main/bootstrap/install/gh.sh) install
bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop/refs/heads/main/bootstrap/install/mamba.sh) install
NAME=... bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop/refs/heads/main/bootstrap/install/mamba-env.sh) install
```

Bootstrap all,

``` sh
mkdir -p ~/git/UniExeterRSE
cd ~/git/UniExeterRSE
git clone git@github.com:UniExeterRSE/gw4-isambard-3-practical-workshop.git
cd gw4-isambard-3-practical-workshop
cd bootstrap
. dotfiles/.bashrc
install/bootstrap.sh
```
