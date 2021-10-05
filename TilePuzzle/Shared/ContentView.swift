//
//  ContentView.swift
//  Shared
//
//  Created by Joshua Stephenson on 9/30/21.
//

import SwiftUI

extension Animation {
    static func slide() -> Animation {
        Animation.easeOut(duration: 0.1)
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
    var board: BoardView
    var tile: Board.Tile
    @State var origin: CGSize
    var body: some View {
        InnerTile(number: tile.number)
            .offset(origin)
            .onTapGesture {
                board.model.move(tile: tile) { position, solved in
                    self.origin = BoardView.offsetForPosition(n: board.model.dimension, position: position)
                    if(solved) {
                        print("SOLVED!")
                    }
                }
            }
            .animation(.slide())
    }
}

struct BoardView: View {
    public var model: Board
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            ForEach(model.tiles, id: \.self) { tile in
                BoardTileView(board: self, tile: tile, origin: BoardView.offsetForPosition(n: model.dimension, position: tile.position))
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
    var boardModel = try? Board(filename: "3x3-01.txt")
    @State var solveIt = true
    var body: some View {
       
        VStack(alignment: .center, spacing: 5.0) {
            Button("Solve") {
                let solver = Solver(boardModel!)
                print("moves: \(solver.moves())")
            }
            
//            Rectangle()
//                .frame(maxWidth: .infinity)
//                .frame(height: 20.0)
//                .background(Color.clear)
            BoardView(model: boardModel!).frame(width: CGFloat(boardModel!.dimension) * BoardConstants.tileSize + CGFloat(boardModel!.dimension - 1) * BoardConstants.spacing, height: CGFloat(boardModel!.dimension) * BoardConstants.tileSize + CGFloat(boardModel!.dimension - 1) * BoardConstants.spacing, alignment: .topLeading)
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
