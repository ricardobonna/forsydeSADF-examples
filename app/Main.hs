module Main where

import MPEG4

import ForSyDe.Shallow

import Text.Printf
import Control.Exception
import System.CPUTime
import Control.Monad
import Control.DeepSeq
import System.Environment
import Data.Matrix    -- use cabal install matrix to instal the matrix package

----------------------------------------------------------
--                       Tests
----------------------------------------------------------


lim :: Int
lim = 10^5

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
  let [infsx, infsy, inbs, nSamp] = map read a :: [Int]
      -- read and check bs, fs and calculate nb
      bs | (ispow2 inbs) && (inbs <= 16) = inbs
      fs | infsx `mod` bs == 0 && infsy `mod` bs == 0 = (infsx,infsy)
      nb = div (uncurry (*) fs) (bs^2)
      -- create FT signal
      ftSig = signal $ cycle $ ["I"] ++ (map ((++) "P" . show) [1..(nb-1)])
      -- create input signal
      inSig = signal $ cycle $ genIBlocks ++ (concat . map genPBlocks) [1..(nb-1)]
      -- generator for I blocks
      genIBlocks = frame2mblocks (1,1) (bs,bs) idFrame
      idFrame = uncurry matrix fs $ \(i,j) -> if i == j then 1 else 0
      -- generator for P blocks
      genPBlocks x = take x $ cycle [pBlock1, pBlock2, pBlock3]
      blockDummy = matrix bs bs $ \(i,j) -> (j-1)
      pBlock1 = FullB {pos = (3,3), block = blockDummy, motionV = (0,-1)}
      pBlock2 = FullB {pos = (3,1), block = blockDummy, motionV = (0,1)}
      pBlock3 = FullB {pos = (3,3), block = blockDummy, motionV = (1,1)}
  -- start "real" computation
  let decoded = pnMPEG4 bs nb fs ftSig (takeS nSamp inSig)
  runtime <- time decoded
  -- print out the stats
  printf "%d\t%d\t%d\t%d\t%.9f\n" bs (fst fs * snd fs) nb nSamp runtime
