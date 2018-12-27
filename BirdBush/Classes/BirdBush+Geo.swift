//
//  GeoBirdBush.swift
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

import Foundation
import SwiftPriorityQueue

public extension BirdBush {
    private struct QueueElement: Comparable {
        static func < (lhs: BirdBush.QueueElement, rhs: BirdBush.QueueElement) -> Bool {
            return lhs.dist < rhs.dist
        }
        
        static func == (lhs: BirdBush.QueueElement, rhs: BirdBush.QueueElement) -> Bool {
            return lhs.dist == rhs.dist
        }
        
        let dist: Double
        let type: QueueElementType
    }
    
    private enum QueueElementType {
        case point(id: U)
        case node(left: Int, right: Int, axis: Int, minLon: Double, maxLon: Double, minLat: Double, maxLat: Double)
    }
    
    func around(lon: Double, lat: Double, maxResults: Int = Int.max, maxDistance: Double = Double.greatestFiniteMagnitude) -> [(U, Double)] {
        var maxHaverSinDist = 1.0, result = [(U, Double)]()
        
        if (maxDistance != Double.greatestFiniteMagnitude) {
            maxHaverSinDist = haverSin(maxDistance / 6.371e6)
        }
        
        // a distance-sorted priority queue that will contain both points and kd-tree nodes
        var q = PriorityQueue<QueueElement>(ascending: true)
        
        // an object that represents the top kd-tree node (the whole Earth)
        var node: QueueElementType? = QueueElementType.node(left: 0, right: ids.count - 1, axis: 0, minLon: -180, maxLon: 180, minLat: -90, maxLat: 90)
        
        let cosLat = cos(lat * .pi / 180)
        
        while let noder = node {
            switch noder {
            case let .node(left, right, axis, minLon, maxLon, minLat, maxLat):
                if (right - left <= nodeSize) { // leaf node
                    
                    // add all points of the leaf node to the queue
                    for i in left...right {
                        let item = ids[i]
                        let dist = haverSinDist(lon1: lon, lat1: lat, lon2: coords[2 * i], lat2: coords[2 * i + 1], cosLat1: cosLat)
                        q.push(QueueElement(dist: dist, type: QueueElementType.point(id: item)))
                    }
                } else { // not a leaf node (has child nodes)
                    
                    let m = (left + right) >> 1 // middle index
                    let midLon = coords[2 * m]
                    let midLat = coords[2 * m + 1]
                    
                    // add middle point to the queue
                    let item = ids[m]
                    let dist = haverSinDist(lon1: midLon, lat1: midLat, lon2: lon, lat2: lat, cosLat1: cosLat)
                    q.push(QueueElement(dist: dist, type: QueueElementType.point(id: item)))
                    
                    let nextAxis = 1 - axis
                    
                    let nextMinLon = axis == 0 ? midLon : minLon
                    let nextMaxLon = axis == 0 ? midLon : maxLon
                    let nextMinLat = axis == 1 ? midLat : minLat
                    let nextMaxLat = axis == 1 ? midLat : maxLat
                    
                    let leftDist = boxDist(qLon: lon, qLat: lat, cosLat: cosLat, minLon: minLon, maxLon: nextMaxLon, minLat: minLat, maxLat: nextMaxLat)
                    let rightDist = boxDist(qLon: lon, qLat: lat, cosLat: cosLat, minLon: nextMinLon, maxLon: maxLon, minLat: nextMinLat, maxLat: maxLat)
                    
                    // first half of the node
                    let leftNode = QueueElementType.node(left: left,
                                                         right: m - 1,
                                                         axis: nextAxis,
                                                         minLon: minLon,
                                                         maxLon: nextMaxLon,
                                                         minLat: minLat,
                                                         maxLat: nextMaxLat)
                    // second half of the node
                    let rightNode = QueueElementType.node(left: m + 1,
                                                          right: right,
                                                          axis: nextAxis,
                                                          minLon: nextMinLon,
                                                          maxLon: maxLon,
                                                          minLat: nextMinLat,
                                                          maxLat: maxLat)
                    
                    
                    // add child nodes to the queue
                    q.push(QueueElement(dist: leftDist, type: leftNode))
                    q.push(QueueElement(dist: rightDist, type: rightNode))
                }
                
                // fetch closest points from the queue; they're guaranteed to be closer
                // than all remaining points (both individual and those in kd-tree nodes),
                // since each node's distance is a lower bound of distances to its children
                while let peek = q.peek() {
                    if case .point(let id) = peek.type {
                        let candidate = q.pop()!
                        if (candidate.dist > maxHaverSinDist) { return result }
                        result.append((id, geoDist(candidate.dist)))
                        if (result.count == maxResults) { return result }
                    } else {
                        break
                    }
                }
                
                // the next closest kd-tree node
                node = q.pop()?.type
            default:
                print("error not a node")
                break
            }
        }
        return result
    }
    
