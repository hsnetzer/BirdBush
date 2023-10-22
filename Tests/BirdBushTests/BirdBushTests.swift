//
//  BirdBushTests.swift
//
//  Created by Harry Netzer on 12/13/18.
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

import XCTest
@testable import BirdBush

class BirdBushTests: XCTestCase {
    var index: BirdBush<Int>!
    var points = [[Int]]()
    var ids = [Int]()
    var coords = [Double]()

    override func setUp() {
        loadTestPoints()

        index = BirdBush<Int>(locations: points,
                              nodeSize: 10,
                              getID: { $0[0] },
                              getX: { Double($0[1]) },
                              getY: { Double($0[2]) })
    }
    
    func loadTestPoints() {
        let file = Bundle.module.url(forResource: "points", withExtension: "json")
        guard let data = try? Data(contentsOf: file!) else { return }
        guard let jsonDict = try? JSONSerialization.jsonObject(with:
            data, options: []) as? [String: Any] else { return }
        points = jsonDict["points"] as! [[Int]]
        coords = jsonDict["coords"] as! [Double]
        ids = jsonDict["ids"] as! [Int]
    }

    func test00BuildPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            _ = BirdBush<Int>(
                locations: points,
                getID: { $0[0] },
                getX: { Double($0[1]) },
                getY: { Double($0[2]) })
            print("Built Tree")
        }
    }

    func test03IndexRangeSearch() {
        XCTAssertEqual(
            index.range(minX: 20, minY: 30, maxX: 50, maxY: 70),
            [60, 20, 45, 3, 17, 71, 44, 19, 18, 15, 69, 90, 62, 96, 47, 8, 77, 72]
        )
    }

    func test04IndexRadiusSearch() {
        XCTAssertEqual(index.within(qx: 50, qy: 50, r: 20),
                       [60, 6, 25, 92, 42, 20, 45, 3, 71, 44, 18, 96])
    }

    func test08Codable() {
        guard let coded = try? JSONEncoder().encode(index) else {
            XCTFail("Could not encode")
            return
        }
        guard let bush = try? JSONDecoder().decode(BirdBush<Int>.self, from: coded) else {
            XCTFail("Could not decode")
            return
        }
        self.index = bush
        test03IndexRangeSearch()
        test04IndexRadiusSearch()
    }
}
