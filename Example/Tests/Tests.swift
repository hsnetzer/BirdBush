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
import BirdBush

class BirdBushTests: XCTestCase {
    var index: BirdBush<Int>?
    var bigIndex: BirdBush<Int>?
    var citiesIndex: BirdBush<String>?
    let points = [[0,54,1],[1,97,21],[2,65,35],[3,33,54],[4,95,39],[5,54,3],[6,53,54],[7,84,72],[8,33,34],[9,43,15],[10,52,83],[11,81,23],[12,1,61],[13,38,74],[14,11,91],[15,24,56],[16,90,31],[17,25,57],[18,46,61],[19,29,69],[20,49,60],[21,4,98],[22,71,15],[23,60,25],[24,38,84],[25,52,38],[26,94,51],[27,13,25],[28,77,73],[29,88,87],[30,6,27],[31,58,22],[32,53,28],[33,27,91],[34,96,98],[35,93,14],[36,22,93],[37,45,94],[38,18,28],[39,35,15],[40,19,81],[41,20,81],[42,67,53],[43,43,3],[44,47,66],[45,48,34],[46,46,12],[47,32,38],[48,43,12],[49,39,94],[50,88,62],[51,66,14],[52,84,30],[53,72,81],[54,41,92],[55,26,4],[56,6,76],[57,47,21],[58,57,70],[59,71,82],[60,50,68],[61,96,18],[62,40,31],[63,78,53],[64,71,90],[65,32,14],[66,55,6],[67,32,88],[68,62,32],[69,21,67],[70,73,81],[71,44,64],[72,29,50],[73,70,5],[74,6,22],[75,68,3],[76,11,23],[77,20,42],[78,21,73],[79,63,86],[80,9,40],[81,99,2],[82,99,76],[83,56,77],[84,83,6],[85,21,72],[86,78,30],[87,75,53],[88,41,11],[89,95,20],[90,30,38],[91,96,82],[92,65,48],[93,33,18],[94,87,28],[95,10,10],[96,40,34],[97,10,20],[98,47,29],[99,46,78]]
    let ids = [97, 74, 95, 30, 77, 38, 76, 27, 80, 55, 72, 90, 88, 48, 43, 46, 65, 39, 62, 93, 9, 96, 47, 8, 3, 12, 15, 14, 21, 41, 36, 40, 69, 56, 85, 78, 17, 71, 44, 19, 18, 13, 99, 24, 67, 33, 37, 49, 54, 57, 98, 45, 23, 31, 66, 68, 0, 32, 5, 51, 75, 73, 84, 35, 81, 22, 61, 89, 1, 11, 86, 52, 94, 16, 2, 6, 25, 92, 42, 20, 60, 58, 83, 79, 64, 10, 59, 53, 26, 87, 4, 63, 50, 7, 28, 82, 70, 29, 34, 91]
    let coords = [10.0, 20.0, 6.0, 22.0, 10.0, 10.0, 6.0, 27.0, 20.0, 42.0, 18.0, 28.0, 11.0, 23.0, 13.0, 25.0, 9.0, 40.0, 26.0, 4.0, 29.0, 50.0, 30.0, 38.0, 41.0, 11.0, 43.0, 12.0, 43.0, 3.0, 46.0, 12.0, 32.0, 14.0, 35.0, 15.0, 40.0, 31.0, 33.0, 18.0, 43.0, 15.0, 40.0, 34.0, 32.0, 38.0, 33.0, 34.0, 33.0, 54.0, 1.0, 61.0, 24.0, 56.0, 11.0, 91.0, 4.0, 98.0, 20.0, 81.0, 22.0, 93.0, 19.0, 81.0, 21.0, 67.0, 6.0, 76.0, 21.0, 72.0, 21.0, 73.0, 25.0, 57.0, 44.0, 64.0, 47.0, 66.0, 29.0, 69.0, 46.0, 61.0, 38.0, 74.0, 46.0, 78.0, 38.0, 84.0, 32.0, 88.0, 27.0, 91.0, 45.0, 94.0, 39.0, 94.0, 41.0, 92.0, 47.0, 21.0, 47.0, 29.0, 48.0, 34.0, 60.0, 25.0, 58.0, 22.0, 55.0, 6.0, 62.0, 32.0, 54.0, 1.0, 53.0, 28.0, 54.0, 3.0, 66.0, 14.0, 68.0, 3.0, 70.0, 5.0, 83.0, 6.0, 93.0, 14.0, 99.0, 2.0, 71.0, 15.0, 96.0, 18.0, 95.0, 20.0, 97.0, 21.0, 81.0, 23.0, 78.0, 30.0, 84.0, 30.0, 87.0, 28.0, 90.0, 31.0, 65.0, 35.0, 53.0, 54.0, 52.0, 38.0, 65.0, 48.0, 67.0, 53.0, 49.0, 60.0, 50.0, 68.0, 57.0, 70.0, 56.0, 77.0, 63.0, 86.0, 71.0, 90.0, 52.0, 83.0, 71.0, 82.0, 72.0, 81.0, 94.0, 51.0, 75.0, 53.0, 95.0, 39.0, 78.0, 53.0, 88.0, 62.0, 84.0, 72.0, 77.0, 73.0, 99.0, 76.0, 73.0, 81.0, 88.0, 87.0, 96.0, 98.0, 96.0, 82.0]
    struct City {
        let name: String
        let lat: Double
        let lon: Double
    }
    var cities = Array<City>()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        do {
            let testBundle = Bundle(for: type(of: self))
            let file = testBundle.url(forResource: "all-the-cities", withExtension: "json")
            XCTAssertNotNil(file)
            let data = try Data(contentsOf: file!)
            let jsonResponse = try JSONSerialization.jsonObject(with:
            data, options: []) as! [[String: Any]]
            for dic in jsonResponse {
                let lat = round((dic["lat"] as! Double) * 1e5) / 1e5
                let lon = round((dic["lon"] as! Double) * 1e5) / 1e5
                cities.append(City(name: dic["name"] as! String, lat: lat, lon: lon))
            }
        } catch {
            print("error")
        }
        citiesIndex = BirdBush<String>(locations: cities, getID: { return $0.name }, getX: { return $0.lon }, getY: { return $0.lat })
        
