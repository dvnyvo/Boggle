module Boggle (boggle) where

import Data.List (nubBy)
import Data.Function (on)

type Board = [String]
type Position = (Int, Int)

boggle :: Board -> [String] -> [(String, [Position])]
boggle board words = nubBy ((==) `on` fst) $ concatMap (\word -> searchWord board word) words

searchWord :: Board -> String -> [(String, [Position])]
searchWord board word = 
    let matchingStartCells = filter (\(x, y) -> board !! x !! y == head word) (getAllCellsInBoard board)
    in concatMap (\cell -> dfs cell [] word word board) matchingStartCells

dfs :: Position -> [Position] -> String -> String -> Board -> [(String, [Position])]
dfs (x, y) visited originalWord currentWord board 
    | x < 0 || y < 0 || x >= numRows || y >= numCols || (x, y) `elem` visited = [] 
    | length currentWord == 1 && head currentWord == board !! x !! y = [(originalWord, reverse (currentPos : visited))] 
    | null currentWord = [(originalWord, reverse (currentPos : visited))] 
    | head currentWord /= board !! x !! y = [] 
    | otherwise = concatMap explore neighbors 
    where
        numRows = length board
        numCols = length (head board)
        currentPos = (x, y)
        neighbors = [(x + dx, y + dy) | dx <- [-1, 0, 1], dy <- [-1, 0, 1], not (dx == 0 && dy == 0)]
        explore (nx, ny) = dfs (nx, ny) (currentPos : visited) originalWord (tail currentWord) board

getAllCellsInBoard :: Board -> [Position] 
getAllCellsInBoard board = [(x, y) | x <- [0 .. numRows - 1], y <- [0 .. numCols - 1]] 
    where
        numRows = length board
        numCols = length (head board)
