# Cabal

## Cabal

    # Create $HOME/.cabal as user package directory.
    % cabal update
    % ls ~/.cabal
    config

    # Listing packages
    % cabal list
    % cabal list --installed
    % ghc-pkg list

    # Install a package
    % cabal install <package>
    % export PATH=$HOME/.cabal/bin:$PATH

    # Re-register broken packages (You might have removed ~/.cabal directory.)
    % ghc-pkg check
    The following packages are broken, ....
    ....
    % ghc-pkg unregister <package, ....>
    % cabal install <package, ....>

## HLint

    % cabal install hlint
    % hlint .

`haskell-src-exts` depends `happy` installed at --global.

    Configuring haskell-src-exts-1.13.5...
    setup: The program happy version >=1.17 is required but it could not be found.
    ...
    % yum install --enablerepo=epel happy
    # or
    % sudo cabal install happy --global
