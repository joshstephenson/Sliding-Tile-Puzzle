//
//  ContentView.swift
//  Shared
//
//  Created by Joshua Stephenson on 9/30/21.
//

import SwiftUI

//public extension View {
//    func offset(x: CGFloat, y: CGFloat) -> some View {
//        return modifier(_OffsetEffect(offset: CGSize(width: x, height: y)))
//    }
//
//    func offset(_ offset: CGSize) -> some View {
//        return modifier(_OffsetEffect(offset: offset))
//    }
//}
//
//struct _OffsetEffect: GeometryEffect {
//    var offset: CGSize
//
//    var animatableData: CGSize.AnimatableData {
//        get { CGSize.AnimatableData(offset.width, offset.height) }
//        set { offset = CGSize(width: newValue.first, height: newValue.second) }
//    }
//
//    public func effectValue(size: CGSize) -> ProjectionTransform {
//        return ProjectionTransform(CGAffineTransform(translationX: offset.width, y: offset.height))
//    }
//}

struct BoardConstants {
    static let tileSize = 50;
    static let boardSize = 3;
}

class BoardModel: ObservableObject {
    public var tiles:[BoardTile]
    public var slot: CGSize
    public var n:Int = BoardConstants.boardSize
    
    public var size:CGFloat {
        return CGFloat(n) * CGFloat(BoardConstants.tileSize)
    }
    
    init() {
        let count:Int = Int(pow(Double(BoardConstants.boardSize),2)) - 1
        var t:[BoardTile] = []
        for i in 1...count{
            let tile = BoardTile(number: i, offset: Board.offsetForTile(n: n, tile: i))
            t.append(tile)
        }
        self.slot = Board.offsetForTile(n: n, tile: count + 1)
        self.tiles = t
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
            let temp = tile.origin
            tile.origin = board.boardModel.slot
            self.origin = tile.origin
            board.boardModel.slot = temp
        }.offset(origin)
        .animation(.spring())
    }
}

struct Board: View {
    public var boardModel: BoardModel
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            ForEach(boardModel.tiles, id: \.self) { tile in
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
        Board(boardModel: boardModel).frame(width: boardModel.size, height: boardModel.size, alignment: .topLeading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
