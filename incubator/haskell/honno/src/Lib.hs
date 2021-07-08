module Lib
    ( parse
    ) where

parse ("s" : words) = simpleSearch words
parse ["l", num ] = listNotes num 

simpleSearch words = putStrLn ("Simple Search for words: " ++ (unwords words))
listNotes num = putStrLn ("List " ++ num ++ " notes:")
