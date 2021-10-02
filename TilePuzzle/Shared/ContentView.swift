//
//  ContentView.swift
//  Shared
//
//  Created by Joshua Stephenson on 9/30/21.
//

import SwiftUI

struct BoardConstants {
    static let tileSize:CGFloat = 70.0
    static let boardSize = 4
    static let spacing:CGFloat = 2.0
}

extension Animation {
    static func slide() -> Animation {
        Animation.easeOut(duration: 0.1)
    }
}

enum InitializationError: Error {
    case noDimensionFound
    case noFileFound
}

enum BoardError: Error {
    case invalidTileIndex
}

class BoardModel: ObservableObject {
    public var tiles:[BoardTile]
    
    // Key is the tile face value (number), value is position (index)
    private var tileLookup:[Int:Int]
    
    // slot is the empty tile
    public var slotIndex: Int = -1
    
    // dimension is the width/height of the puzzle board
    public var dimension:Int
    
    // size is the user inteface size, cumputed based on dimension
    public var size:CGFloat = 0.0
    
    // A measure of how many tiles are out of place
    private var hamming: Int = -1
    
    // Sum of distances between tiles and goal
    private var manhattan: Int = -1
    
    // initialize a board of size dimension in its solved state
    init(dimension: Int) {
        self.dimension = dimension
        self.size = CGFloat(dimension) * BoardConstants.tileSize + CGFloat(dimension - 1) * BoardConstants.spacing
        let count:Int = Int(pow(Double(dimension),2)) - 1
        var t:[BoardTile] = []
        var l:[Int:Int] = [:]
        for i in 1...count{
            let tile = BoardTile(number: i)
            t.append(tile)
            l[i] = i
        }
        self.slotIndex = count + 1
        self.tiles = t
        self.tileLookup = l
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
            if char == "" {
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
        var l:[Int:Int] = [:]
        
        for i in 1...numbers.count{
            let number = numbers[i-1]
            if number == 0 {
                self.slotIndex = i
            }else{
                let tile = BoardTile(number: number)
                t.append(tile)
                l[number] = i
            }
        }
        self.tiles = t
        self.tileLookup = l
        processTiles()
        print("Hamming: \(hamming), Manhattan: \(manhattan)")
    }
    
    func indexForTile(tile: BoardTile) -> Int {
        return tileLookup[tile.number]!
    }
    
    func move(tile: BoardTile, block: (CGSize) -> Void) {
        if isSlideable(tile: tile) {
            if let idx = tileLookup[tile.number] {
                let oldSlot = Board.offsetForTile(n: dimension, positionIndex: slotIndex)
                
                // tile's index becomes the slot's index
                tileLookup[tile.number] = slotIndex
                
                // New slot index becomes the tile's index
                slotIndex = idx
                
                // Let the view update itself
                block(oldSlot)
            }
        }
    }
    
    // We should only be able to slide tiles adjascent to empty slot
    private func isSlideable(tile: BoardTile) -> Bool {
        if let tileIndex = tileLookup[tile.number] {
            // slot is in the same row with tile and adjascent
            if ((tileIndex - 1) / dimension == (slotIndex - 1) / dimension) && (abs(tileIndex - slotIndex) == 1) {
                return true
            // slot is in the same column with tile and adjascent
            } else if abs(tileIndex - slotIndex) == dimension {
                return true
            }
        }
        return false;
    }
    
    private func processTiles() {
        var hamming = 0
        var manhattan = 0
        for tile in tiles {
            if let manh = try? manhattanForTile(tile: tile) {
                if manh > 0 {
                    hamming += 1
                }
                manhattan += manh
            }
        }
        self.hamming = hamming
        self.manhattan = manhattan
    }
    
    private func manhattanForTile(tile: BoardTile) throws -> Int {
        guard let index = tileLookup[tile.number] else {
            throw BoardError.invalidTileIndex
        }
        let col = (index - 1) % dimension
        let row = (index - 1) / dimension
        
        let value = tile.number - 1
        var finalCol = value % dimension
        var finalRow:Int
        if (finalCol == 0) {
            finalRow = value / dimension;
            finalCol = dimension;
        } else {
            finalRow = (value / dimension) + 1;
        }
        let manhattan = abs(finalRow - row) + abs(finalCol - col)
        return manhattan
    }
}

class BoardTile: NSObject {
    var number: Int
    
    init(number: Int) {
        self.number = number
    }
}

struct InnerTile: View {
    var number: Int
    var body: some View {
        Text("\(number)")
            .font(.largeTitle)
            .frame(width: CGFloat(BoardConstants.tileSize), height: CGFloat(BoardConstants.tileSize), alignment: .center)
            .background(Color("Tile"))
            .cornerRadius(5.0)
    }
}

struct BoardTileView: View {
    var board: Board
    var tile: BoardTile
    @State var origin: CGSize
    var body: some View {
        InnerTile(number: tile.number)
            .offset(origin)
            .onTapGesture {
                board.model.move(tile: tile) { origin in
                    self.origin = origin
                }
            }
            .animation(.slide())
    }
}

struct Board: View {
    public var model: BoardModel
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            ForEach(model.tiles, id: \.self) { tile in
                BoardTileView(board: self, tile: tile, origin: Board.offsetForTile(n: model.dimension, positionIndex: model.indexForTile(tile: tile)))
                    .background(Color.clear)
            }
        }
    }
    
    static func offsetForTile(n: Int, positionIndex: Int) -> CGSize {
        let col = CGFloat((positionIndex - 1) % n)
        let row = CGFloat((positionIndex - 1) / n)
        return CGSize(width: col * BoardConstants.tileSize + (col - 1) * BoardConstants.spacing,
                      height: row * BoardConstants.tileSize + (row - 1) * BoardConstants.spacing)
    }
    
}

struct ContentView: View {
    var boardModel = try? BoardModel(filename: "3x3-01.txt")
    var body: some View {
        Board(model: boardModel!).frame(width: boardModel!.size, height: boardModel!.size, alignment: .topLeading)
            .background(Color("Board"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
