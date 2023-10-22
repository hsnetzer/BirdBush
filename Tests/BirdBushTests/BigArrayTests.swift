//
//  BigArrayTests.swift
//  BirdBush_Tests
//
//  Created by Harry Netzer on 10/10/20.
//

import XCTest
@testable import BirdBush

class BigArrayTests: XCTestCase {
    var bigIndex: BirdBush<Double>!

    override func setUpWithError() throws {
        let bigArray = (0...9990).map { [Double($0), .random(in: -100...100), .random(in: -100...100)] }
            + [[9991, 83.96721, 34.74901]]
        bigIndex = BirdBush<Double>(locations: bigArray,
                                    nodeSize: 64,
                                    getID: { $0[0] },
                                    getX: { $0[1] },
                                    getY: { $0[2] })

    }

    func test05BigIndexRandomPointNN() {
        for _ in 1...1000 {
            let randX = Double.random(in: 0...100)
            let randY = Double.random(in: 0...100)
            let nearest = bigIndex.nearest(qx: randX, qy: randY)
            let brute = bigIndex.bruteNN(queryLon: randX, queryLat: randY, maxResults: 1, distFunc: BirdBush<Any>.sqDist).first!
            XCTAssertEqual(nearest.0, brute.0)
            XCTAssertEqual(nearest.1, brute.1)
        }
    }

    func testAroundDistance() {
        let neighbor = bigIndex.around(lon: 83.96498, lat: 34.75539, maxResults: 1, maxDistance: 100000).first!
        XCTAssertEqual(neighbor.0, 9991)
        let dist = bigIndex.centralAngle(neighbor.1) * 6.371e6
        XCTAssertEqual(dist, 738.0985242616835)
    }
}
