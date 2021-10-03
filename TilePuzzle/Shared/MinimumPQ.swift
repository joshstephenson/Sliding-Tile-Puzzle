//
//  MinimumPQ.swift
//  TilePuzzle
//
//  Created by Joshua Stephenson on 10/2/21.
//

import Foundation

public struct PriorityQueue<T: Comparable> {
    private var pq:[T]
    private var n:Int
    
    init(_ capacity:Int) {
        pq = []
        n = 0;
    }
    
    init() {
        self.init(1)
    }
    
    public func isEmpty() -> Bool {
        return n == 0;
    }
    
    public func min() -> T? {
        return pq[1]
    }
   
    public mutating func delMin() -> T? {
        if !isEmpty() {
            let min = pq[1]
            exchange(1,n)
            n -= 1
            sink(1)
            pq.remove(at: n+1)
            return min;
        }
        return nil
    }
    
    public mutating func insert(t: T) {
        self.n += 1
        pq[n] = t
        swim(n)
    }
    
    private mutating func swim(_ k:Int) {
        var k = k
        while(k > 1 && greater(k/2, k)) {
            exchange(k, k/2)
            k = k/2;
        }
    }
    
    private mutating func sink(_ k:Int) {
        var k = k
        while (2*k <= n) {
            var j = 2*k
            if (j < n && greater(j, j+1)) {
                j += 1
            }
            exchange(k, j)
            k = j
        }
    }
    
    private func greater(_ i:Int, _ j:Int) -> Bool{
        return pq[i] > pq[j]
    }
    
    private mutating func exchange(_ i: Int, _ j: Int) {
        let swap = pq[i]
        pq[i] = pq[j]
        pq[j] = swap
    }
}
