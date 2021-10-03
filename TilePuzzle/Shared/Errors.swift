//
//  Errors.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import Foundation

enum InitializationError: Error {
    case noDimensionFound
    case noFileFound
}

enum BoardError: Error {
    case invalidTileIndex
}
