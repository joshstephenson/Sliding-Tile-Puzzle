//
//  MinimumPriorityQueueTests.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/4/21.
//

import XCTest

class MinimumPriorityQueueTests: XCTestCase {

    func testSwimming() throws {
        var minPQ = MinimumPriorityQueue<Int>()
        minPQ.insert(13)
        XCTAssertEqual(minPQ.min()!, 13)
        
        minPQ.insert(14)
        XCTAssertEqual(minPQ.min()!, 13)
        
        minPQ.insert(12)
        XCTAssertEqual(minPQ.min()!, 12)
        
        minPQ.insert(11)
        XCTAssertEqual(minPQ.min()!, 11)
        
        minPQ.insert(3)
        XCTAssertEqual(minPQ.min()!, 3)
        
        minPQ.insert(7)
        XCTAssertEqual(minPQ.min()!, 3)
        
        minPQ.insert(1)
        XCTAssertEqual(minPQ.min()!, 1)
    }
    
    func testSinking() throws {
        var minPQ = MinimumPriorityQueue<Int>()
        minPQ.insert(2)
        minPQ.insert(4)
        minPQ.insert(8)
        minPQ.insert(5)
        minPQ.insert(7)
        minPQ.insert(6)
        minPQ.insert(1)
        minPQ.insert(3)
        minPQ.insert(9)
        
        XCTAssertEqual(minPQ.delMin()!, 1)
        XCTAssertEqual(minPQ.delMin()!, 2)
        XCTAssertEqual(minPQ.delMin()!, 3)
        XCTAssertEqual(minPQ.delMin()!, 4)
        XCTAssertEqual(minPQ.delMin()!, 5)
        XCTAssertEqual(minPQ.delMin()!, 6)
        XCTAssertEqual(minPQ.delMin()!, 7)
        XCTAssertEqual(minPQ.delMin()!, 8)
        XCTAssertEqual(minPQ.delMin()!, 9)
    }

}
