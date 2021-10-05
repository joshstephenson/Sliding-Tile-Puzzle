# Sliding Tile Puzzle 

![Recording](https://user-images.githubusercontent.com/11002/135719524-02adc24c-6c98-4864-aed9-42e45038353f.gif)

## About

This is a basic sliding tize puzzle implemented in Swift and SwiftUI.

## Automatic Solving via A* Algorithm

Automatic solver via A* algorithm, implemented in `Solver.swift` and `MinimumProrityQueue.swift`. I've implemented a binary heap minimum priority queue in order to solve the puzzle. The binary heap is a simple array data structure where a child is always at `2 * i + 1` and a parent is always at `(i - 1) / 2`. It is a minimum priority queue which means the first element is always the smallest. In this case the items put into the priority queue are `SearchNode` objects which store a reference to a board. A board represents an optional move. Search nodes have a priority (what is minimized in the queue) which is an aggregate of the number of moves taken to get there from the original board state and the board's manhattan value. 

A single tile's manhattan value is the number of positions it is away from it's final position, and a board's manhattan value is the sum of those values. Therefore the priority of the search node is a combination of how far this board is away from its end state and how many moves we've made so far. By putting these in a minimum priority queue we are ensuring we get the fastest possible solution, as opposed to a maximum priority queue which would give us the slowest possible solution (which would be infinite).
