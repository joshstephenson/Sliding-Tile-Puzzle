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
    var boardView: BoardView
    var board: Board
    @ObservedObject var tile: Board.Tile
    
    init(boardView: BoardView, tile: Board.Tile) {
        self.boardView = boardView
        self.tile = tile
        self.board = boardView.model
    }
    var body: some View {
        InnerTile(number: tile.number)
            .offset(boardView.offsets[tile.position]!)
            .onTapGesture {
                board.move(position: tile.position) { position, solved in
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
    public var offsets: [Int:CGSize]
    
    init(model: Board) {
        self.model = model
        var offsets:[Int:CGSize] = [:]
        for i in 1...(model.dimension * model.dimension) {
            offsets[i] = BoardView.offsetForPosition(n: model.dimension, position: i)
        }
        self.offsets = offsets
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            ForEach(model.tiles, id: \.self) { tile in
                BoardTileView(boardView: self, tile: tile)
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
    @ObservedObject var boardModel = try! Board(filename: "4x4-01.txt")
    var body: some View {
        VStack(alignment: .center, spacing: 5.0) {
            Button("Solve") {
                boardModel.solve(with: { solution in
                    print("Solved in \(solution.count) steps")
                    if solution.count > 0 {
                        var index = 0.0
                        for position in solution {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * index) {
                                boardModel.move(position: position)
                            }
                            index += 1
                        }
                    }else{
                        if boardModel.isSolved {
                            print("Board is already solved")
                        }else {
                            print("Board cannot be solved")
                        }
                    }
                })
            }
            Rectangle()
                .fill(progressColor(boardModel.progress))
                .frame(minWidth:frameSize())
                .frame(height:5.0)
            
            BoardView(model: boardModel).frame(width: frameSize(), height: frameSize(), alignment: .topLeading)
                .background(Color("Board"))
        }
    }
    
    private func frameSize() -> CGFloat {
        return CGFloat(boardModel.dimension) * BoardConstants.tileSize + CGFloat(boardModel.dimension - 1) * BoardConstants.spacing
    }
    
    private func progressColor(_ progress: Double) -> Color {
        print(progress)
        return Color(red: 1 - (progress * 2.0), green: progress, blue: 0.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
