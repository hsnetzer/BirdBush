//
//  BirdBush+NN.swift
//
//  Created by Harry Netzer on 12/17/18.
//  Copyright © 2018 Harry Netzer. All rights reserved.
//

extension BirdBush {
    // returns tuple of nn id and squared distance
    public func nearest(qx: Double, qy: Double) -> (U, Double) {
        return nearestWith(qx: qx,
                           qy: qy,
                           left: 0,
                           right: ids.count-1,
                           axis: 0,
                           bestDist: Double.infinity,
                           bestID: ids[0])
    }

    private func nearestWith(qx: Double, qy: Double, left: Int, right: Int, axis: Int, bestDist: Double, bestID: U) -> (U, Double) {
        var newBest = bestID
        var newBestDist = bestDist

        if right - left <= nodeSize {
            for index in left...right {
                let thisDist = BirdBush.sqDist(coords[2 * index],
                                               coords[2 * index + 1],
                                               qx, qy)
                if thisDist < newBestDist {
                    newBest = ids[index]
                    newBestDist = thisDist
                }
            }
            return (newBest, newBestDist)
        }

        // otherwise find the middle index
        let mid = (left + right) >> 1
        let nextAxis = 1 - axis

        // include the middle item if it's in range
        let xCoord = coords[2 * mid]
        let yCoord = coords[2 * mid + 1]
        let dimDiff = axis == 0 ? qx - xCoord : qy - yCoord

        // queue search in halves that intersect the query
        if dimDiff < 0 {
            (newBest, newBestDist) = nearestWith(qx: qx,
                                                 qy: qy,
                                                 left: left,
                                                 right: mid - 1,
                                                 axis: nextAxis,
                                                 bestDist: bestDist,
                                                 bestID: bestID)
        } else {
            (newBest, newBestDist) = nearestWith(qx: qx,
                                                 qy: qy,
                                                 left: mid + 1,
                                                 right: right,
                                                 axis: nextAxis,
                                                 bestDist: bestDist,
                                                 bestID: bestID)
        }

        if newBestDist > dimDiff * dimDiff {
            let mSqDist = BirdBush.sqDist(xCoord, yCoord, qx, qy)
            if mSqDist < newBestDist {
                newBest = ids[mid]
                newBestDist = mSqDist
            }

            if dimDiff < 0 {
                return nearestWith(qx: qx,
                                   qy: qy,
                                   left: mid + 1,
                                   right: right,
                                   axis: nextAxis,
                                   bestDist: newBestDist,
                                   bestID: newBest)
            } else {
                return nearestWith(qx: qx,
                                   qy: qy,
                                   left: left,
                                   right: mid - 1,
                                   axis: nextAxis,
                                   bestDist: newBestDist,
                                   bestID: newBest)
            }
        }

        return (newBest, newBestDist)
    }
}
