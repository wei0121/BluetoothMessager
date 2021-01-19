import Foundation
import CoreBluetooth

public struct BluetoothMessagerPeripheralConfig {
    public var serviceUUID: CBUUID
    public var characteristicUUID: CBUUID
    public var didSendMessage: ((Bool, BluetoothMessagerError?) -> Void)?
    
    public init(serviceUUID: CBUUID, characteristicUUID: CBUUID) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
    }

}
public protocol BluetoothMessagerPeripheralAction {
    func sendMessage(message: String)
}

