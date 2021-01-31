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
  s.summary          = 'A simplified bluetooth library for sending messages between iOS devices.'
  s.description      = <<-DESC
  BluetoothMessager is an extension for using sending messages between iOS devices via Core Bluetooth.
                       DESC

  s.homepage         = 'https://github.com/wei0121/BluetoothMessager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weiren' => 'xwr0121@outlook.com' }
  s.source           = { :git => 'https://github.com/weiren/BluetoothMessager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_versions = "5.3"
  s.source_files = 'BluetoothMessager/Classes/**/*'
  
end
