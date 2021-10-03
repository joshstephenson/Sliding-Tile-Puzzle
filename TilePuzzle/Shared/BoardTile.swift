//
//  BoardTile.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import Foundation

class BoardTile: NSObject {
    var board: BoardModel
    var number: Int
    var col: Int = -1
    var row: Int = -1
    var manhattan: Int = -1
    var position: Int {
        didSet {
            updateCalculatedAttributes()
        }
    }
    
    init(board: BoardModel, number: Int, position: Int) {
        self.board = board
        self.number = number
        self.position = position
        super.init()
        updateCalculatedAttributes()
    }
    
    private func updateCalculatedAttributes() {
        self.col = (position - 1) % board.dimension + 1
        self.row = (position - 1) / board.dimension + 1
        self.manhattan = calculateManhattan()
    }
    
    private func calculateManhattan() -> Int {
        var finalCol = number % board.dimension
        var finalRow:Int
        if (finalCol == 0) {
            finalRow = number / board.dimension;
            finalCol = board.dimension;
        } else {
            finalRow = (number / board.dimension) + 1;
        }
        let manhattan = abs(finalRow - row) + abs(finalCol - col)
//        print("\(number), row: \(row), col: \(col), finalRow: \(finalRow), finalCol: \(finalCol), manh: \(manhattan)")
        return manhattan
    }
}

