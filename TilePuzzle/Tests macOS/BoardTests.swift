//
//  BoardTests.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import XCTest

class MockBoard {
    var tiles:[MockTile] = []
    
    init(tileCount: Int) {
        var t:[MockTile] = []
        for i in 1...10 {
            t.append(MockTile(number: i, board: self))
        }
        self.tiles = t
    }
    
    init(tiles: [MockTile]) {
        self.tiles = tiles
    }
    
    func returnCopyAfterRemoving(_ count: Int) -> MockBoard {
        var swap = tiles
        for _ in 1...count {
            swap.removeLast()
        }
        return MockBoard(tiles: swap)
    }
}

class MockTile:NSObject {
    var board: MockBoard
    var number: Int
    init(number: Int, board: MockBoard) {
        self.number = number
        self.board = board
    }
}

class BoardTests: XCTestCase {

    func testNeigborsReturnsCorrectNumberOfBoards() throws {
        var contents = """
            3
             1  2  3
             4  0  6
             7  5  8
            """
        var board = try Board(contents: contents)
        XCTAssertEqual(board.neighbors().count, 4)
        
        contents = """
            3
             1  2  3
             0  4  6
             7  5  8
            """
        board = try Board(contents: contents)
        XCTAssertEqual(board.neighbors().count, 3)
        
        contents = """
            3
             0  2  3
             1  4  6
             7  5  8
            """
        board = try Board(contents: contents)
        XCTAssertEqual(board.neighbors().count, 2)
        
        contents = """
            3
             1  2  3
             8  4  6
             7  5  0
            """
        board = try Board(contents: contents)
        XCTAssertEqual(board.neighbors().count, 2)
    }
    
    func testBasicArrayCopy() throws {
        
        let mockBoard = MockBoard(tileCount: 10)
        let dupe = mockBoard.returnCopyAfterRemoving(3)
        XCTAssertEqual(mockBoard.tiles.count, 10)
        for i in 0...9 {
            XCTAssertEqual(mockBoard.tiles[i].number, i+1)
        }
        XCTAssertEqual(dupe.tiles.count, 7)
        for i in 0...6 {
            XCTAssertEqual(mockBoard.tiles[i].number, i+1)
        }
    }
    
    func testDuplicatingDoesntChangeInitial() throws {
        let initial = """
            3
             1  2  0
             4  8  3
             7  6  5
            """
        
        let board = try Board(contents: initial)
        let _ = board.description
        let dupe = board.duplicateAfterSliding(2) // slide the 2 over to the right
        XCTAssertEqual(board.slotPosition, 3)
        XCTAssertEqual(dupe.slotPosition, 2)
        let expected = [1,2,0,4,8,3,7,6,5]
        
        let result1:[Int] = board.description.components(separatedBy: CharacterSet.whitespacesAndNewlines).compactMap { char in
            if char.isEmpty {
                return nil
            }
            return Int(char)
        }
        var index = 0
        for num in result1 {
            XCTAssertEqual(num, expected[index])
            index += 1
        }
    }
    
    func testDuplicatingAfterSliding() throws {
        let initial = """
            3
             1  2  0
             4  8  3
             7  6  5
            """
        
        let board = try Board(contents: initial)
        var neighbor = board.duplicateAfterSliding(6) // slide the 3 up
        var expected = [1,2,3,4,8,0,7,6,5]
        
        var result1:[Int] = neighbor.description.components(separatedBy: CharacterSet.whitespacesAndNewlines).compactMap { char in
            if char.isEmpty {
                return nil
            }
            return Int(char)
        }
        var index = 0
        for num in result1 {
            XCTAssertEqual(num, expected[index])
            index += 1
        }
        
        // NOTE: Still working with the original board
        neighbor = board.duplicateAfterSliding(2) // slide the 2 over to the right
        expected = [1,0,2,4,8,3,7,6,5]
        
        result1 = neighbor.description.components(separatedBy: CharacterSet.whitespacesAndNewlines).compactMap { char in
            if char.isEmpty {
                return nil
            }
            return Int(char)
        }
        index = 0
        for num in result1 {
            XCTAssertEqual(num, expected[index])
            index += 1
        }
    }
    
    func testNeighborsReturnsCorrectBoards() throws {
        let initial = """
            3
             1  2  0
             4  8  3
             7  6  5
            """
        let expected1 = [1,0,2,4,8,3,7,6,5]
        var board = try Board(contents: initial)
        
        let result1:[Int] = board.neighbors().first!.description.components(separatedBy: CharacterSet.whitespacesAndNewlines).compactMap { char in
            if char.isEmpty {
                return nil
            }
            return Int(char)
        }
        var index = 0
        for num in result1 {
            XCTAssertEqual(num, expected1[index])
            index += 1
        }
        XCTAssertEqual(result1.count, 9)
        
        let expected2 = [1,2,3,4,8,0,7,6,5]
        let result2:[Int] = board.neighbors().last!.description.components(separatedBy: CharacterSet.whitespacesAndNewlines).compactMap { char in
            if char.isEmpty {
                return nil
            }
            return Int(char)
        }
        index = 0
        for num in result2 {
            XCTAssertEqual(num, expected2[index])
            index += 1
        }
        XCTAssertEqual(result2.count, 9)
    }

}
