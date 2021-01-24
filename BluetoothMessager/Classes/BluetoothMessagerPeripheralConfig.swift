import Foundation
import CoreBluetooth

public struct BluetoothMessagerPeripheralConfig {
    public var serviceUUID: CBUUID
    public var characteristicUUID: CBUUID
    public var didUpdateCentral: ((CBCentral?) -> Void)?
    public var didReceiveMessage: ((String) -> Void)?
    public var didSendMessage: ((Bool, BluetoothMessagerError?) -> Void)?
    
    public init(serviceUUID: CBUUID, characteristicUUID: CBUUID) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
    }

}
public protocol BluetoothMessagerPeripheralAction {
    var activated: Bool { get set }
    var isReadyToSendMessage: Bool { get }
    func sendMessage(message: String)
}

