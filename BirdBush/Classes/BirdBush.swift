//
//  BirdBush.swift
//
//  Created by Harry Netzer on 12/11/18.
//
//
//  ISC License
//
//  Copyright (c) 2018, Vladimir Agafonkin
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose
//  with or without fee is hereby granted, provided that the above copyright notice
//  and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
//  INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
//  OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
//  TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
//  THIS SOFTWARE.
//

public final class BirdBush<U> {
    var ids = [U]()
    var coords = [Double]()
    let nodeSize: Int
    
    public init<T>(locations: [T], nodeSize: Int = 64, getID: (_ : T) -> U, getX: (_ : T) -> Double, getY: (_ : T) -> Double) {
        for location in locations {
            ids.append(getID(location))
            coords.append(getX(location))
            coords.append(getY(location))
        }
        self.nodeSize = nodeSize
        sortKD(left: 0, right: ids.count - 1, axis: 0)
    }
    
    func sortKD(left: Int, right: Int, axis: Int) {
        if (right - left <= nodeSize) { return }
    
        let m = (left + right) >> 1 // middle index
    
        // sort ids and coords around the middle index so that the halves lie
        // either left/right or top/bottom correspondingly (taking turns)
        select(k: m, left: left, right: right, axis: axis)
        
        // recursively kd-sort first half and second half on the opposite axis
        sortKD(left: left, right: m - 1, axis: 1 - axis)
        sortKD(left: m + 1, right: right, axis: 1 - axis)
    }
    
    // custom Floyd-Rivest selection algorithm: sort ids and coords so that
    // [left..k-1] items are smaller than k-th item (on either x or y axis)
    func select(k: Int, left: Int, right: Int, axis: Int) {
        var right = right
        var left = left
        
        while (right > left) {
            if (right - left > 600) {
                let doublek = Double(k)
                let n = Double(right - left + 1)
                let m = Double(k - left + 1)
                let z = log(n)
                let s = 0.5 * exp(2 * z / 3)
                let sd = 0.5 * sqrt(z * s * (n - s) / n) * (m - n / 2 < 0 ? -1 : 1)
                let newLeft = max(left, Int(floor(doublek - m * s / n + sd)))
                let newRight = min(right, Int(floor(doublek + (n - m) * s / n + sd)))
                select(k: k, left: newLeft, right: newRight, axis: axis)
            }
            
            let t = coords[2 * k + axis]
            var i = left
            var j = right
            
            swapItem(left, k)
            if (coords[2 * right + axis] > t) {
                swapItem(left, right)
            }
            
            while (i < j) {
                swapItem(i, j);
                i += 1
                j -= 1
                while (coords[2 * i + axis] < t) { i += 1 }
                while (coords[2 * j + axis] > t) { j -= 1 }
            }
            
            if (coords[2 * left + axis] == t) {
                swapItem(left, j)
            } else {
                j += 1
                swapItem(j, right)
            }
            
            if (j <= k) { left = j + 1 }
            if (k <= j) { right = j - 1 }
        }
    }
    
    // Used to find NN, 
    func sqDist(_ ax: Double, _ ay: Double, _ bx: Double, _ by: Double) -> Double {
        let dx = ax - bx
        let dy = ay - by
        return dx * dx + dy * dy
    }
    
    private func swapItem(_ i: Int, _ j: Int) {
        ids.swapAt(i, j)
        coords.swapAt(2*i, 2*j)
        coords.swapAt(2*i+1, 2*j+1)
    }
}

extension BirdBush: Codable where U: Codable { }
