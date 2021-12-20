//
//  TilePuzzleApp.swift
//  Shared
//
//  Created by Joshua Stephenson on 9/30/21.
//

import SwiftUI

@main
struct TilePuzzleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Board(dimension: 4))
        }
    }
}
