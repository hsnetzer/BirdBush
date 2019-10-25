//
//  BirdBush+Range.swift
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
    public func range(minX: Double, minY: Double, maxX: Double, maxY: Double) -> [U] {
        var stack = [0, ids.count - 1, 0]
        var result = [U]()

        // recursively search for items in range in the kd-sorted arrays
        while stack.count > 0 {
            let axis = stack.popLast()!
            let right = stack.popLast()!
            let left = stack.popLast()!

            // if we reached a "tree node", search linearly
            if right - left <= nodeSize {
                for index in left...right {
                    let xCoord = coords[2 * index]
                    let yCoord = coords[2 * index + 1]
                    if xCoord >= minX && xCoord <= maxX && yCoord >= minY && yCoord <= maxY {
                        result.append(ids[index])
                    }
                }
                continue
            }

            // otherwise find the middle index
            let mid = (left + right) >> 1

            // include the middle item if it's in range
            let xCoord = coords[2 * mid]
            let yCoord = coords[2 * mid + 1]
            if xCoord >= minX && xCoord <= maxX && yCoord >= minY && yCoord <= maxY {
                result.append(ids[mid])
            }

            // queue search in halves that intersect the query
            if (axis == 0 ? minX <= xCoord : minY <= yCoord) {
                stack.append(left)
                stack.append(mid - 1)
                stack.append(1 - axis)
            }
            if (axis == 0 ? maxX >= xCoord : maxY >= yCoord) {
                stack.append(mid + 1)
                stack.append(right)
                stack.append(1 - axis)
            }
        }
        return result
    }
}
