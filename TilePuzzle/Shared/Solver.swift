//
//  Solver.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import Foundation

class SearchNode: Comparable, Equatable, CustomStringConvertible {
    static func == (lhs: SearchNode, rhs: SearchNode) -> Bool {
        return lhs.priority == rhs.priority && lhs.manhattan == rhs.manhattan
    }
    
    static func < (lhs: SearchNode, rhs: SearchNode) -> Bool {
        if lhs.priority == rhs.priority {
            return lhs.manhattan < rhs.manhattan
        }
        return lhs.priority < rhs.priority
    }
    
    public var description: String {
        return "SearchNode: solved: \(isSolved) priority: \(priority), manhattan: \(manhattan), moves: \(moves), previous: \(previous == nil)"
    }
    
    internal var board: Board
    internal var moves: Int
    internal var previous: SearchNode?
    private var priority:Int
    private var manhattan:Int
    public var isSolved:Bool {
        return board.isSolved
    }
    
    init(board: Board, moves: Int, previous: SearchNode?) {
        self.board = board
        self.moves = moves
        self.previous = previous
        self.manhattan = board.manhattan
        self.priority = manhattan + moves; // decreasing priority by number of moves
    }
}

struct Solver {
    private var boards:[Board] = []
    private var isSolvable = false
    
    init(_ initial: Board) {
        var pq = MinimumPriorityQueue<SearchNode>()
        // TwinPQ is used to determine if a board can be solved
        // If a twin board can be solved then the initial (non-twin) cannot be
        var twinPQ = MinimumPriorityQueue<SearchNode>()
        
        pq.insert(SearchNode(board: initial, moves: 0, previous: nil))
        twinPQ.insert(SearchNode(board: initial.twin(), moves: 0, previous: nil))

        while((!pq.isEmpty() && !pq.min()!.isSolved) && (!twinPQ.isEmpty() && !twinPQ.min()!.isSolved)) {
            if let node = pq.delMin() {
                for neighbor in node.board.neighbors() {
                    // we need to ignore neighbors that are the previous layout
                    if node.previous == nil || neighbor != node.previous!.board {
                        let newNode = SearchNode(board: neighbor, moves: node.moves + 1, previous: node)
                        pq.insert(newNode)
                    }
                }
            }
            
            // Now do the same for the twin PQ
            if let node = twinPQ.delMin() {
                for neighbor in node.board.neighbors() {
                    if node.previous == nil || neighbor != node.previous!.board {
                        let newNode = SearchNode(board: neighbor, moves: node.moves + 1, previous: node)
                        twinPQ.insert(newNode)
                    }
                }
            }
        }
        
        if let node = pq.delMin() {
            print(node)
            // if this node isn't solved, then it means the twin was, in which case this is unsolvable
            if node.isSolved {
                // Now that we know it's solved, build the stack of boards representing
                // the steps to solve
                var goalNode = node
                self.boards = []
                isSolvable = true
                while (goalNode.previous != nil) {
                    let previous = goalNode.previous!
                    boards.append(goalNode.board)
                    goalNode = previous
                }
                boards.append(initial)
            }else {
                print("board not solvable")
            }
        } else {
            print("empty PQ")
        }
    }
    
    public func solution() -> [Board] {
        return boards
    }
    
    public func moves() -> Int {
        if isSolvable {
            return boards.count - 1
        }else {
            return -1
        }
    }
}