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

Generating with locations inputted as an array of Array<Double>s of the form [id, x coord, y coord]:
```swift
var bigArray = [[Double]]()
for i in 1...10000 {
  bigArray.append([Double(i), Double.random(in: 0...100), Double.random(in: 0...100)])
}
let bigIndex = BirdBush<Double>(locations: bigArray, getID: { return $0[0] }, getX: { return $0[1] }, getY: { return $0[2] })
```  

### Methods

## Author & License

Bird Bush is a Swift port of Vladimir Agafonkin's JavaScript libraries kdbush and geokdbush. BirdBush is available under the ISC license. See the LICENSE file for more info.
