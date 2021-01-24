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
    private var _activated: Bool = false
    private var connectedCentral: CBCentral? {
        didSet {
            DispatchQueue.main.async() {
                self.config.didUpdateCentral?(self.connectedCentral)
            }
        }
    }
    private var transferCharacteristic: CBMutableCharacteristic?
    private var peripheralManager: CBPeripheralManager!
    private var messageData: CBMessagerData!
    private func setupPeripheral() {
        let transferCharacteristic = CBMutableCharacteristic(type: config.characteristicUUID,
                                                         properties: [.notify, .write],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        let transferService = CBMutableService(type: config.serviceUUID, primary: true)
        
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.add(transferService)
        self.transferCharacteristic = transferCharacteristic
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [config.serviceUUID]])
        self.messageData = CBMessagerData(peripheralManager: peripheralManager, transferCharacteristic: transferCharacteristic)
    }
}

extension BluetoothMessagerPeripheral: BluetoothMessagerPeripheralAction {
    
    var activated: Bool {
        get {
            return _activated
        }
        set {
            _activated = newValue
        }
    }
    
    var isReadyToSendMessage: Bool {
        get {
            // Todo: Check readyToSendMessage
            return false
        }
    }
    
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
            self.config.didReceiveMessage?(stringFromData)
        }
    }
    
}
