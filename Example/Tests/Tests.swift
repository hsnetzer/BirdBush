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
    var index: BirdBush<Int>?
    var bigIndex: BirdBush<Double>?
    var citiesIndex: BirdBush<String>?
    
    var points = [[Int]]()
    var ids = [Int]()
    var coords = [Double]()
    var cities = [City]()
    var bigArray = [[Double]]() // Keep for comparison to brute test
    
    struct City {
        let name: String
        let lat: Double
        let lon: Double

        init(dic: [String: Any]) {
            name = dic["name"] as! String
            lat = dic["lat"] as! Double
            lon = dic["lon"] as! Double
        }
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        for count in 1...10000 {
            bigArray.append([Double(count), Double.random(in: 0...100), Double.random(in: 0...100)])
        }
        bigIndex = BirdBush<Double>(
            locations: bigArray,
            nodeSize: 64,
            getID: { $0[0] },
            getX: { $0[1] },
            getY: { $0[2] })

        loadPoints()

        index = BirdBush<Int>(
            locations: points,
            nodeSize: 10,
            getID: { $0[0] },
            getX: { Double($0[1]) },
            getY: { Double($0[2]) })
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func loadPoints() {
        let testBundle = Bundle(for: type(of: self))
        let file = testBundle.url(forResource: "points", withExtension: "json")
        XCTAssertNotNil(file)
        guard let data = try? Data(contentsOf: file!) else { return }
        guard let jsonDict = try? JSONSerialization.jsonObject(with:
            data, options: []) as? [String: Any] else { return }
        points = jsonDict["points"] as! [[Int]]
        coords = jsonDict["coords"] as! [Double]
        ids = jsonDict["ids"] as! [Int]
    }

    func buildCitiesIndex() {
        let testBundle = Bundle(for: type(of: self))
        let file = testBundle.url(forResource: "all-the-cities", withExtension: "json")
        XCTAssertNotNil(file)
        guard let data = try? Data(contentsOf: file!) else { return }
        guard let jsonResponse = try? JSONSerialization.jsonObject(with:
            data, options: []) as? [[String: Any]] else { return }
        cities = jsonResponse.map(City.init)
        citiesIndex = BirdBush<String>(
            locations: cities,
            getID: { $0.name },
            getX: { $0.lon },
            getY: { $0.lat })
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

    func test01SmartGeoPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 1...10 {
                let randLon = Double.random(in: -180...180)
                let randLat = Double.random(in: -90...90)
                _ = citiesIndex?.around(lon: randLon, lat: randLat, maxResults: 10)
            }
        }
    }

    func test02BruteGeoPerformance() {
        buildCitiesIndex()
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 1...10 {
                let randLon = Double.random(in: -180...180)
                let randLat = Double.random(in: -90...90)
                _ = bruteGeoNN(
                    queryX: randLon,
                    queryY: randLat,
                    index: cities,
                    getX: { $0.lon },
                    getY: { $0.lat },
                    getID: { $0.name },
                    maxResults: 10)
            }
        }
    }

    func test03IndexRangeSearch() {
        XCTAssertEqual(
            index?.range(minX: 20, minY: 30, maxX: 50, maxY: 70),
            [60, 20, 45, 3, 17, 71, 44, 19, 18, 15, 69, 90, 62, 96, 47, 8, 77, 72]
        )
    }

    func test04IndexRadiusSearch() {
        XCTAssertEqual(index?.within(qx: 50, qy: 50, r: 20),
                       [60, 6, 25, 92, 42, 20, 45, 3, 71, 44, 18, 96])
    }

    func test05BigIndexRandomPointNN() {
        for _ in 1...1000 {
            let randX = Double.random(in: 0...100)
            let randY = Double.random(in: 0...100)
            let nearest = bigIndex!.nearest(qx: randX, qy: randY)
            let brute = bruteNN(queryX: randX,
                                queryY: randY,
                                index: bigArray,
                                getX: { $0[1] },
                                getY: { $0[2] },
                                getID: { $0[0] })
            XCTAssertEqual(nearest.0, brute.0)
            XCTAssertEqual(nearest.1, brute.1)
        }
    }

    func test06CitiesGeoNN() {
        buildCitiesIndex()
        for _ in 1...20 {
            let randLon = Double.random(in: -180...180)
            let randLat = Double.random(in: -90...90)
            let nearest = citiesIndex!.around(lon: randLon,
                                              lat: randLat,
                                              maxResults: 10)
            let brute = bruteGeoNN(queryX: randLon,
                                   queryY: randLat,
                                   index: cities,
                                   getX: { $0.lon },
                                   getY: { $0.lat },
                                   getID: { $0.name },
                                   maxResults: 10)
            XCTAssertEqual(nearest.count, brute.count)
            for ind in 0..<nearest.count {
                XCTAssertEqual(nearest[ind].1, brute[ind].1)
                XCTAssertEqual(nearest[ind].0, brute[ind].0)
            }
        }
    }

    func test07GeoVsNon() {
        buildCitiesIndex()
        guard let citiesIndex = citiesIndex else {
            XCTFail("No cities index")
            return
        }

        let wiggle = 0.1

        var stdDev = 0.0
        var count = 0.0

        for _ in 0...999 {
            guard let random = cities.randomElement() else {
                continue
            }
            guard (-180.0+wiggle...180.0-wiggle).contains(random.lat) else {
                print("Strange city...")
                continue
            }
//            print("Longitude of \(random.name): \(random.lon)")
            let randLat = random.lat + Double.random(in: -wiggle...wiggle)
            let randLon = random.lon + Double.random(in: -wiggle...wiggle)

            guard let nnGeo = citiesIndex.around(lon: randLon, lat: randLat, maxResults: 1).first?.0 else {
                continue
            }
            let nearest = citiesIndex.nearest(qx: randLon, qy: randLat).0
            if nnGeo != nearest {
                let cityGeo = cities.first(where: { $0.name == nnGeo })!
                let cityNon = cities.first(where: { $0.name == nearest })!

                let distGeo = citiesIndex.centralAngle(cmpDist(lon1: cityGeo.lon,
                                                               lat1: cityGeo.lat,
                                                               lon2: randLon,
                                                               lat2: randLat))
                let distNN = citiesIndex.centralAngle(cmpDist(lon1: cityNon.lon,
                                                              lat1: cityNon.lat,
                                                              lon2: randLon,
                                                              lat2: randLat))
                stdDev += abs(distGeo - distNN)
                count += 1
            }
        }

        print("Deviation in KM:")
        print(stdDev / count * 6.371e3)
    }

    func test08Codable() {
        guard let index = index else {
            XCTFail("No index")
            return
        }
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

//    func nonCodableBush() {
//        let code = try? JSONEncoder().encode(BirdBush<Any>(
//            locations: [1.0],
//            getID: { return $0 },
//            getX: { return $0 },
//            getY: { return $0 })) // Buildtime err
//    }

    func bruteGeoNN<T, U>(
        queryX: Double,
        queryY: Double,
        index: [T],
        getX: (T) -> Double,
        getY: (T) -> Double,
        getID: (T) -> U,
        maxResults: Int = .max,
        maxDistance: Double = .greatestFiniteMagnitude) -> [(U, Double)] {

        let maxHav = BirdBush<Any>.hav(maxDistance / 6.371e6)
        var filtered = maxDistance > 2e7 ? index : index.filter { element in
            return cmpDist(lon1: getX(element), lat1: getY(element), lon2: queryX, lat2: queryY) < maxHav
        }

        var ret = [(U, Double)]()
        for neighborNum in 0..<maxResults {
            var bestElement = filtered[neighborNum]
            var bestDist = cmpDist(lon1: getX(bestElement),
                                   lat1: getY(bestElement),
                                   lon2: queryX,
                                   lat2: queryY)
            for ind in neighborNum..<filtered.count {
                let thisDist = cmpDist(lon1: getX(filtered[ind]), lat1: getY(filtered[ind]), lon2: queryX, lat2: queryY)
                if thisDist < bestDist {
                    (bestElement, bestDist) = (filtered[ind], thisDist)
                    filtered.swapAt(ind, neighborNum)
                }
            }
            ret.insert((getID(bestElement), bestDist), at: ret.firstIndex(where: { $0.1 > bestDist }) ?? ret.endIndex)
        }
        return ret
    }

    func bruteNN<T, U>(queryX: Double,
                       queryY: Double,
                       index: [T],
                       getX: (T) -> Double,
                       getY: (T) -> Double,
                       getID: (T) -> U) -> (U, Double) {
        var bestPoint = index.first!
        var bestDist = BirdBush<Any>.sqDist(queryX, queryY, getX(bestPoint), getY(bestPoint))
        for element in index {
            let thisDist = BirdBush<Any>.sqDist(queryX, queryY, getX(element), getY(element))
            if thisDist < bestDist {
                bestDist = thisDist
                bestPoint = element
            }
        }
        return (getID(bestPoint), bestDist)
    }

    func cmpDist(lon1: Double, lat1: Double, lon2: Double, lat2: Double) -> Double {
        return BirdBush<Any>.haverSinDist(
            lon1: lon1,
            lat1: lat1,
            lon2: lon2,
            lat2: lat2,
            cosLat1: cos(lat1 * .pi / 180)
        )
    }
}
