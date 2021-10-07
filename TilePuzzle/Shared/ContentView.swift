//
//  ContentView.swift
//  Shared
//
//  Created by Joshua Stephenson on 9/30/21.
//

import SwiftUI
import Combine

extension Animation {
    static func slide() -> Animation {
        Animation.easeOut(duration: AnimationConstants.slideAnimationDuration)
    }
}

struct InnerTile: View {
    var number: Int
    var dimension: Int
    var body: some View {
        Text("\(number)")
            .font(Font.custom("HelveticaNeue", size: 25.0))
            .shadow(color: Color.white, radius: 1.0, x: 1.0, y: 1.0)
            .foregroundColor(Color.black)
            .frame(width: CGFloat(BoardConstants.tileSize), height: CGFloat(BoardConstants.tileSize), alignment: .center)
            .background(color())
            .cornerRadius(5.0)
    }
    
    private func color() -> Color {
        // Desiring a hue between 0.44 and 0.56
        let start = 0.45
        let range = 0.12
        let offset = range / Double(dimension * dimension) * Double(number)
        let hue = start + offset
        return Color.init(hue: hue, saturation: 1.0, brightness: 1.0)
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
        InnerTile(number: tile.number, dimension: tile.dimension)
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
        return CGSize(width: col * BoardConstants.tileSize + (col - 1) * BoardConstants.spacing + 6.0,
                      height: row * BoardConstants.tileSize + (row - 1) * BoardConstants.spacing + 6.0)
    }
    
}

struct PuzzleButton: View {
    var action: (() -> Void)
    var label: String
    init(label: String, action: @escaping (() -> Void)) {
        self.label = label
        self.action = action
    }
    var body: some View {
        Button(action: action, label: {
            Text(label)
                .font(Font.custom("HelveticaNeue-Medium", size: 14.0))
                .underline()
                .foregroundColor(Color.white)
                .frame(height:22.0)
        }).buttonStyle(BorderlessButtonStyle())
        .background(Color("Board"))
    }
}

struct ContentView: View {
    @ObservedObject var boardModel = Board(dimension: 4)
    @State var isActive: Bool = false
    var body: some View {
        VStack(alignment: .center, spacing: 5.0) {
            if !isActive {
                Spacer().frame(height:8.0)
                HStack(alignment: .center, spacing: 20.0) {
                    PuzzleButton(label: "Randomize") {
                        self.isActive = true
                        self.boardModel.randomize() {
                            self.isActive = false
                        }
                    }
                    PuzzleButton(label: "Solve") {
                        if boardModel.isSolved {
                            print("Board is already solved")
                        }else{
                            self.isActive = true
                            boardModel.solve() {
                                self.isActive = false
                            }
                        }
                    }
                }
            }else {
                Spacer().frame(height:10.0)
                ProgressView()
                    .colorScheme(.dark)
                    .frame(maxHeight:20.0)
            }
            
            Spacer().frame(height:2.0)
//            Rectangle()
//                .fill(progressColor(boardModel.progress))
//                .frame(maxWidth:CGFloat(boardModel.progress) * frameSize())
//                .frame(height:5.0)
            BoardView(model: boardModel).frame(width: frameSize(), height: frameSize(), alignment: .topLeading)
                
        }.background(Color("Board"))
    }
    
    private func frameSize() -> CGFloat {
        return CGFloat(boardModel.dimension) * BoardConstants.tileSize + CGFloat(boardModel.dimension - 1) * BoardConstants.spacing + 6.0
    }
    
    private func progressColor(_ progress: Double) -> Color {
        return Color(red: 0.0, green: 1.0, blue: 0.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
