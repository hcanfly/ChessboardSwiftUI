//
//  ContentView.swift
//  ChessboardSwiftUI
//
//  Created by Gary Hanson on 2/24/21.
//


import SwiftUI


struct ContentView: View {
    @ObservedObject var game: Game
    @State private var pieceFrames = [CGRect](repeating: .zero, count: 64)  // location of squares in global coordinates

    private func squareToIndex(square: SquarePosition) -> Int {
        return (square.rowNum * 8) + square.columnNum
    }
    
    func pieceDropped(location: CGPoint, index: Int) {
        if let match = pieceFrames.firstIndex(where: { $0.contains(location) }) {
            let fromPiece = game.pieceForIndex(index: index)!
            if game.isLegalMoveFor(piece: fromPiece, fromIndex: index, toIndex: match) {
                if let toPiece = game.pieceForIndex(index: match) {
                    game.addCapturedPiece(toPiece)
                }
                game.movePiece(from: index, toIndex: match)
            } else {
                // not a legal move
            }
        } else {
            // dropped off the board
        }
    }
    
    private func squareBackgroundColor(index: Int) -> Color {
        let row = index / 8
        let column = index % 8
        
        if (row % 2 == 0 && column % 2 != 0) || (row % 2 != 0 && column % 2 == 0) {
            return Color("blackSquare")
        }
        else {
            return Color("whiteSquare")
        }
    }

    private var Content: some View {
        VStack(alignment: .center) {
            Text(game.colorToPlay == EnableColor.forWhite ? "White to move..." : "Black to move...")
                .font(.title3)
                .foregroundColor(.green)
                .padding(.bottom, 50)

            CapturedPieceView(game: game, capturedPieces: game.capturedWhitePieces, showBlack: false)
                .padding(.bottom, 30)
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 8)
            LazyVGrid(columns: columns, spacing: 0, content:  {
                ForEach(0..<64) { i in
                    SquareView(index: i, handleDrop: pieceDropped, piece: game.pieceForIndex(index: i), game: game)
                        .background(squareBackgroundColor(index: i))
                        .overlay(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        self.pieceFrames[i] = geo.frame(in: .global)
                                    }
                            }
                        )
                }
            })
            .padding(.bottom, 30)

            CapturedPieceView(game: game, capturedPieces: game.capturedBlackPieces, showBlack: true)

            Spacer()
            HStack {
                Spacer()
                
                Button {
                    game.newGame()
                } label: {
                    Text("New Game")
                }
                }
        }
        .padding(.bottom, 10)
    }
    
    var body: some View {
        Content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .padding(.top, 40)
            .background(Image("BlackMarbleBackground").resizable())
    }
    
}


struct SquareView: View {
    let index: Int
    let handleDrop: ((CGPoint, Int) -> Void)?
    let piece: ChessPiece?
    let game: Game

    @State private var dragAmount = CGSize.zero
    
    private func pieceIsActiveColor(piece: ChessPiece) -> Bool {
        if piece.isBlack && game.colorToPlay == EnableColor.forBlack || piece.isBlack == false && game.colorToPlay == EnableColor.forWhite {
            return true
        }
        
        return false
    }
    
    var body: some View {
        // z-index can be only be controlled within the containing view. So, the view
        // to be dragged, this image, can't be contained in an HStack or ZStack, etc.
        // in this view.
        game.getImage(for: piece)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .rotationEffect(.degrees((piece == nil || piece!.isBlack == false) ? 0.0 : 180.0))
            .offset(dragAmount)
            .zIndex(dragAmount == .zero ? 0 : 1)    // keep the dragged image on top
            .allowsHitTesting(piece != nil && pieceIsActiveColor(piece: piece!))
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged {
                        self.dragAmount = CGSize(width: $0.translation.width, height: $0.translation.height)
                    }
                    .onEnded {
                        self.handleDrop?($0.location, self.index)
                        self.dragAmount = .zero
                    }
            )
    }
}

struct CapturedPieceView: View {
    var game: Game
    var capturedPieces: [ChessPiece]     // need this because it has to be visible in ContentView for Combine
    let showBlack: Bool

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 2) {
                ForEach(capturedPieces.sorted(by: { $0.pieceType.rawValue > $1.pieceType.rawValue } ) ) { piece in
                    game.getImage(for: piece)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .rotationEffect(.degrees((piece.isBlack == true) ? 0.0 : 180.0))
                }
            }
            .background(Color.clear)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 30)
        .background(Color.gray)
    }
}
