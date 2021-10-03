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

    func testExample() throws {
        let board = try! BoardModel(filename: "3x3-01.txt")
        let solver = Solver(board)
        XCTAssert(solver.moves() == 5)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
