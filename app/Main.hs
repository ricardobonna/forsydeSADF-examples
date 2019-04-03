module Main where

import MPEG4

import ForSyDe.Shallow hiding (Matrix, matrix)

import Text.Printf
import Control.Exception
import System.CPUTime
import Control.Parallel.Strategies
import Control.Monad
import Control.DeepSeq
import System.Environment
import Data.Matrix    -- use cabal install matrix to instal the matrix package
import Data.List
----------------------------------------------------------
--                       Tests
----------------------------------------------------------


lim :: Int
lim = 1

instance NFData a => NFData (Signal a) where rnf = rnf . fromSignal

time :: (NFData t) => Signal t -> IO (Double)
time y = do
    start <- getCPUTime
    replicateM_ lim $ do
        x <- evaluate $ y
        rnf x `seq` return ()
    end   <- getCPUTime
    let diff = (fromIntegral (end - start)) / (10^12)
    -- printf "Computation time: %0.9f sec\n" (diff :: Double)
    -- printf "Individual time: %0.9f sec\n" ( :: Double)
    return (diff / fromIntegral lim)

-- Before testing, remember to ignore the IDCT

ispow2 a | a == 2 && a > 0 = True
         | a > 0           = ispow2 (a `div` 2)
         | otherwise       = False

main = do
  a <- getArgs
  let params = take 3 a
      ftPath = head $ drop 3 a
      mbPath = head $ drop 4 a
  ftFile <- readFile ftPath
  mbFile <- readFile mbPath
  let [infsx, infsy, inbs] = map read params :: [Int]
      -- read and check bs, fs and calculate nb
      bs | (ispow2 inbs) && (inbs <= 16) = inbs
      fs | infsx `mod` bs == 0 && infsy `mod` bs == 0 = (infsx,infsy)
      nb = div (uncurry (*) fs) (bs^2)
      -- create FT signal
      ftSig = signal $ read ftFile :: Signal String
      mbSig = signal $ read mbFile :: Signal MacroBlock

      inpSize = lengthS ftSig

  -- start "real" computation
  let decoded = pnMPEG4 bs nb fs ftSig mbSig
  runtime <- time decoded
  let fps = (fromIntegral inpSize) / runtime
  -- print out the stats
  printf "MPEG4 model ForSyDe\n"
  printf "Frame size: (%d, %d)\nBlock size: %d\nNumber of frames: %d\nTime elapsed: %.4fs\nFPS: %.4f\n" (fst fs) (snd fs) bs inpSize runtime fps


instance Read MacroBlock where
  readsPrec _ x =
    [ (PosB pos (fromLists blk), tail (dropWhile (/='}') x))
    | ("PosB",r1) <- lex x
    , (blk, _) <- reads $ inBetween "[[" "]]" x
    , (pos,r4) <- reads $ dropWhile (/='(') $ inBetween "pos = (" ")" x
    ] ++
    [ (FullB pos mot (fromLists blk), tail (dropWhile (/='}') x))
    | ("FullB",r1) <- lex x
    , (blk, _) <- reads $ inBetween "[[" "]]" x
    , (mot, _) <- reads $ dropWhile (/='(') $ inBetween "motionV = " ")" x
    , (pos, _) <- reads $ dropWhile (/='(') $ inBetween "pos = (" ")" x
    ]

takeUntil :: String -> String -> String
takeUntil [] [] = []                           --don't need this
takeUntil xs [] = []
takeUntil [] ys = []
takeUntil xs (y:ys) = if   isPrefixOf xs (y:ys)
                      then xs
                      else y:(takeUntil xs (tail (y:ys)))

dropUntil :: String -> String -> String
dropUntil [] [] = []                           --don't need this
dropUntil xs [] = []
dropUntil [] ys = []
dropUntil xs (y:ys) = if   isPrefixOf xs (y:ys)
                      then (y:ys)
                      else dropUntil xs ys

inBetween :: String -> String -> String -> String
inBetween left right = takeUntil right . dropUntil left
