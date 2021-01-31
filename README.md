# BluetoothMessager

[![CI Status](https://img.shields.io/travis/weiren/BluetoothMessager.svg?style=flat)](https://travis-ci.org/weiren/BluetoothMessager)
[![Version](https://img.shields.io/cocoapods/v/BluetoothMessager.svg?style=flat)](https://cocoapods.org/pods/BluetoothMessager)
[![License](https://img.shields.io/cocoapods/l/BluetoothMessager.svg?style=flat)](https://cocoapods.org/pods/BluetoothMessager)
[![Platform](https://img.shields.io/cocoapods/p/BluetoothMessager.svg?style=flat)](https://cocoapods.org/pods/BluetoothMessager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BluetoothMessager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BluetoothMessager'
```

## Author

weiren, xwr0121@outlook.com

## Roadmap

- Message Sender should always as central
- Peripheral should send back a confirmation message to central when recevied a message
- Message receiver should be selectable 
- Queue for keeping messege with state (sending/received/success/failed)
- Check maximum volume of message data
- Message date format (String/Array/Dictionary)
- Improve error handling
- Imporve UI/UX

## License

BluetoothMessager is available under the MIT license. See the LICENSE file for more info.
