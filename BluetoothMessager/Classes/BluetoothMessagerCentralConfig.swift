import Foundation
import CoreBluetooth

public struct BluetoothMessagerCentralConfig {
    public var serviceUUID: CBUUID
    public var characteristicUUID: CBUUID
    public var minimalSignalStrength: Int = -50
    public var timeOut: TimeInterval = 1
    public var didUpdateDiscoveredPeripherals: (([CBPeripheral]) -> Void)?
    public var didReceiveMessage: ((String) -> Void)?
    
    public init(serviceUUID: CBUUID, characteristicUUID: CBUUID, didUpdateDiscoveredPeripherals: (([CBPeripheral]) -> Void)? = nil, didReceiveMessage: ((String) -> Void)? = nil) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.didUpdateDiscoveredPeripherals = didUpdateDiscoveredPeripherals
        self.didReceiveMessage = didReceiveMessage
    }
}


public protocol BluetoothMessagerCentralAction {
    var readyToSendMessage: Bool { get }
    func setPeripheralsActivation(peripheral: CBPeripheral, enable: Bool)
    func sendMessage(message: String) throws
}



