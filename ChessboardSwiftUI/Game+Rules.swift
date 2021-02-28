//
//  Game+Rules.swift
//  GridTest
//
//  Created by Gary Hanson on 2/25/21.
//

import Foundation

extension Game {
    
    private func moveIsRowOrColumn(fromSquare: SquarePosition, toSquare: SquarePosition) -> Bool {
        
        return ( (toSquare.rowNum == fromSquare.rowNum) || (toSquare.columnNum == fromSquare.columnNum) )
    }
    
    private func isRowOrColumnEmpty(fromSquare: SquarePosition, toSquare: SquarePosition) -> Bool {
        
        if fromSquare.rowNum == toSquare.rowNum  {       // checking same row
            let fromColumn = min(toSquare.columnNum, fromSquare.columnNum) + 1    // don't check starting or ending squares
            let toColumn = max(toSquare.columnNum, fromSquare.columnNum)
            for c in fromColumn ..< toColumn {
                if pieces[toSquare.rowNum][c] != nil {
                    return false
                }
            }
        }
        else {                                             // check column
            let fromRow = min(toSquare.rowNum, fromSquare.rowNum) + 1
            let toRow = max(toSquare.rowNum, fromSquare.rowNum)
            for r in fromRow ..< toRow {
                if pieces[r][fromSquare.columnNum] != nil {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func moveIsDiagonal(fromSquare: SquarePosition, toSquare: SquarePosition) -> Bool {
        
        return ( abs(toSquare.rowNum - fromSquare.rowNum) == (abs(toSquare.columnNum - fromSquare.columnNum)) )
    }
    
    private func isDiagonalEmpty(fromSquare: SquarePosition, toSquare: SquarePosition) -> Bool {  // square column must be less than toSquare column
        
        var fromRow: Int
        var fromColumn: Int
        var toColumn: Int
        
        // orient so test is always going down
        if fromSquare.rowNum < toSquare.rowNum {
            fromRow = fromSquare.rowNum
            fromColumn = fromSquare.columnNum
            //toRow = toSquare.rowNum
            toColumn = toSquare.columnNum
        }
        else {
            fromRow = toSquare.rowNum
            fromColumn = toSquare.columnNum
            toColumn = fromSquare.columnNum
        }
        
        if toColumn > (fromColumn + 1) {                        // diagonal is down to right
            var r = fromRow + 1
            for c in (fromColumn + 1)...(toColumn - 1) {        // don't check starting or ending squares
                if pieces[r][c] != nil {
                    return false
                }
                r += 1
            }
        }
        else {                                                  // diagonal is down to left
            var r = fromRow + 1
            var c = fromColumn - 1
            while c >= (toColumn + 1) {
                if pieces[r][c] != nil {
                    return false
                }
                c -= 1
                r += 1
            }
        }
        
        return true
    }
    
    
    // TODO: I know that several minor rules are not being enforced. 1) En Passant is not supported at all, 2) the tests for a valid Castle are not complete,
    // 3) it's been a long time since I've played chess seriously so I may have forgotten something else.
    // This app was never intended to be an attempt to create a complete commercial app.
    func isLegalMoveFor(piece: ChessPiece, fromIndex: Int, toIndex: Int) -> Bool {
        let fromSquarePosition = SquarePosition(matrixIndex: fromIndex)
        let toSquarePosition = SquarePosition(matrixIndex: toIndex)

        return isLegalMoveFor(piece: piece, fromSquare: fromSquarePosition, toSquare: toSquarePosition)
    }
    
    func isLegalMoveFor(piece: ChessPiece, fromSquare: SquarePosition, toSquare: SquarePosition) -> Bool {
        
        let destinationPiece = pieces[toSquare.rowNum][toSquare.columnNum]                  // is there a piece on the square we're moving to?
        
        if (destinationPiece != nil) && (destinationPiece!.isBlack == piece.isBlack) {      // can't move if piece of same color is there
            return false
        }
        
        self.didCastle = false
        var isLegal = false
        let numRowsMoved = abs(toSquare.rowNum - fromSquare.rowNum)
        let numColumnsMoved = abs(toSquare.columnNum - fromSquare.columnNum)
        
        switch (piece.pieceType) {
        case ChessPiece.PieceType.pawn:
            // the basics: pawn can move one or two rows from start pos else only one
            if ( (piece.isBlack && ((toSquare.rowNum > fromSquare.rowNum) && ( (fromSquare.rowNum == 1) ? numRowsMoved < 3 : (numRowsMoved == 1) )) )
                    || ( !piece.isBlack && ((toSquare.rowNum < fromSquare.rowNum) && ( (fromSquare.rowNum == 6) ? (numRowsMoved < 3) : (numRowsMoved == 1) ))) ) {
                
                // not bothering with en passant moves because it requires too much state info to bother with
                // must be in same column unless taking a piece, then can be in column on either side
                if ( (destinationPiece == nil) && (toSquare.columnNum != fromSquare.columnNum)) || (numColumnsMoved > 1) {
                    return isLegal
                }
                
                if ( (numRowsMoved == 2) && (self.isRowOrColumnEmpty(fromSquare: fromSquare, toSquare: toSquare) == false ) ) {
                    return isLegal
                }
                
                isLegal = true
            }
            
        case ChessPiece.PieceType.knight:
            isLegal = ( (numColumnsMoved == 2) && (numRowsMoved == 1) ) || ( (numRowsMoved == 2) && (numColumnsMoved == 1) )
            
        case ChessPiece.PieceType.bishop:
            isLegal = self.moveIsDiagonal(fromSquare: fromSquare, toSquare:toSquare) && self.isDiagonalEmpty(fromSquare: fromSquare, toSquare:toSquare)
            
        case ChessPiece.PieceType.rook:
            isLegal = self.moveIsRowOrColumn(fromSquare: fromSquare, toSquare:toSquare) && self.isRowOrColumnEmpty(fromSquare: fromSquare, toSquare:toSquare)
            
        case ChessPiece.PieceType.queen:
            isLegal = (self.moveIsDiagonal(fromSquare: fromSquare, toSquare:toSquare) && self.isDiagonalEmpty(fromSquare: fromSquare, toSquare:toSquare)) ||
                (self.moveIsRowOrColumn(fromSquare: fromSquare, toSquare:toSquare) && self.isRowOrColumnEmpty(fromSquare: fromSquare, toSquare:toSquare))
            
        case ChessPiece.PieceType.king:
            isLegal = ( (numColumnsMoved < 2) && (numRowsMoved < 2) )
            // really, really crude, incomplete test for castling
            if ( !isLegal && (fromSquare.columnNum == 4) && (numColumnsMoved > 1) && (numRowsMoved == 0) && ( ( (toSquare.rowNum == 0) && (fromSquare.rowNum == 0) ) || ( (toSquare.rowNum == 7) && (fromSquare.rowNum == 7) ) )  ) {
                isLegal = true
                self.didCastle = true        // controller will create another move for rook
            }
        }
        
        // TODO! this is commented off to conveniently allow viewing the end-of-game graphics. The best solution for making this a real application would be
        // to add a way to allow a user to resign.
        // Lastly, see if the move leaves the player in Check.
        //        if isLegal {
        //            isLegal = !isKingInCheckForColor(pieceView.isBlack)
        //        }
        
        return isLegal
    }
    
    // completely brute force to see if a king is in check, but more than fast enough
    func isKingInCheckForColor(_ isBlack: Bool) -> Bool {
        
        var kingsSquare = SquarePosition(rowNum: -1,columnNum: -1)
        
        // get square that king of color is on
        for c in 0..<8 {
            for r in 0..<8 {
                if ( (pieces[r][c] != nil) && (pieces[r][c]!.pieceType == ChessPiece.PieceType.king) && (pieces[r][c]!.isBlack == isBlack) ) {
                    kingsSquare = SquarePosition(rowNum: r, columnNum: c)
                    break
                }
            }
        }
        
        // iterate through pieces, if piece is of other color - is king's square a legal move?
        for c in 0..<8 {
            for r in 0..<8 {
                if (pieces[r][c] != nil) && (pieces[r][c]!.isBlack != isBlack) {
                    let pieceSquare = SquarePosition(rowNum: r, columnNum: c)
                    if self.isLegalMoveFor(piece: pieces[r][c]!, fromSquare:pieceSquare, toSquare:kingsSquare) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
}