    // lower bound for distance from a location to points inside a bounding box
    private func boxDist(qLon: Double, qLat: Double, cosLat: Double, minLon: Double, maxLon: Double, minLat: Double, maxLat: Double) -> Double {
        // query point is between minimum and maximum longitudes
        if (qLon >= minLon && qLon <= maxLon) {
            if (qLat < minLat) { return haverSin((qLat - minLat) * .pi / 180) }
            if (qLat > maxLat) { return haverSin((qLat - maxLat) * .pi / 180) }
            return 0
        }
        
        // query point is west or east of the bounding box;
        // calculate the extremum for great circle distance from query point to the closest longitude;
        let haverSinDLon = min(haverSin((qLon - minLon) * .pi / 180), haverSin((qLon - maxLon) * .pi / 180))
        let extremumLat = vertexLat(lat: qLat, haverSinDLon: haverSinDLon)
        
        // if extremum is inside the box, return the distance to it
        if (extremumLat > minLat && extremumLat < maxLat) {
            return haverSinDistPartial(haverSinDLon: haverSinDLon, cosLat1: cosLat, lat1: qLat, lat2: extremumLat)
        }
        
        // otherwise return the distan e to one of the bbox corners (whichever is closest)
        return min(
            haverSinDistPartial(haverSinDLon: haverSinDLon, cosLat1: cosLat, lat1: qLat, lat2: minLat),
            haverSinDistPartial(haverSinDLon: haverSinDLon, cosLat1: cosLat, lat1: qLat, lat2: maxLat)
        )
    }
    
    private func haverSin(_ theta: Double) -> Double {
        let s = sin(theta / 2)
        return s * s
    }
    
    private func haverSinDistPartial(haverSinDLon: Double, cosLat1: Double, lat1: Double, lat2: Double) -> Double {
        return cosLat1 * cos(lat2 * .pi / 180) * haverSinDLon + haverSin((lat1 - lat2) * .pi / 180)
    }
    
    private func haverSinDist(lon1: Double, lat1: Double, lon2: Double, lat2: Double, cosLat1: Double) -> Double {
        let haverSinDLon = haverSin((lon1 - lon2) * .pi / 180)
        return haverSinDistPartial(haverSinDLon: haverSinDLon, cosLat1: cosLat1, lat1: lat1, lat2: lat2)
    }
    
    func cmpDist(lon1: Double, lat1: Double, lon2: Double, lat2: Double) -> Double {
        return haverSinDist(lon1: lon1, lat1: lat1, lon2: lon2, lat2: lat2, cosLat1: cos(lat1 * .pi / 180))
    }
    
    func geoDist(_ h: Double) -> Double {
        return 2 * 6.371e6 * asin(sqrt(h))
    }
    
    private func vertexLat(lat: Double, haverSinDLon: Double) -> Double {
        let cosDLon = 1 - 2 * haverSinDLon
        if (cosDLon <= 0) { return lat > 0 ? 90 : -90 }
        return atan(tan(lat * .pi / 180) / cosDLon) * 180 / .pi
    }
}
