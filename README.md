# BirdBush

[![CI Status](https://img.shields.io/travis/hsnetzer@gmail.com/BirdBush.svg?style=flat)](https://travis-ci.org/hsnetzer@gmail.com/BirdBush)
[![Version](https://img.shields.io/cocoapods/v/BirdBush.svg?style=flat)](https://cocoapods.org/pods/BirdBush)
[![License](https://img.shields.io/cocoapods/l/BirdBush.svg?style=flat)](https://cocoapods.org/pods/BirdBush)
[![Platform](https://img.shields.io/cocoapods/p/BirdBush.svg?style=flat)](https://cocoapods.org/pods/BirdBush)

Swift implementation of a k-d binary space partitioning tree. The data is stored in a pair of arrays, making serialization very straightforward. Besides the classic k-d tree queries, BirdBush also implements a geographical nearest neighbor search based on mourner's geokdbush. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

BirdBush is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'BirdBush', :git => 'https://github.com/hsnetzer/BirdBush'
```

## Documentation

### Initialization

Generating with locations inputted as an array of Double arrays of the form [id, lon, lat]:
```swift
var bigArray = [[Double]]()
for i in 1...10000 {
  bigArray.append([Double(i), Double.random(in: -180..<180), Double.random(in: -90...90)])
}
let bigIndex = BirdBush<Double>(locations: bigArray, getID: { return $0[0] }, getX: { return $0[1] }, getY: { return $0[2] })
```  

### Methods

#### around(lon: Double, lat: Double, maxResults: Int, maxDistance: Double)

Returns an array of the closest points from a given location in order of increasing distance. Return type is `(U, Double)]` where `U` is type for the location ids, specified by `BirdBush<U>` when you initialized. The second value in the tuples is a stand in for distance - to convert it to the central angle use `centralAngle(_ h: Double)`. 

- `lon`: query point longitude.
- `lat`: query point latitude.
- `maxResults`: (optional) maximum number of points to return (`Int.max` by default).
- `maxDistance`: (optional) maximum distance in kilometers to search within (`Infinity` by default).

## Author & License

Bird Bush is a Swift port of Vladimir Agafonkin's JavaScript libraries [kdbush](https://github.com/mourner/kdbush) and [geokdbush](https://github.com/mourner/geokdbush). BirdBush is available under the ISC license. See the LICENSE file for more info.
