# Installation

## Linux

* [Haskell Platform for Linux](http://www.haskell.org/platform/linux.html)
* [The Glasgow Haskell Complier](http://www.haskell.org/ghc/)

Download and install GHC.

    % su -
    % cd /usr/local/src
    % curl -LO "http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-x86_64-unknown-linux.tar.bz2"
    % bzip2 -dc ghc-7.6.3-x86_64-unknown-linux.tar.bz2 | tar xvf -
    % cd ghc-7.6.3-x86_64-unknown-linux
    # Install at /usr/local/ghc/ghc-7.6.3
    % ./configure --prefix=/usr/local/ghc/ghc-7.6.3
    % make install
    ...
    % export PATH=/usr/local/ghc/ghc-7.6.3/bin:$PATH
    % which ghc
    % /usr/local/ghc/ghc-7.6.3/bin/ghc

The official page recommends installing [Haskell Platform](http://www.haskell.org/platform/). But we prefer to install `Cabal` directly from [its hackage page](http://hackage.haskell.org/package/cabal-install).

    % curl -LO "http://hackage.haskell.org/packages/archive/cabal-install/1.16.0.2/cabal-install-1.16.0.2.tar.gz"
    % tar xvfz cabal-install-1.16.0.2.tar.gz
    % cd cabal-install-0.16.0.2
    % sh ./bootstrap.sh
    ...
    % cabal update
    % export PATH=$HOME/.cabal/bin:$PATH
    % which cabal
    % ~/.cabal/bin/cabal
    % cabal --version
    cabal-install version 1.16.0.2
    using version 1.16.0 of the Cabal library

See <http://hackage.haskell.org/trac/hackage/wiki/CabalInstall> more details.

Use `cabal-dev` in favor of `cabal`. It supports sandboxed cabal-install repositories.

    % cabal install cabal-dev
    % which cabal-dev
    % ~/.cabal/bin/cabal-dev

Just use `caba-dev` command instead of `cabal`. By default, it creates a `./cabal-dev` directory as the sandbox.

    % cd /path/to/project
    % cabal-dev install doctest
    % ls cabal-dev
    bin/ lib/ logs/ packages-7.6.3.conf/ packages/ share/ cabal.config
    % cabal-dev/bin/doctest --help
    ...

Also specify a sandbox directory by using `--sandbox` option.

    % cabal-dev install --sandbox=~/.cabal-dev/yesod
