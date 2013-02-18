{-# LANGUAGE ScopedTypeVariables, TypeSynonymInstances, FlexibleInstances #-}

module KMeansHelper where

import Data.List (sort, span, minimumBy)
import Data.Function (on)
import Data.Ord (comparing)
import Language.Haskell.Liquid.Prelude (liquidAssert, liquidError)


-- | Fixed-Length Lists

{-@ type List a N = {v : [a] | (len v) = N} @-}


-- | N Dimensional Points

{-@ type Point N = List Double N @-}

{-@ type NonEmptyList a = {v : [a] | (len v) > 0} @-}

-- | Clustering 

{-@ type Clustering a  = [(NonEmptyList a)] @-}

------------------------------------------------------------------
-- | Grouping By a Predicate -------------------------------------
------------------------------------------------------------------

{-@ groupBy       :: (a -> a -> Bool) -> [a] -> (Clustering a) @-}
groupBy _  []     =  []
groupBy eq (x:xs) =  (x:ys) : groupBy eq zs
  where (ys,zs)   = span (eq x) xs

------------------------------------------------------------------
-- | Partitioning By a Size --------------------------------------
------------------------------------------------------------------

{-@ type PosInt = {v: Int | v > 0 } @-}

{-@ partition           :: size:PosInt -> [a] -> (Clustering a) @-}

partition size []       = []
partition size ys@(_:_) = zs : partition size zs'
  where
    zs                  = take size ys
    zs'                 = drop size ys

-----------------------------------------------------------------------
-- | Safe Zipping -----------------------------------------------------
-----------------------------------------------------------------------

{-@ safeZipWith :: (a -> b -> c)
                -> xs:[a]
                -> (List b (len xs))
                -> (List c (len xs))
  @-}

safeZipWith f (a:as) (b:bs) = f a b : safeZipWith f as bs
safeZipWith _ [] []         = []

-- Other cases only for exposition
safeZipWith _ (_:_) []      = liquidError "Dead Code"
safeZipWith _ [] (_:_)      = liquidError "Dead Code"


-----------------------------------------------------------------------
-- | "Matrix" Transposition -------------------------------------------
-----------------------------------------------------------------------

{-@ type Matrix a Rows Cols  = (List (List a Cols) Rows) @-}

{-@ transpose                :: c:Int -> r:PosInt -> Matrix a r c -> Matrix a c r @-}

transpose                    :: Int -> Int -> [[a]] -> [[a]]
transpose 0 _ _              = []
transpose c r ((x:xs) : xss) = (x : map head xss) : transpose (c-1) r (xs : map tail xss)

-- Not needed, just for exposition
transpose c r ([] : _)       = liquidError "dead code"
transpose c r []             = liquidError "dead code"
