//
//  CitiesTests.swift
//  BirdBush_Tests
//
//  Created by Harry Netzer on 10/10/20.
//

import XCTest
import SwiftPriorityQueue
@testable import BirdBush

class CitiesTests: XCTestCase {
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

    func getCitiesData() throws -> [City]? {
        let file = Bundle.module.url(forResource: "all-the-cities", withExtension: "json")
        let data = try Data(contentsOf: file!)
        let jsonResponse = try JSONSerialization
            .jsonObject(with: data, options: []) as? [[String: Any]]
        return jsonResponse?.map(City.init)
    }

    func buildCitiesIndex(cities: [City]?) -> BirdBush<String>? {
        guard let cities = cities else { return nil }
        return BirdBush<String>(locations: cities,
                                getID: { $0.name },
                                getX: { $0.lon },
                                getY: { $0.lat })
    }

    func test01AroundPerformance() throws {
        guard let citiesTree = buildCitiesIndex(cities: try getCitiesData()) else { XCTFail(); return }
        self.measure {
            for _ in 1...10 {
                _ = citiesTree.around(lon: .random(in: -180...180), lat: .random(in: -90...90), maxResults: 10)
            }
        }
    }

    func test02BruteGeoPerformance() throws {
        guard let citiesTree = buildCitiesIndex(cities: try getCitiesData()) else { XCTFail(); return }
        self.measure {
            for _ in 1...10 {
                _ = citiesTree.bruteNN(queryLon: .random(in: -180...180),
                                       queryLat: .random(in: -90...90),
                                       maxResults: 10,
                                       distFunc: BirdBush<Any>.cmpDist)
            }
        }
    }

    func test06CitiesGeoNN() throws {
        let cities = try getCitiesData()
        let citiesIndex = buildCitiesIndex(cities: cities)
        for _ in 1...20 {
            let randLon = Double.random(in: -180...180)
            let randLat = Double.random(in: -90...90)
            let nearest = citiesIndex!.around(lon: randLon,
                                              lat: randLat,
                                              maxResults: 10)
            let brute = citiesIndex!.bruteNN(queryLon: randLon, queryLat: randLat, maxResults: 10, distFunc: BirdBush<Any>.cmpDist)
            for ind in 0..<nearest.count {
                XCTAssertEqual(nearest[ind].1, brute[ind].1)
                XCTAssertEqual(nearest[ind].0, brute[ind].0)
            }
        }
    }

    func test07GeoVsNon() throws {
        guard let cities = try getCitiesData(), let citiesIndex = buildCitiesIndex(cities: cities) else {
            XCTFail("No cities index")
            return
        }

        let wiggle = 0.1

        var stdDev = 0.0
        var count = 0.0

        for _ in 0...999 {
            let randomCity = cities.randomElement()!
            let randLat = randomCity.lat + .random(in: -wiggle..<wiggle)
            XCTAssert(-90...90 ~= randLat)
            let randLon = randomCity.lon + .random(in: -wiggle..<wiggle)

            let nnGeo = citiesIndex.around(lon: randLon, lat: randLat, maxResults: 1).first!.0
            let nearest = citiesIndex.nearest(qx: randLon, qy: randLat).0
            if nnGeo != nearest {
                let cityGeo = cities.first(where: { $0.name == nnGeo })!
                let cityNon = cities.first(where: { $0.name == nearest })!

                let distGeo = citiesIndex.centralAngle(BirdBush<Any>.cmpDist(lon1: cityGeo.lon,
                                                                             lat1: cityGeo.lat,
                                                                             lon2: randLon,
                                                                             lat2: randLat))
                let distNN = citiesIndex.centralAngle(BirdBush<Any>.cmpDist(lon1: cityNon.lon,
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

    func test09BuildCitiesIndex() throws {
        let data = try getCitiesData()
        measure {
            _ = buildCitiesIndex(cities: data)
        }
    }
}

extension BirdBush {
    typealias DistanceFunction = (Double, Double, Double, Double) -> Double

    func bruteNN(queryLon: Double, queryLat: Double, maxResults: Int, maxDist: Double = .greatestFiniteMagnitude, distFunc: DistanceFunction) -> [(U, Double)] {
        var queue = PriorityQueue<QueueElement>(ascending: true)
        for index in 0..<ids.count {
            let lon = coords[index * 2]
            let lat = coords[index * 2 + 1]
            let dist = distFunc(lon, lat, queryLon, queryLat)
            guard dist <= maxDist else { continue }
            queue.push(QueueElement(dist: dist, payload: .point(id: ids[index])))
        }

        var result = [(U, Double)]()
        while let peek = queue.peek() {
            if case .point(let id) = peek.payload {
                let candidate = queue.pop()!
                if candidate.dist > maxDist { return result }
                result.append((id, candidate.dist))
                if result.count == maxResults { return result }
            } else {
                break
            }
        }
        return []
    }
}