        var bigArray = [[Double]]()
        for i in 1...10000 {
            bigArray.append([Double(i), Double.random(in: 0...100), Double.random(in: 0...100)])
        }
        bigIndex = BirdBush<Int>(locations: bigArray, nodeSize: 64, getID: { return Int($0[0]) }, getX: { return $0[1] }, getY: { return $0[2] })
        
        index = BirdBush<Int>(locations: points, nodeSize: 10, getID: { return $0[0] }, getX: { return Double($0[1]) }, getY: { return Double($0[2]) })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBuildPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let _ = BirdBush<Int>(locations: points, getID: { return $0[0] }, getX: { return Double($0[1]) }, getY: { return Double($0[2]) })
            print("Built Tree")
        }
    }
    
    func testSmartGeoPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 1...100 {
                let randLon = Double.random(in: -180...180)
                let randLat = Double.random(in: -90...90)
                let _ = citiesIndex?.around(lon: randLon, lat: randLat, maxResults: 1)
            }
        }
    }
    
    func testBruteGeoPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 1...100 {
                let randLon = Double.random(in: -180...180)
                let randLat = Double.random(in: -90...90)
                let _ = bruteGeoNN(qx: randLon, qy: randLat, index: citiesIndex!)
            }
        }
    }
    
    func testIndexRangeSearch() {
        XCTAssertEqual(index?.range(minX: 20, minY: 30, maxX: 50, maxY: 70), [60,20,45,3,17,71,44,19,18,15,69,90,62,96,47,8,77,72])
    }
    
    func testIndexRadiusSearch() {
        XCTAssertEqual(index?.within(qx: 50, qy: 50, r: 20), [60,6,25,92,42,20,45,3,71,44,18,96])
    }
    
    func testBigIndexRandomPointNN() {
        for _ in 1...10000 {
            let randX = Double.random(in: 0...100)
            let randY = Double.random(in: 0...100)
            let nn = bigIndex!.nearest(qx: randX, qy: randY)
            XCTAssertEqual(nn.0, bruteNN(qx: randX, qy: randY, index: bigIndex!).0)
        }
    }
    
    func testCitiesGeoNN() {
        for i in 1...1000 {
            let randLon = Double.random(in: -180...180)
            let randLat = Double.random(in: -90...90)
            print("\(i) randLat: \(randLat), randlon: \(randLon)")
            let nn = citiesIndex?.around(lon: randLon, lat: randLat, maxResults: 1).first
            let brute = bruteGeoNN(qx: randLon, qy: randLat, index: citiesIndex!)
            print("tree dist: \(nn!.1) for \(nn!.0)")
            print("brute dist: \(brute.1) for \(brute.0)")
            XCTAssertEqual(nn!.0, brute.0)
        }
    }
    
    func bruteNN<T>(qx: Double, qy: Double, index: BirdBush<T>) -> (T, Double) {
        var bestDist = Double.greatestFiniteMagnitude
        var bestPoint = index.ids[0]
        for i in 0..<index.ids.count {
            let thisDist = sqDist(index.coords[2*i], index.coords[2*i+1], qx, qy)
            if thisDist < bestDist {
                bestDist = thisDist
                bestPoint = index.ids[i]
            }
        }
        return (bestPoint, bestDist)
    }
    
    func bruteGeoNN<T>(qx: Double, qy: Double, index: BirdBush<T>) -> (T, Double) {
        var bestDist = 12.742e6
        var bestPoint = index.ids[0]
        for i in 0..<index.ids.count {
            let thisDist = cmpDist(lon1: qx, lat1: qy, lon2: index.coords[2*i], lat2: index.coords[2*i+1])
            if thisDist < bestDist {
                bestDist = thisDist
                bestPoint = index.ids[i]
            }
        }
        return (bestPoint, geoDist(bestDist))
    }
    
    func sqDist(_ ax: Double, _ ay: Double, _ bx: Double, _ by: Double) -> Double {
        let dx = (ax - bx)
        let dy = (ay - by)
        return dx * dx + dy * dy
    }
}

extension BirdBushTests {
    // for testing
    func cmpDist(lon1: Double, lat1: Double, lon2: Double, lat2: Double) -> Double {
        return haverSinDist(lon1: lon1, lat1: lat1, lon2: lon2, lat2: lat2, cosLat1: cos(lat1 * .pi / 180))
    }
    
    // range: [0, 1]. hav(θ) = hav(-θ)
    func hav(_ θ: Double) -> Double {
        let s = sin(θ / 2)
        return s * s
    }
    
    func haverSinDistPartial(haverSinDLon: Double, cosLat1: Double, lat1: Double, lat2: Double) -> Double {
        return cosLat1 * cos(lat2 * .pi / 180) * haverSinDLon + hav((lat1 - lat2) * .pi / 180)
    }
    
    func haverSinDist(lon1: Double, lat1: Double, lon2: Double, lat2: Double, cosLat1: Double) -> Double {
        let haverSinDLon = hav((lon1 - lon2) * .pi / 180)
        return haverSinDistPartial(haverSinDLon: haverSinDLon, cosLat1: cosLat1, lat1: lat1, lat2: lat2)
    }
    
    // public for testing
    func geoDist(_ h: Double) -> Double {
        return 2 * 6.371e6 * asin(sqrt(h))
    }
}
