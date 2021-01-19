import Foundation
import CoreBluetooth

class BluetoothMessagerPeripheral: NSObject {


    static let bluetoothMessagerPeripheralQueueKey = "BluetoothMessager.BluetoothMessagerPeripheralQueue"
    
    var config: BluetoothMessagerPeripheralConfig
    init?(config: BluetoothMessagerPeripheralConfig?) {
        guard config != nil else {
            return nil
        }
        self.config = config!
        super.init()
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue(label: BluetoothMessagerPeripheral.bluetoothMessagerPeripheralQueueKey), options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
    
    private var connectedCentral: CBCentral?
    private var transferCharacteristic: CBMutableCharacteristic?
    private var peripheralManager: CBPeripheralManager!
    private var messageData: CBMessagerData!
    private func setupPeripheral() {
        let transferCharacteristic = CBMutableCharacteristic(type: config.characteristicUUID,
                                                         properties: [.notify, .writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        let transferService = CBMutableService(type: config.serviceUUID, primary: true)
        
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.add(transferService)
        self.transferCharacteristic = transferCharacteristic
        self.messageData = CBMessagerData(peripheralManager: peripheralManager, transferCharacteristic: transferCharacteristic)
    }
}

extension BluetoothMessagerPeripheral: BluetoothMessagerPeripheralAction {
    func sendMessage(message: String) {
        messageData.setMessage(message: message)
    }
}

extension BluetoothMessagerPeripheral: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            setupPeripheral()
        case .poweredOff, .resetting, .unauthorized, .unknown, .unsupported:
            return
        @unknown default:
            return
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        connectedCentral = central
        messageData.maximumDataLength = central.maximumUpdateValueLength
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        connectedCentral = nil
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        messageData.send()
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                let stringFromData = String(data: requestValue, encoding: .utf8) else {
                    continue
            }
        }
    }
    
}
