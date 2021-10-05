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

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
