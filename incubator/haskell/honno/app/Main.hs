module Main where

import Lib
import System.Environment
import Data.List

main = do
  args <- getArgs
  parse args

