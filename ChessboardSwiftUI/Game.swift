//
//  Game.swift
//  GridTest
//
//  Created by Gary Hanson on 2/24/21.
//

import SwiftUI


final class Game: ObservableObject {
    @Published var pieces = [[ChessPiece?]]()                   // data model. matrix is [row][column]
    @Published var capturedBlackPieces = [ChessPiece]()
    @Published var capturedWhitePieces = [ChessPiece]()
    var didCastle = false
    var colorToPlay = EnableColor.forWhite                      // whose turn is it?
    
    init() {
        newGame()
    }
    
    func newGame() {
        pieces.removeAll()
        capturedWhitePieces.removeAll()
        capturedBlackPieces.removeAll()
        didCastle = false
        colorToPlay = EnableColor.forWhite 
        
        for _ in 0..<8 {
            pieces.append(Array(repeating: nil, count: 8))
        }
        
        let pi: [PieceInfo] = [
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 0), isBlack: true, type: ChessPiece.PieceType.rook),
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 1), isBlack: true, type: ChessPiece.PieceType.knight),
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 2), isBlack: true, type: ChessPiece.PieceType.bishop),
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 3), isBlack: true, type: ChessPiece.PieceType.queen),
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 4), isBlack: true, type: ChessPiece.PieceType.king),
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 5), isBlack: true, type: ChessPiece.PieceType.bishop),
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 6), isBlack: true, type: ChessPiece.PieceType.knight),
            PieceInfo(square: SquarePosition(rowNum: 0, columnNum: 7), isBlack: true, type: ChessPiece.PieceType.rook),

            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 0), isBlack: true, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 1), isBlack: true, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 2), isBlack: true, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 3), isBlack: true, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 4), isBlack: true, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 5), isBlack: true, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 6), isBlack: true, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 1, columnNum: 7), isBlack: true, type: ChessPiece.PieceType.pawn),
            
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 0), isBlack: false, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 1), isBlack: false, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 2), isBlack: false, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 3), isBlack: false, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 4), isBlack: false, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 5), isBlack: false, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 6), isBlack: false, type: ChessPiece.PieceType.pawn),
            PieceInfo(square: SquarePosition(rowNum: 6, columnNum: 7), isBlack: false, type: ChessPiece.PieceType.pawn),

            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 0), isBlack: false, type: ChessPiece.PieceType.rook),
            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 1), isBlack: false, type: ChessPiece.PieceType.knight),
            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 2), isBlack: false, type: ChessPiece.PieceType.bishop),
            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 3), isBlack: false, type: ChessPiece.PieceType.queen),
            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 4), isBlack: false, type: ChessPiece.PieceType.king),
            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 5), isBlack: false, type: ChessPiece.PieceType.bishop),
            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 6), isBlack: false, type: ChessPiece.PieceType.knight),
            PieceInfo(square: SquarePosition(rowNum: 7, columnNum: 7), isBlack: false, type: ChessPiece.PieceType.rook),
        ]

        for p in pi {
            let piece = ChessPiece(isBlack: p.isBlack, pieceType: p.type)
            
            self.pieces[p.square.rowNum][p.square.columnNum] = piece
        }
    }

    // when doing castling, get the current position of the rook based on the king's move
    private func currentRookPositionForKingCastlingMoveTo(_ square: SquarePosition) -> SquarePosition {
    
        let rookSquare = SquarePosition(rowNum: square.rowNum, columnNum: square.columnNum == 1 ? 0 : 7)
        
        return rookSquare
    }
    
    // when doing castling, get the new position of the rook based on the king's move
    private func newRookPositionForKingCastlingMoveTo(_ square: SquarePosition) -> SquarePosition {
    
        let castleSquare = SquarePosition(rowNum: square.rowNum, columnNum: square.columnNum == 1 ? 2 : 5)
    
        return castleSquare
    }
    
    func movePiece(from index: Int, toIndex: Int) {
        let fromSquare = SquarePosition(matrixIndex: index)
        let toSquare = SquarePosition(matrixIndex: toIndex)
        
        pieces[toSquare.rowNum][toSquare.columnNum] = pieces[fromSquare.rowNum][fromSquare.columnNum]
        pieces[fromSquare.rowNum][fromSquare.columnNum] = nil
        if self.didCastle == true {
            // king moved to legal castle position, move rook accordingly
            
            let toSquarePosition = SquarePosition(matrixIndex: toIndex)
            let rookSquare = self.currentRookPositionForKingCastlingMoveTo(toSquarePosition)
            let castleSquare = self.newRookPositionForKingCastlingMoveTo(toSquarePosition)
            
            let rook = pieces[rookSquare.rowNum][rookSquare.columnNum]
            pieces[castleSquare.rowNum][castleSquare.columnNum] = rook
            pieces[rookSquare.rowNum][rookSquare.columnNum] = nil
            self.didCastle = false
        }
        self.colorToPlay = self.colorToPlay == EnableColor.forWhite ? EnableColor.forBlack : EnableColor.forWhite
    }
    
    func addCapturedPiece(_ piece: ChessPiece) {
        if piece.isBlack {
            capturedBlackPieces.append(piece)
        } else {
            capturedWhitePieces.append(piece)
        }
    }
    
    func getImage(for piece: ChessPiece?) -> Image {
        if let piece = piece {
            return piece.image
        } else {
            return Image("ClearPict")
        }
    }
    
    func pieceForIndex(index: Int) -> ChessPiece? {
        return pieces[index / 8][index % 8]
    }
    
    private func squareToIndex(square: SquarePosition) -> Int {
        return (square.rowNum * 8) + square.columnNum
    }
    
}
