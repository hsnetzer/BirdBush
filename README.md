# BirdBush

[![CI Status](https://img.shields.io/travis/hsnetzer/BirdBush.svg?style=flat)](https://travis-ci.org/hsnetzer/BirdBush)
[![Version](https://img.shields.io/cocoapods/v/BirdBush.svg?style=flat)](https://cocoapods.org/pods/BirdBush)
[![License](https://img.shields.io/cocoapods/l/BirdBush.svg?style=flat)](https://cocoapods.org/pods/BirdBush)
[![Platform](https://img.shields.io/cocoapods/p/BirdBush.svg?style=flat)](https://cocoapods.org/pods/BirdBush)

Swift implementation of a 2D binary space partitioning tree. The data is stored in a pair of arrays, making serialization very straightforward. Besides the classic k-d tree queries, BirdBush also implements a geographical nearest neighbor search based on [geokdbush](https://github.com/mourner/geokdbush). 

For a mutable, non-geographical k-d tree see [KDTree](https://github.com/Bersaelor/KDTree).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

BirdBush is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'BirdBush'
```

## Documentation

### Initialization

Generating with locations inputted as an array of Double arrays of the form [id, lon, lat]:
```swift
var bigArray = [[Double]]()
for i in 1...10000 {
  bigArray.append([Double(i), Double.random(in: -180..<180), Double.random(in: -90...90)])
}
let bigIndex = BirdBush<Double>(locations: bigArray, 
                                getID: { $0[0] }, 
                                getX: { $0[1] }, 
                                getY: { $0[2] })
```  

### Methods

#### around(lon: Double, lat: Double, maxResults: Int, maxDistance: Double) -> [(U, Double)]

Returns the closest points to a given geographical location in order of increasing distance. Return type is `[(U, Double)]` where `U` is type for the location ids, specified by `BirdBush<U>` when you initialized. The second value is the haversine between the two points - to convert it to the radian central angle use `centralAngle(_ h: Double)`. 

- `lon`: query point longitude.
- `lat`: query point latitude.
- `maxResults`: (optional) maximum number of points to return (`Int.max` by default).
- `maxDistance`: (optional) maximum distance in meters to search within (`Double.greatestFiniteMagnitude` by default).

#### centralAngle(_ h: Double) -> Double

Returns the central angle (radians) of a haversine returned by `around`. To convert central angle to distance, multiply by earth's radius in units of your choosing, e.g. 6.371e6 meters. 

#### nearest(qx: Double, qy: Double) -> (U, Double)

Returns the closest point to query coordinates. Return type is `(U, Double)` where `U` is type for the location ids, specified by `BirdBush<U>` when you initialized. The second value is the squared euclidean distance between the points. 

- `qx`: query point x coord.
- `qy`: query point y coord.

#### range(minX: Double, minY: Double, maxX: Double, maxY: Double) -> [U]

Returns the points within a given box. Return type is `[U]` where `U` is type for the location ids, specified by `BirdBush<U>` when you initialized.

#### within(qx: Double, qy: Double, r: Double) -> [U]

Returns all points within given distance from query point. Return type is `[U]` where `U` is type for the location ids, specified by `BirdBush<U>` when you initialized. 

- `qx`: query point x coord.
- `qy`: query point y coord.
- `r`: maximum distance.

## Author & License

Bird Bush is a Swift port of Vladimir Agafonkin's JavaScript libraries [kdbush](https://github.com/mourner/kdbush) and [geokdbush](https://github.com/mourner/geokdbush). BirdBush is available under the ISC license. See the LICENSE file for more info.
