//
//  BoardModel.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import Foundation

class Board: ObservableObject, Equatable, CustomStringConvertible {
    static func == (lhs: Board, rhs: Board) -> Bool {
        return lhs.dimension == rhs.dimension
            && lhs.slotPosition == rhs.slotPosition
            && lhs.manhattan == rhs.manhattan
    }
    
    
    public var tiles:[Tile] = []
    
    // slot is the empty tile
    public var slotPosition: Int = -1
    
    // dimension is the width/height of the puzzle board
    public var dimension:Int
    
    // is Solved?
    public var isSolved:Bool {
        return hamming == 0
    }
    
    @Published var progress: Double = 1.0
    
    // A measure of how many tiles are out of place
    private var hamming: Int = -1
    
    // Sum of distances between tiles and goal
    public var manhattan: Int = -1 {
        didSet {
            let maxManhattan = Double(tiles.count)
            self.progress = hamming == 0 ? 1.0 : 1 - (Double(manhattan) / maxManhattan)
        }
    }
    
    private var tileLookup:[Int:Tile] = [:]
    
    public var description: String {
        var string = ""
        var count = 0
        var l:[Int:Int] = [:]
        for tile in tiles {
            l[tile.position] = tile.number
        }
        for i in 1...tiles.count+1 {
            if slotPosition == i {
                string.append(("0 "))
            }else if let number = l[i]{
                string.append("\(number) ")
            }
            count += 1
            if count == dimension {
                string.append("\n")
                count = 0
            }
        }
        return string
    }
    
    // initialize a board of size dimension in its solved state
    init(dimension: Int) {
        self.dimension = dimension
        let count:Int = Int(pow(Double(dimension),2)) - 1
        var t:[Tile] = []
        var l:[Int:Tile] = [:]
        for i in 1...count{
            let tile = Tile(dimension: dimension, number: i, position: i)
            t.append(tile)
            l[i] = tile
        }
        self.slotPosition = count + 1
        self.tiles = t
        self.tileLookup = l
        processTiles()
    }
    
    init(dimension: Int, tiles: [Tile], slotPosition: Int) {
        self.slotPosition = slotPosition
        self.dimension = dimension
        var t:[Tile] = []
        var l:[Int:Tile] = [:]
        for tile in tiles{
            // need to duplicate the tiles to not collide with other boards
            let newTile = Tile(dimension: dimension, number: tile.number, position: tile.position)
            l[newTile.position] = newTile
            t.append(newTile)
        }
        self.tiles = t
        self.tileLookup = l
        processTiles()
    }
   
    
    // Initialize from a txt file
    convenience init(filename: String) throws {
        guard let file = Bundle.main.path(forResource: filename, ofType: nil) else {
            throw InitializationError.noFileFound
        }
        let contents = try String(contentsOf: URL(fileURLWithPath: file))
        try self.init(contents: contents)
    }
    
    // For Testing
    // Initialize from a string of contenst
    init(contents: String) throws {
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
        assert(numbers.count == dim*dim)
        self.dimension = dim
        
        var t:[Tile] = []
        var l:[Int:Tile] = [:]
        for i in 1...numbers.count{
            let number = numbers[i-1]
            if number == 0 {
                self.slotPosition = i
            }else{
                let tile = Tile(dimension: dimension, number: number, position: i)
                t.append(tile)
                l[i] = tile
            }
        }
        self.tiles = t
        self.tileLookup = l
        processTiles()
    }
    
    func move(position: Int, block: ((Int, Bool) -> Void)? = nil) {
        if let tile = tileLookup[position], isSlideable(tile: tile) {
            let oldPosition     = tile.position
            let oldManhattan    = tile.manhattan
            let oldSlot         = slotPosition
            
            // tile's position becomes the slot's
            tile.position = slotPosition
            
            // Update manhattan and hamming so we know when the puzzle is solved
            manhattan -= (oldManhattan - tile.manhattan)
            if tile.manhattan == 0 && oldManhattan > 0 {
                hamming -= 1
            } else if tile.manhattan > 0 && oldManhattan == 0 {
                hamming += 1
            }
            
            // New slot index becomes the tile's index
            slotPosition = oldPosition
            
            // Update the lookup so we can find nearby tiles
            tileLookup.removeValue(forKey: slotPosition)
            tileLookup[tile.position] = tile

            // Let the view update itself
            if let block = block {
                block(oldSlot, isSolved)
            }
        }
    }
    
