//
//  BoardModel.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import Foundation

class BoardModel: ObservableObject {
    public var tiles:[BoardTile] = []
    
    // slot is the empty tile
    public var slotPosition: Int = -1
    
    // dimension is the width/height of the puzzle board
    public var dimension:Int
    
    // size is the user inteface size, cumputed based on dimension
    public var size:CGFloat = 0.0
    
    // is Solved?
    public var isSolved:Bool {
        return manhattan == 0
    }
    
    @Published var progress: Double = 1.0
    
    // A measure of how many tiles are out of place
    private var hamming: Int = -1
    
    // Sum of distances between tiles and goal
    private var manhattan: Int = -1 {
        didSet {
            let maxManhattan = Double(tiles.count)
            self.progress = hamming == 0 ? 1.0 : 1 - (Double(manhattan) / maxManhattan)
        }
    }
    
    // initialize a board of size dimension in its solved state
    init(dimension: Int) {
        self.dimension = dimension
        self.size = CGFloat(dimension) * BoardConstants.tileSize + CGFloat(dimension - 1) * BoardConstants.spacing
        let count:Int = Int(pow(Double(dimension),2)) - 1
        var t:[BoardTile] = []
        var l:[Int:Int] = [:]
        for i in 1...count{
            let tile = BoardTile(board: self, number: i, position: i)
            t.append(tile)
            l[i] = i
        }
        self.slotPosition = count + 1
        self.tiles = t
        processTiles()
    }
    
    // Initialize from a txt file
    init(filename: String) throws {
        guard let file = Bundle.main.path(forResource: filename, ofType: nil) else {
            throw InitializationError.noFileFound
        }
        let contents = try String(contentsOf: URL(fileURLWithPath: file))
        let lines = contents.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        var numbers:[Int] = lines.compactMap { char in
            if char.isEmpty {
                return nil
            }
            return Int(char)
        }
        guard let dim = numbers.first else {
            throw InitializationError.noDimensionFound
        }
        numbers.removeFirst()
        
        self.dimension = dim
        
        self.size = CGFloat(dimension) * BoardConstants.tileSize + CGFloat(dimension - 1) * BoardConstants.spacing
        print("Dimension: \(self.dimension) -- Tiles: \(numbers)")
        var t:[BoardTile] = []
        
        for i in 1...numbers.count{
            let number = numbers[i-1]
            if number == 0 {
                self.slotPosition = i
            }else{
                let tile = BoardTile(board: self, number: number, position: i)
                t.append(tile)
            }
        }
        self.tiles = t
        processTiles()
    }
    
    func move(tile: BoardTile, block: (Int, Bool) -> Void) {
        if isSlideable(tile: tile) {
            let oldPosition     = tile.position
            let oldManhattan    = tile.manhattan
            let oldSlot         = slotPosition
            
            // tile's position becomes the slot's
            tile.position = slotPosition
            
            // Update manhattan so we know when the puzzle is solved
            manhattan -= (oldManhattan - tile.manhattan)
            
            // New slot index becomes the tile's index
            slotPosition = oldPosition

            // Let the view update itself
            block(oldSlot, isSolved)
        }
    }
    
    // We should only be able to slide tiles adjascent to empty slot
    private func isSlideable(tile: BoardTile) -> Bool {
        // slot is in the same row with tile and adjascent
        if ((tile.position - 1) / dimension == (slotPosition - 1) / dimension) && (abs(tile.position - slotPosition) == 1) {
            return true
        // slot is in the same column with tile and adjascent
        } else if abs(tile.position - slotPosition) == dimension {
            return true
        }
        return false;
    }
    
    // Calculate our initial hamming and manhattan
    private func processTiles() {
        var hamming = 0
        var manhattan = 0
        for tile in tiles {
            if tile.manhattan > 0 {
                hamming += 1
                manhattan += tile.manhattan
            }
        }
        self.hamming = hamming
        self.manhattan = manhattan
    }
    
}
