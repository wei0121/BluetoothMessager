import Foundation
import CoreBluetooth

public struct BluetoothMessagerCentralConfig {
    public var serviceUUID: CBUUID
    public var characteristicUUID: CBUUID
    public var minimalSignalStrength: Int = -50
    public var timeOut: TimeInterval = 1
    public var didUpdateDiscoveredPeripherals: (([CBPeripheral]) -> Void)?
    public var didUpdateNotifyingCharacteristic: (([CBCharacteristic]) -> Void)?
    public var didReceiveMessage: ((String) -> Void)?
    public var didSendMessage: ((Bool, BluetoothMessagerError?) -> Void)?
    
    public init(serviceUUID: CBUUID, characteristicUUID: CBUUID, didUpdateDiscoveredPeripherals: (([CBPeripheral]) -> Void)? = nil, didReceiveMessage: ((String) -> Void)? = nil) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.didUpdateDiscoveredPeripherals = didUpdateDiscoveredPeripherals
        self.didReceiveMessage = didReceiveMessage
    }
}


public protocol BluetoothMessagerCentralAction {
    var activated: Bool { get set }
    var isReadyToSendMessage: Bool { get }
    func setPeripheralsActivation(peripheral: CBPeripheral, enable: Bool)
    func sendMessage(message: String, withResponse: Bool)
    //    func sendMessage(message: String) throws
}



