//
//  BirdBush+Within.swift
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

extension BirdBush {
    public func within(qx: Double, qy: Double, r: Double) -> [U] {
        var stack = [0, ids.count - 1, 0]
        var result = [U]()
        let r2 = r * r
        
        // recursively search for items within radius in the kd-sorted arrays
        while (stack.count >= 3) {
            let axis = stack.popLast()!
            let right = stack.popLast()!
            let left = stack.popLast()!
            
            // if we reached "tree node", search linearly
            if (right - left <= nodeSize) {
                for i in left...right {
                    if (sqDist(coords[2 * i], coords[2 * i + 1], qx, qy) <= r2) {
                        result.append(ids[i])
                    }
                }
                continue
            }
            
            // otherwise find the middle index
            let m = (left + right) >> 1
            
            // include the middle item if it's in range
            let x = coords[2 * m]
            let y = coords[2 * m + 1]
            if (sqDist(x, y, qx, qy) <= r2) {
                result.append(ids[m])
            }
            
            // queue search in halves that intersect the query
            if (axis == 0 ? qx - r <= x : qy - r <= y) {
                stack.append(left)
                stack.append(m - 1)
                stack.append(1 - axis)
            }
            if (axis == 0 ? qx + r >= x : qy + r >= y) {
                stack.append(m + 1)
                stack.append(right)
                stack.append(1 - axis)
            }
        }
        
        return result
    }
}
