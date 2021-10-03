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
    
    func move(tile: BoardTile, block: (CGSize, Bool) -> Void) {
        if isSlideable(tile: tile) {
            let oldPosition = tile.position
            let oldSlot = Board.offsetForPosition(n: dimension, position: slotPosition)
            let oldManhattan = tile.manhattan
            
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
                board.model.move(tile: tile) { origin, solved in
                    self.origin = origin
                    if(solved) {
                        print("SOLVED!")
                    }
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
                BoardTileView(board: self, tile: tile, origin: Board.offsetForPosition(n: model.dimension, position: tile.position))
                    .background(Color.clear)
            }
        }
    }
    
    static func offsetForPosition(n: Int, position: Int) -> CGSize {
        let col = CGFloat((position - 1) % n)
        let row = CGFloat((position - 1) / n)
        return CGSize(width: col * BoardConstants.tileSize + (col - 1) * BoardConstants.spacing,
                      height: row * BoardConstants.tileSize + (row - 1) * BoardConstants.spacing)
    }
    
}

struct ContentView: View {
    var boardModel = try? BoardModel(filename: "3x3-01.txt")
    var body: some View {
        VStack(alignment: .center, spacing: 5.0) {
//            Rectangle()
//                .frame(maxWidth: .infinity)
//                .frame(height: 20.0)
//                .background(Color.clear)
            Board(model: boardModel!).frame(width: boardModel!.size, height: boardModel!.size, alignment: .topLeading)
                .background(Color("Board"))
        }
    }
    
//    private func progressColor(_ progress: Double) -> Color {
//        print(progress)
//        return Color(hue: 0.9, saturation: progress, brightness: 1.0)
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
