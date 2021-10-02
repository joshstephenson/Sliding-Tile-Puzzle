//
//  ContentView.swift
//  Shared
//
//  Created by Joshua Stephenson on 9/30/21.
//

import SwiftUI

struct BoardConstants {
    static let tileSize = 50;
    static let boardSize = 3;
}

class BoardModel: ObservableObject {
    public var tiles:[BoardTile]
    
    // Key is the tile face value (number), value is position (index)
    private var tileLookup:[Int:Int]
    public var slotIndex: Int = -1
    public var slot: CGSize
    public var dimension:Int = BoardConstants.boardSize
    
    public var size:CGFloat {
        return CGFloat(dimension) * CGFloat(BoardConstants.tileSize)
    }
    
    init() {
        let count:Int = Int(pow(Double(BoardConstants.boardSize),2)) - 1
        var t:[BoardTile] = []
        var l:[Int:Int] = [:]
        for i in 1...count{
            let tile = BoardTile(number: i, offset: Board.offsetForTile(n: dimension, tile: i))
            t.append(tile)
            l[i] = i
        }
        self.slotIndex = count + 1
        self.slot = Board.offsetForTile(n: dimension, tile: count + 1)
        self.tiles = t
        self.tileLookup = l
    }
    
    func move(tile: BoardTile) -> Int {
        if let idx = tileLookup[tile.number] {
            let old = slotIndex
            tileLookup[tile.number] = slotIndex
            slotIndex = idx
            slot = Board.offsetForTile(n: dimension, tile: slotIndex)
            return old
        }
        return -1
    }
    
    func isSlideable(tile: BoardTile) -> Bool {
        if let tileIndex = tileLookup[tile.number] {
            // slot is in the same row with tile and adjascent
            if ((tileIndex - 1) / dimension == (slotIndex - 1) / dimension) && (abs(tileIndex - slotIndex) == 1) {
                return true
            // slot is in the same column with tile and adjascent
            } else if abs(tileIndex - slotIndex) == dimension {
                return true
            }
//            print("foo: \(((tileIndex - 1) / dimension == (slotIndex - 1) / dimension)), modulo: \(tileIndex % dimension), slot modulo: \(slotIndex % dimension)")
        }
        return false;
    }
}

class BoardTile: NSObject {
    var number: Int
    var origin: CGSize
    
    init(number: Int, offset: CGSize) {
        self.number = number
        self.origin = offset
    }
}

struct BoardTileView: View {
    var board: Board
    var tile: BoardTile
    @State var origin: CGSize
    var body: some View {
        Button("\(tile.number)") {
            if board.model.isSlideable(tile: tile) {
//                let temp = tile.origin
                tile.origin = board.model.slot
                self.origin = tile.origin
//                board.boardModel.slot = temp
                let idx = board.model.move(tile: tile)
//                tile.origin = Board.offsetForTile(n: board.boardModel.dimension, tile: idx)
            }
        }.offset(origin)
        .animation(.spring())
    }
}

struct Board: View {
    public var model: BoardModel
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            ForEach(model.tiles, id: \.self) { tile in
                BoardTileView(board: self, tile: tile, origin: tile.origin)
            }
        }
    }
    
    static func offsetForTile(n: Int, tile: Int) -> CGSize {
        let col = (tile - 1) % n
        let row = (tile - 1) / n
        return CGSize(width: col * BoardConstants.tileSize, height: row * BoardConstants.tileSize)
    }
    
}

struct ContentView: View {
    var boardModel = BoardModel()
    var body: some View {
        Board(model: boardModel).frame(width: boardModel.size, height: boardModel.size, alignment: .topLeading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
