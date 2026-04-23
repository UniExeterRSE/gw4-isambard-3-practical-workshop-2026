All files in this directory are “compiled” from `src/` directory.

Compilation is defined by line matching `^source FILEPATH$`, where `FILEPATH` is resolved from the basedir of current
file relatively.

Files from `bin/` will source files from `lib/`. All files in `bin/` is compiled to this directory.

# Bootstrap script

``` bash
bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop/refs/heads/main/bootstrap/install/bootstrap.sh)
```
