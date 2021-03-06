import Foundation
import CoreBluetooth

public class BluetoothMessagerCentralConfig{
    public var serviceUUID: CBUUID
    public var characteristicUUID: CBUUID
    public var minimalSignalStrength: Int = -50
    public var timeOut: TimeInterval = 1
    public var didUpdateDiscoveredPeripherals: (([CBPeripheral]) -> Void)?
    public var didUpdateNotifyingCharacteristic: (([CBCharacteristic]) -> Void)?
    public var didReceiveMessage: ((_ message: String, _ sender: String) -> Void)?
    public var didSendMessage: ((Bool, BluetoothMessagerError?) -> Void)?
    
    public init(serviceUUID: CBUUID, characteristicUUID: CBUUID, didUpdateDiscoveredPeripherals: (([CBPeripheral]) -> Void)? = nil, didReceiveMessage: ((_ message: String, _ sender: String) -> Void)? = nil) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.didUpdateDiscoveredPeripherals = didUpdateDiscoveredPeripherals
        self.didReceiveMessage = didReceiveMessage
    }
}

public protocol BluetoothMessagerCentralAction {
    var scanNewPeripheral: Bool { get set }
    var isReadyToSendMessage: Bool { get }
    func sendMessage(message: String, withResponse: Bool)
}



