//
//  SolverTests.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/3/21.
//

import XCTest

class SolverTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSolverFindsMostSimpleSolution() throws {
        let contents = """
            3
             1  2  3
             4  5  6
             7  0  8
            """
        let board = try Board(contents: contents)
        let solver = Solver(board)
        XCTAssertEqual(solver.moves(), 1)
    }
    
    func testSolverFindsMoreComplicatedSolution() throws {
        let contents = """
            3
             1  2  0
             4  8  3
             7  6  5
            """
        let board = try Board(contents: contents)
        let solver = Solver(board)
        XCTAssertEqual(solver.moves(), 6)
    }
    
    func testSolverFindsSimpleFourByFourSolution() throws {
        let contents = """
        4
         1  6  2  4
         5  0  3  8
         9 10  7 11
        13 14 15 12
"""
        let board = try Board(contents: contents)
        let solver = Solver(board)
        XCTAssertEqual(solver.moves(), 6)
    }
    
    func testSolverFindsMoreComplicatedFourByFourSolution() throws {
        let contents = """
       4
        2  5  4  8
        1  7 10  3
       14  6  0 11
        9 13 15 12
"""
        let board = try Board(contents: contents)
        let solver = Solver(board)
        XCTAssertEqual(solver.moves(), 18)
    }
   
    func testVerifiesThreeByThreeBoardIsUnsolvable() throws {
        let contents = """
       3
        1  2  3
        4  6  5
        7  8  0
"""
        let board = try Board(contents: contents)
        let solver = Solver(board)
        XCTAssertEqual(solver.moves(), -1)
    }
    
    func testVerifiesFourByFourBoardIsUnsolvable() throws {
        let contents = """
       4
        3  2  4  8
        1  6  0 12
        5 10  7 11
        9 13 14 15

"""
        let board = try Board(contents: contents)
        let solver = Solver(board)
        XCTAssertEqual(solver.moves(), -1)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
