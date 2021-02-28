//
//  BoardAndPieces.swift
//  GridTest
//
//  Created by Gary Hanson on 2/24/21.
//

import SwiftUI


struct SquarePosition : Codable {
    let rowNum: Int
    let columnNum: Int
    
    init(rowNum: Int, columnNum: Int) {
        self.rowNum = rowNum
        self.columnNum = columnNum
    }
    
    init(matrixIndex: Int) {
        self.rowNum = matrixIndex / 8
        self.columnNum = matrixIndex % 8
    }
}

// enable hit testing only for color whose turn it is
enum EnableColor: Int {
    case forBlack,
    forWhite,
    forNone
}

struct PieceInfo {
    let square: SquarePosition
    let isBlack: Bool
    let type: ChessPiece.PieceType
}

struct ChessPiece: Identifiable {
    
    enum PieceType: Int {
        case pawn = 0,
        knight,
        bishop,
        rook,
        queen,
        king
    }
    
    let id = UUID()
    let isBlack: Bool
    let pieceType: PieceType
    
    var image: Image {
        get {
            let imageName = self.name + (isBlack ? "-black" : "")
            let image = Image(imageName)

            return image
        }
    }
    
    var name: String {
        var pieceName = ""
        
        switch (self.pieceType) {
            case .rook:
                pieceName = "Rook"
                
            case .bishop:
                pieceName = "Bishop"
                
            case .knight:
                pieceName = "Knight"
                
            case .queen:
                pieceName = "Queen"
                
            case .king:
                pieceName = "King"
                
            case .pawn:
                pieceName = "Pawn"
            }
        
        return pieceName
    }
    
}
