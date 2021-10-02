//
//  ContentView.swift
//  Shared
//
//  Created by Joshua Stephenson on 9/30/21.
//

import SwiftUI

struct BoardConstants {
    static let tileSize:CGFloat = 70.0
    static let boardSize = 3
    static let spacing:CGFloat = 2.0
}

extension Animation {
    static func slide() -> Animation {
        Animation.easeOut(duration: 0.1)
    }
}

class BoardModel: ObservableObject {
    public var tiles:[BoardTile]
    
    // Key is the tile face value (number), value is position (index)
    private var tileLookup:[Int:Int]
    public var slotIndex: Int = -1
    public var dimension:Int = BoardConstants.boardSize
    
    public var size:CGFloat {
        return CGFloat(dimension) * BoardConstants.tileSize + CGFloat(dimension - 1) * BoardConstants.spacing
    }
    
    init() {
        let count:Int = Int(pow(Double(BoardConstants.boardSize),2)) - 1
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
    }
    
    func move(tile: BoardTile, block: (CGSize) -> Void) {
        print("\(tile.number) -> \(tileLookup[tile.number])")
        if isSlideable(tile: tile) {
            if let idx = tileLookup[tile.number] {
                let oldSlot = Board.offsetForTile(n: dimension, tile: slotIndex)
                
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
                BoardTileView(board: self, tile: tile, origin: Board.offsetForTile(n: model.dimension, tile: tile.number))
                    .background(Color.clear)
            }
        }
    }
    
    static func offsetForTile(n: Int, tile: Int) -> CGSize {
        let col = CGFloat((tile - 1) % n)
        let row = CGFloat((tile - 1) / n)
        return CGSize(width: col * BoardConstants.tileSize + (col - 1) * BoardConstants.spacing,
                      height: row * BoardConstants.tileSize + (row - 1) * BoardConstants.spacing)
    }
    
}

struct ContentView: View {
    var boardModel = BoardModel()
    var body: some View {
        Board(model: boardModel).frame(width: boardModel.size, height: boardModel.size, alignment: .topLeading)
            .background(Color("Board"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
