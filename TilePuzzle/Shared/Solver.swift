//
//  Solver.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import Foundation

struct Solver {
    private var board: BoardModel
    
    init(_ board: BoardModel) {
        self.board = board
    }
    
    public func moves() -> Int {
        return -1
    }
}
