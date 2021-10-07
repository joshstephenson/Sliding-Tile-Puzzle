# Sliding Tile Puzzle 

![recording4](https://user-images.githubusercontent.com/11002/136454277-1760eaab-6a1a-43d8-8089-6d40456fe43e.gif)

## About

This is by no means an original project, but it was an excuse to learn SwiftUI a bit more, as well as an excuse to build a binary heap and priority queue, which I hadn't done before. Building a binary heap is probably not a great idea for a production worthy app, as you could most likely find one, but it is a very simple data structure when backed by an array (See [MinimumPriorityQueue.swift](https://github.com/joshstephenson/Sliding-Tile-Puzzle/blob/main/TilePuzzle/Shared/MinimumPriorityQueue.swift.)) Priority Queues are a common data structure for solving games where efficiency of moves is important. In the case of a sliding tile puzzle, it can be solved with many sets of moves, but using a minimum priority queue ensures you identify the set of fewest moves in order to solve.

## This project can:

1. Create a sliding tile board of any dimension (see `ContentView.swift` and `Board.swift`)
2. Load a sliding tile layout from a text file (see `ContentView.swift` and `Board.swift`)
3. Randomize the board so that at least x% of tiles are out of place. In this case that is 80% but it can be changed in `BoardConstants.swift`.
4. Solve any solvable board and determine if a board is solvable (see `Solver.checkIfSolvable`).

## Automatic Solving via A* Algorithm

Automatic solver via A* ("A star") algorithm, implemented in [Solver.swift](https://github.com/joshstephenson/Sliding-Tile-Puzzle/blob/main/TilePuzzle/Shared/Solver.swift) leveraging [MinimumPriorityQueue.swift](https://github.com/joshstephenson/Sliding-Tile-Puzzle/blob/main/TilePuzzle/Shared/MinimumPriorityQueue.swift.). 


## About the binary heap
The binary heap is a simple array where a child is always at `2 * i + 1` and a parent is always at `(i - 1) / 2`. It is a minimum priority queue which means the first element is always the smallest. When a new item is inserted, it is placed at the end of the array and it _swims up_ to its proper position (see `swim()` funnction). When a minimum item is removed, then the item from the end of the array (lowest priority) is put in its placed and it _sinks down_ to its proper position (see `sink()` function). In this case the items put into the priority queue are `SearchNode` objects which store a reference to a board,  total number of moves to get to that board state, and the last move to get to that state. Each board represents an optional move. Search nodes have a priority (that is minimized in the queue) which is an aggregate of the number of moves taken to get there from the original board state and the board's manhattan value.

A single tile's manhattan value is the number of positions it is away from it's final position, and a board's manhattan value is the sum of manhattan values for each tile. Therefore the priority of the search node is a combination of how far this board is away from its end state and how many moves have been made so far. By putting these in a minimum priority queue we are ensuring we get the solution with the minimum number of moves, as opposed to a maximum priority queue which would give us the slowest possible solution (which would be infinite).

## There are tests for:

1. The priority queue, ensuring sinking and swimming of values works properly.
2. Board functions that twin a board (for solvability check), finding possibly moves and duplicating boards after potential moves.
3. Solver with various board states.