    // A neighbor is a board in the current state, but with one tile slid into empty slot
    // There are always at least 2 neighbors and as many as 4
    func neighbors() -> [Board] {
        assert(slotPosition > 0)
        var boards:[Board] = []
        
        let hasLeft     = slotPosition % dimension != 1
        let hasRight    = slotPosition % dimension != 0
        let hasAbove    = slotPosition > dimension
        let hasBelow    = slotPosition <= dimension * (dimension - 1)
        
        if (hasLeft) {
            boards.append(duplicateAfterSliding(slotPosition - 1))
        }
        if (hasRight) {
            boards.append(duplicateAfterSliding(slotPosition + 1))
        }
        if (hasAbove) {
            boards.append(duplicateAfterSliding(slotPosition - dimension))
        }
        if (hasBelow) {
            boards.append(duplicateAfterSliding(slotPosition + dimension))
        }
        assert(boards.count > 0)
        return boards
    }
    
    // swap any two tiles (non-slot tiles)
    // Only a board OR its twin is solvable, not both
    func twin() -> Board {
        var swap:[Tile] = []
        
        // deepcopy
        for tile in tiles {
            swap.append(Tile(dimension: tile.dimension, number: tile.number, position: tile.position))
        }
        let swapFrom:Tile = swap.first!
        let swapTo:Tile = swap[dimension]
        let oldPosition = swapFrom.position
        swapFrom.position = swapTo.position
        swapTo.position = oldPosition
        swap.swapAt(0, dimension-1)
        return Board(dimension: dimension, tiles: swap, slotPosition: slotPosition)
    }
    
    func duplicateAfterSliding(_ position: Int) -> Board {
        return duplicateAfterSliding(tileLookup[position]!)
    }
    
    private func duplicateAfterSliding(_ tile: Tile) -> Board {
        let b = Board(dimension: dimension, tiles: tiles, slotPosition: slotPosition)
        b.move(position: tile.position, block: nil)
        return b
    }
    
    // We should only be able to slide tiles adjascent to empty slot
    private func isSlideable(tile: Tile) -> Bool {
        // slot is in the same row with tile and the adjascent
        if ((tile.position - 1) / dimension == (slotPosition - 1) / dimension) && (abs(tile.position - slotPosition) == 1) {
            return true
        // slot is in the same column with tile and they are adjascent
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
    
    
    class Tile: NSObject {
        var dimension: Int
        var number: Int
        var col: Int = -1
        var row: Int = -1
        var manhattan: Int = -1
        var position: Int {
            didSet {
                updateCalculatedAttributes()
            }
        }
        public override var description: String {
            return "<Tile number: \(number), position: \(position)>"
        }
        
        init(dimension: Int, number: Int, position: Int) {
            self.dimension = dimension
            self.number = number
            self.position = position
            super.init()
            updateCalculatedAttributes()
        }
        
        private func updateCalculatedAttributes() {
            self.col = (position - 1) % dimension + 1
            self.row = (position - 1) / dimension + 1
            self.manhattan = calculateManhattan()
        }
        
        private func calculateManhattan() -> Int {
            var finalCol = number % dimension
            var finalRow:Int
            if (finalCol == 0) {
                finalRow = number / dimension;
                finalCol = dimension;
            } else {
                finalRow = (number / dimension) + 1;
            }
            let manhattan = abs(finalRow - row) + abs(finalCol - col)
    //        print("\(number), row: \(row), col: \(col), finalRow: \(finalRow), finalCol: \(finalCol), manh: \(manhattan)")
            return manhattan
        }
    }

}
