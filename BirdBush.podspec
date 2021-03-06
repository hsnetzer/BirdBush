#
# Be sure to run `pod lib lint BirdBush.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BirdBush'
  s.version          = '0.8.0'
  s.summary          = 'A static kd tree for geographical purposes'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Swift implementation of a k-d binary space partitioning tree. The data is stored in a pair of arrays, making serialization very straightforward. Besides the classic k-d tree queries, BirdBush also implements a geographical nearest neighbor search based on mourner's geokdbush.
                       DESC

  s.homepage         = 'https://github.com/hsnetzer/bird-bush'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'ISC', :file => 'LICENSE' }
  s.author           = { 'Harry Netzer' => 'hsnetzer@gmail.com' }
  s.source           = { :git => 'https://github.com/hsnetzer/bird-bush.git', :tag => '0.8.0' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'BirdBush/Classes/**/*'
  s.dependency 'SwiftPriorityQueue'
  s.swift_version = '5.0'
  
  # s.resource_bundles = {
  #   'BirdBush' => ['BirdBush/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
