#
# Be sure to run `pod lib lint BluetoothMessager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BluetoothMessager'
  s.version          = '0.1.0'
  s.summary          = 'A simplified bluetooth library for sending messages between iOS devices'
  s.description      = <<-DESC
  A simplified bluetooth library for sending messages between iOS devices
                       DESC

  s.homepage         = 'https://github.com/weiren/BluetoothMessager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weiren' => 'xwr0121@163.com' }
  s.source           = { :git => 'https://github.com/weiren/BluetoothMessager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_versions = "5.3"
  s.source_files = 'BluetoothMessager/Classes/**/*'
  # s.public_header_files = 'Pod/Classes/BluetoothMessager.swift'
  
  # s.resource_bundles = {
  #   'BluetoothMessager' => ['BluetoothMessager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
