# Sliding Tile Puzzle 

![Recording2](https://user-images.githubusercontent.com/11002/136385768-ae6d067e-a075-4686-b5ee-787e6c2311bb.gif)


## About

This is a basic sliding tize puzzle implemented in Swift and SwiftUI.

## Automatic Solving via A* Algorithm

Automatic solver via A* algorithm, implemented in `Solver.swift` leveraging `MinimumProrityQueue.swift`. Using a binary heap minimum priority queue data structure in order to solve the puzzle. The binary heap is a simple array where a child is always at `2 * i + 1` and a parent is always at `(i - 1) / 2`. It is a minimum priority queue which means the first element is always the smallest. In this case the items put into the priority queue are `SearchNode` objects which store a reference to a board, maintain a total number of moves to get to that board state and the last moved tile (in order to animate solving once solved). Each board represents an optional move. Search nodes have a priority (that is minimized in the queue) which is an aggregate of the number of moves taken to get there from the original board state and the board's manhattan value.

A single tile's manhattan value is the number of positions it is away from it's final position, and a board's manhattan value is the sum of manhattan values for each tile. Therefore the priority of the search node is a combination of how far this board is away from its end state and how many moves we've made so far. By putting these in a minimum priority queue we are ensuring we get the solution with the minimum number of moves, as opposed to a maximum priority queue which would give us the slowest possible solution (which would be infinite).

### This code can:

1. Create a sliding tile board of any dimension
2. Load a sliding tile layout from a text file (see `ContentView.swift` and `Board.swift`)
3. Randomize the board so that at least x% of tiles are out of place. In this case that is 80% but it can be changed in `BoardConstants.swift`.
4. Solve any solvable board and determine if a board is solvable (see `Solver.checkIfSolvable`).

### There are tests for:

1. The priority queue, ensuring sinking and swimming of values works properly.
2. Board functions that twin a board (for solvability check), finding possibly moves and duplicating boards after potential moves.
3. Solver with various board states.
