# GHC

## GHCi

    % ghci
    ghci> let a = 1
    ghci> a
    1
    ghci> [ x | x <- [1..10], x `mod` 2 == 0 ]
    [2,4,6,8,10]

    -- Load from a file
    ghci> :l path/to/file.hs

    -- Show the type of <expr>
    ghci> :t "Foo"
    "Foo" :: [Char]
    ghci> :t (+)
    (+) :: Num a => a -> a -> a

    -- Display infomation about the given names
    ghci> :i Maybe
    data Maybe a = Nothing | Just a -- Defined in Data.Maybe
    instance Eq a => Eq (Maybe a) -- Defined in Data.Maybe
    ....

    -- Import module(s)
    ghci> :m + Data.Char
    ghci> chr 65
    "A"
    ghci> :m - Data.Char
    <interactive>:1:1: Not in scope: `chr'

    -- Load a package
    ghci> :set -package yourpkg

    -- Quit GHCi
    ghci> :q
