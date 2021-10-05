//
//  BoardTests.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import XCTest

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
    
    func testDuplicatingAfterSliding() throws {
        let initial = """
            3
             1  2  0
             4  8  3
             7  6  5
            """
        
        var board = try Board(contents: initial)
        var neighbor = board.duplicateAfterSliding(2) // slide the 2 over to the right
        var expected = [1,0,2,4,8,3,7,6,5]
        
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
        let expected2 = [1,2,3,4,8,0,7,6,5]
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
//        XCTAssertTrue(result1 == expected1 || result1 == expected2)
    }

}
