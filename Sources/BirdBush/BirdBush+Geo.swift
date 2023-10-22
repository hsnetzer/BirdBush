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

import SwiftPriorityQueue
import Numerics

extension BirdBush {
    struct QueueElement: Comparable {
        static func < (lhs: QueueElement, rhs: QueueElement) -> Bool {
            return lhs.dist < rhs.dist
        }

        static func == (lhs: QueueElement, rhs: QueueElement) -> Bool {
            return lhs.dist == rhs.dist
        }

        let dist: Double
        let payload: QueuePayload
    }

    enum QueuePayload {
        case point(id: U)
        case node(left: Int, right: Int, axis: Int, minLon: Double, maxLon: Double, minLat: Double, maxLat: Double)
    }

    /**
     Finds the nearest neighors to a point on the earth's surface.

     - Parameters:
        - lon: The longitude of the query point.
        - lat: The latitude of the query point.
        - maxResults: The maximum number of neighbors to return.
        - maxDistance: The maximum distance in meters of neighbors to return.

     - Returns: An array of `(U, Double)` representing the ids and distances
     of the nearest neighbors, in ascending order of distance.
    */
    public func around(lon: Double,
                       lat: Double,
                       maxResults: Int = .max,
                       maxDistance: Double = .greatestFiniteMagnitude) -> [(U, Double)] {
        var maxHaverSinDist = 1.0, result = [(U, Double)]()
        guard ids.count > 0 else { return result }

        if maxDistance != .greatestFiniteMagnitude {
            maxHaverSinDist = .hav(maxDistance / 6.371e6)
        }

        // a distance-sorted priority queue that will contain both points and kd-tree nodes
        var queue = PriorityQueue<QueueElement>(ascending: true)

        // an object that represents the top kd-tree node (the whole Earth)
        var node: QueuePayload? = .node(left: 0,
                                        right: ids.count - 1,
                                        axis: 0,
                                        minLon: -180,
                                        maxLon: 180,
                                        minLat: -90,
                                        maxLat: 90)

        let cosLat = Double.cos(lat * .pi / 180)

        while let noder = node {
            switch noder {
            case let .node(left, right, axis, minLon, maxLon, minLat, maxLat):
                if right - left <= nodeSize { // leaf node

                    // add all points of the leaf node to the queue
                    for index in left...right {
                        let item = ids[index]
                        let dist = BirdBush.haverSinDist(lon1: lon, lat1: lat,
                                                         lon2: coords[2 * index],
                                                         lat2: coords[2 * index + 1],
                                                         cosLat1: cosLat)
                        queue.push(QueueElement(dist: dist, payload: .point(id: item)))
                    }
                } else { // not a leaf node (has child nodes)

                    let mid = (left + right) / 2 // middle index
                    let midLon = coords[2 * mid]
                    let midLat = coords[2 * mid + 1]

                    // add middle point to the queue
                    let item = ids[mid]
                    let dist = BirdBush.haverSinDist(lon1: lon,
                                                     lat1: lat,
                                                     lon2: midLon,
                                                     lat2: midLat,
                                                     cosLat1: cosLat)
                    queue.push(QueueElement(dist: dist, payload: .point(id: item)))

                    let nextAxis = 1 - axis

                    let nextMinLon = axis == 0 ? midLon : minLon
                    let nextMaxLon = axis == 0 ? midLon : maxLon
                    let nextMinLat = axis == 1 ? midLat : minLat
                    let nextMaxLat = axis == 1 ? midLat : maxLat

                    let leftDist = BirdBush.boxDist(qLon: lon,
                                                    qLat: lat,
                                                    cosLat: cosLat,
                                                    minLon: minLon,
                                                    maxLon: nextMaxLon,
                                                    minLat: minLat,
                                                    maxLat: nextMaxLat)
                    let rightDist = BirdBush.boxDist(qLon: lon,
                                                     qLat: lat,
                                                     cosLat: cosLat,
                                                     minLon: nextMinLon,
                                                     maxLon: maxLon,
                                                     minLat: nextMinLat,
                                                     maxLat: maxLat)

                    // first half of the node
                    let leftNode = QueuePayload.node(left: left,
                                                     right: mid - 1,
                                                     axis: nextAxis,
                                                     minLon: minLon,
                                                     maxLon: nextMaxLon,
                                                     minLat: minLat,
                                                     maxLat: nextMaxLat)
                    // second half of the node
                    let rightNode = QueuePayload.node(left: mid + 1,
                                                      right: right,
                                                      axis: nextAxis,
                                                      minLon: nextMinLon,
                                                      maxLon: maxLon,
                                                      minLat: nextMinLat,
                                                      maxLat: maxLat)

                    // add child nodes to the queue
                    queue.push(QueueElement(dist: leftDist, payload: leftNode))
                    queue.push(QueueElement(dist: rightDist, payload: rightNode))
                }

                // fetch closest points from the queue; they're guaranteed to be closer
                // than all remaining points (both individual and those in kd-tree nodes),
                // since each node's distance is a lower bound of distances to its children
                while let peek = queue.peek() {
                    if case .point(let id) = peek.payload {
                        let candidate = queue.pop()!
                        if candidate.dist > maxHaverSinDist { return result }
                        result.append((id, candidate.dist))
                        if result.count == maxResults { return result }
                    } else {
                        break
                    }
                }

                // the next closest kd-tree node
                node = queue.pop()?.payload
            default:
                print("error not a node")
            }
        }
        return result
    }

