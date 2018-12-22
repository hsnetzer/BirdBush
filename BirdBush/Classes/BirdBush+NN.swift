//
//  BirdBush+NN.swift
//
//  Created by Harry Netzer on 12/17/18.
//  Copyright © 2018 Harry Netzer. All rights reserved.
//

import Foundation

public extension BirdBush {
    func nearest(qx: Double, qy: Double) -> (U, Double) {
        return nearestWith(qx: qx, qy: qy, left: 0, right: ids.count-1, axis: 0, bestDist: Double.infinity, bestID: ids[0])
    }
    
    private func nearestWith(qx: Double, qy: Double, left: Int, right: Int, axis: Int, bestDist: Double, bestID: U) -> (U, Double) {
        var newBest = bestID
        var newBestDist = bestDist
        
        if (right - left <= nodeSize) {
            for i in left...right {
                let thisDist = sqDist(coords[2 * i], coords[2 * i + 1], qx, qy)
                if (thisDist < newBestDist) {
                    newBest = ids[i]
                    newBestDist = thisDist
                }
            }
            return (newBest, newBestDist)
        }
        
        // otherwise find the middle index
        let m = (left + right) >> 1
        let nextAxis = 1 - axis
        
        // include the middle item if it's in range
        let x = coords[2 * m]
        let y = coords[2 * m + 1]
        let dimDiff = axis == 0 ? qx - x : qy - y
        
        // queue search in halves that intersect the query
        if dimDiff < 0 {
            (newBest, newBestDist) = nearestWith(qx: qx, qy: qy, left: left, right: m-1, axis: nextAxis, bestDist: bestDist, bestID: bestID)
        } else {
            (newBest, newBestDist) = nearestWith(qx: qx, qy: qy, left: m+1, right: right, axis: nextAxis, bestDist: bestDist, bestID: bestID)
        }
        
        if newBestDist > dimDiff * dimDiff {
            let mSqDist = sqDist(x, y, qx, qy)
            if mSqDist < newBestDist {
                newBest = ids[m]
                newBestDist = mSqDist
            }
            
            if dimDiff < 0 {
                return nearestWith(qx: qx, qy: qy, left: m+1, right: right, axis: nextAxis, bestDist: newBestDist, bestID: newBest)
            } else {
                return nearestWith(qx: qx, qy: qy, left: left, right: m-1, axis: nextAxis, bestDist: newBestDist, bestID: newBest)
            }
        }
        
        return (newBest, newBestDist)
    }
}
