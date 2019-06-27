{-# OPTIONS_GHC -O2 #-}

{-# LANGUAGE TemplateHaskell #-}

module InlineRecCallsSpec (spec) where

import TestUtils


------------------------------------------------------------------------------
-- TODO: more tests
spec :: Spec
spec = describe "plugin" $ do
  it "should explicitly break recursion in global bindings" $ do
    shouldSucceed $(inspectTest $ 'recursive === 'mutual)
  -- TODO: implementation as Core pass to resolve this
  -- it "should work without signatures" $ do
  --   shouldSucceed $(inspectTest $ 'recursiveNoSig === 'mutual)
  it "should explicitly break recursion in local bindings" $ do
    shouldSucceed $(inspectTest $ 'localRecursive === 'localMutual)

------------------------------------------------------------------------------
recursive :: Int -> Int
recursive 0 = 1
recursive n = n * recursive (n - 1)
{-# INLINE recursive #-}

-- recursiveNoSig 0 = (1 :: Int)
-- recursiveNoSig n = n * recursiveNoSig (n - 1)
-- {-# INLINE recursiveNoSig #-}

mutual :: Int -> Int
mutual 0 = 1
mutual n = n * mutual' (n - 1)
{-# INLINE mutual #-}

mutual' :: Int -> Int
mutual' = mutual
{-# NOINLINE mutual' #-}

localRecursive :: Int -> Int
localRecursive = local where
  local 0 = 1
  local n = n * local (n - 1)
  {-# INLINE local #-}

localMutual :: Int -> Int
localMutual = local where
  local 0 = 1
  local n = n * local' (n - 1)
  {-# INLINE local #-}

  local' = local
  {-# NOINLINE local' #-}
