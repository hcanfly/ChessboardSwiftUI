//
//  ChessboardSwiftUIApp.swift
//  ChessboardSwiftUI
//
//  Created by Gary Hanson on 2/24/21.
//

import SwiftUI

@main
struct ChessboardSwiftUIApp: App {
    let game = Game()
    
    var body: some Scene {
        WindowGroup {
            ContentView(game: game)
        }
    }
}