    // lower bound for distance from a location to points inside a bounding box
    private static func boxDist(qLon: Double,
                                qLat: Double,
                                cosLat: Double,
                                minLon: Double,
                                maxLon: Double,
                                minLat: Double,
                                maxLat: Double) -> Double {
        // query point is between minimum and maximum longitudes of the box
        if qLon >= minLon && qLon <= maxLon {
            if qLat < minLat { return .hav((qLat - minLat) * .pi / 180) }
            if qLat > maxLat { return .hav((qLat - maxLat) * .pi / 180) }
            return 0
        }

        // query point is west or east of the bounding box;
        // calculate the extremum for great circle distance from query point to the closest longitude;
        let haverSinDLon = min(
            Double.hav((qLon - minLon) * .pi / 180),
            Double.hav((qLon - maxLon) * .pi / 180))
        let extremumLat = vertexLat(lat: qLat, haverSinDLon: haverSinDLon)

        // if extremum is inside the box, return the distance to it
        if extremumLat > minLat && extremumLat < maxLat {
            return haverSinDistPartial(haverSinDLon: haverSinDLon,
                                       cosLat1: cosLat,
                                       lat1: qLat,
                                       lat2: extremumLat)
        }

        // otherwise return the distance to one of the bbox corners (whichever is closest)
        return min(
            haverSinDistPartial(haverSinDLon: haverSinDLon,
                                cosLat1: cosLat,
                                lat1: qLat, lat2: minLat),
            haverSinDistPartial(haverSinDLon: haverSinDLon,
                                cosLat1: cosLat,
                                lat1: qLat, lat2: maxLat)
        )
    }

    private static func haverSinDistPartial(haverSinDLon: Double,
                                            cosLat1: Double,
                                            lat1: Double,
                                            lat2: Double) -> Double {
        cosLat1
            * .cos(lat2 * .pi / 180)
            * haverSinDLon
            + .hav((lat1 - lat2) * .pi / 180)
    }

    static func haverSinDist(lon1: Double, lat1: Double, lon2: Double, lat2: Double, cosLat1: Double) -> Double {
        haverSinDistPartial(
          haverSinDLon: .hav((lon1 - lon2) * .pi / 180),
            cosLat1: cosLat1,
            lat1: lat1,
            lat2: lat2
        )
    }

    /**
     Calculate the central angle in radians of a given haversine. The mathematical domain
     of this function is [0, 1] and the range is [0, π]. This function increases monotonically.

     - parameter hav: The haversine to calculate the central angle from.
    */
    public func centralAngle(_ hav: Double) -> Double {
        2 * .asin(.sqrt(hav))
    }

    private static func vertexLat(lat: Double, haverSinDLon: Double) -> Double {
        let cosDLon = 1 - 2 * haverSinDLon
        if cosDLon <= 0 { return lat > 0 ? 90 : -90 }
        return .atan(.tan(lat * .pi / 180) / cosDLon) * 180 / .pi
    }

    /// A fast function that increases monotonically with distance, at least locally. Useful for testing. 
    static func cmpDist(lon1: Double, lat1: Double, lon2: Double, lat2: Double) -> Double {
        haverSinDist(lon1: lon1,
                     lat1: lat1,
                     lon2: lon2,
                     lat2: lat2,
                     cosLat1: .cos(lat1 * .pi / 180))
    }
}

extension Double {
  /// Sine squared of theta over 2
  ///
  /// - returns: Values [0, 1] inclusive
  /// - parameter theta: Radians
  static func hav(_ theta: Double) -> Double {
      let sine = Double.sin(theta / 2)
      return sine * sine
  }
}
