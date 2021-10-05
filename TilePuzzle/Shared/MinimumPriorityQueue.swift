//
//  MinimumPQ.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/2/21.
//

import Foundation

public struct MinimumPriorityQueue<T: Comparable> {
    private var nodes:[T]
    
    init() {
        nodes = []
    }
    
    public func isEmpty() -> Bool {
        return nodes.isEmpty
    }
    
    public func min() -> T? {
        return nodes.first
    }
   
    public mutating func delMin() -> T? {
        guard !nodes.isEmpty else { return nil }
        
        if nodes.count == 1 {
            return nodes.removeLast()
        } else {
            let min = nodes.first
            nodes[0] = nodes.removeLast()
            sink(0)
            return min;
        }
    }
    
    public mutating func insert(_ node: T) {
        nodes.append(node)
        swim(nodes.count-1)
    }
    
    // swap child with parent until proper min heap order is reached
    private mutating func swim(_ index: Int) {
        var childIndex = index
        var parentIndex = (childIndex - 1) / 2
        
        while childIndex > 0 && nodes[childIndex] < nodes[parentIndex] {
            nodes.swapAt(childIndex, parentIndex)
            childIndex = parentIndex
            parentIndex = (childIndex - 1) / 2
        }
    }
    
    // swap current with child until proper min heap order is restored
    private mutating func sink(_ index:Int) {
        var index = index
        while 2 * index + 1 < nodes.count {
            var selected = 2 * index + 1 // left-hand side of two children
            let right = selected + 1
            if right < nodes.count && nodes[right] < nodes[selected] {
                selected = right
            }
            if nodes[selected] < nodes[index] {
                nodes.swapAt(index, selected)
            }
            index = selected
        }
    }

}
