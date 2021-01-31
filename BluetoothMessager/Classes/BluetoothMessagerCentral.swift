import Foundation
import CoreBluetooth

class BluetoothMessagerCentral: NSObject {
    
    weak var config: BluetoothMessagerCentralConfig?
    var discoveringPeripheral: Bool = false {
        didSet {
            guard let config = config else {
                fatalError()
            }
            if discoveringPeripheral {
                centralManager.scanForPeripherals(withServices: [config.serviceUUID],
                                                  options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }else{
                centralManager.stopScan()
            }
        }
    }
    var discoveredPeripherals: [CBMessagerPeripheral] = [] {
        didSet {
            guard let config = config else { fatalError() }
            if oldValue != discoveredPeripherals {
                config.didUpdateDiscoveredPeripherals?(discoveredPeripherals.toPeripherals())
            }
        }
    }
    var avalibleCharacteristics: [CBMessagerCharacteristic] = []

    private var _activated: Bool = false
    private var centralManager: CBCentralManager!
    init?(config: BluetoothMessagerCentralConfig?) {
        guard config != nil else { return nil }
        self.config = config
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    private func retrieveConnection() {
        guard let config = config else { fatalError() }
        let retrieveConnectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [config.serviceUUID])
        retrieveConnectedPeripherals.forEach {
            if ($0.state == .disconnected || $0.state == .disconnecting) {
                centralManager.connect($0, options: nil)
            }
        }
        if retrieveConnectedPeripherals.count <= 0 {
            discoveringPeripheral = true
        }
    }
    
    private func cleanup(peripheral: CBPeripheral) {
        guard let config = config else { fatalError() }
        guard case .connected = peripheral.state else { return }
        for service in (peripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == config.characteristicUUID && characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    private func writeData(data: Data, withResponse: Bool) {
        avalibleCharacteristics.forEach { characteristic in
            characteristic.write(data: data, withResponse: withResponse)
        }
    }
}

extension BluetoothMessagerCentral: BluetoothMessagerCentralAction {
    var scanNewPeripheral: Bool {
        get {
            return discoveringPeripheral
        }
        set {
            discoveringPeripheral = newValue
        }
    }
    var isReadyToSendMessage: Bool {
        get {
            return avalibleCharacteristics.filter({ $0.transferBlocked }).count == 0
        }
    }
    func sendMessage(message: String, withResponse: Bool) {
        let messageData = message.data(using: .utf8)!
        self.writeData(data: messageData, withResponse: withResponse)
    }
}

extension BluetoothMessagerCentral: CBCentralManagerDelegate {

    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            retrieveConnection()
        case .poweredOff, .resetting, .unauthorized, .unknown, .unsupported:
            return
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let config = config else { fatalError() }
        guard RSSI.intValue >= config.minimalSignalStrength else {
            return
        }
        discoveredPeripherals.insertIfNotExist(peripheral: peripheral)
        if !(peripheral.state == .connected || peripheral.state == .connecting) {
            centralManager.connect(peripheral, options: nil)
        }
        if discoveringPeripheral {
            centralManager.scanForPeripherals(withServices: [config.serviceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let config = config else { fatalError() }
        config.didUpdateDiscoveredPeripherals?(discoveredPeripherals.toPeripherals())
        peripheral.delegate = self
        peripheral.discoverServices([config.serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let config = config else { fatalError() }
        config.didUpdateDiscoveredPeripherals?(discoveredPeripherals.toPeripherals())
        retrieveConnection()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cleanup(peripheral: peripheral)
    }
}

extension BluetoothMessagerCentral: CBPeripheralDelegate {

    // Services
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        guard let config = config else { fatalError() }
        peripheral.discoverServices([config.serviceUUID])
        avalibleCharacteristics.remove(in: invalidatedServices)
        config.didUpdateNotifyingCharacteristic?(avalibleCharacteristics.toCharacteristics())
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let config = config else { fatalError() }
        guard error == nil, let peripheralServices = peripheral.services else {
            cleanup(peripheral: peripheral)
            return
        }
        peripheralServices.forEach { (service) in
            peripheral.discoverCharacteristics([config.characteristicUUID], for: service)
        }
    }
    
    // Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let config = config else { fatalError() }
        guard error == nil, let serviceCharacteristics = service.characteristics else {
            cleanup(peripheral: peripheral)
            return
        }
        serviceCharacteristics.filter{ $0.uuid == config.characteristicUUID }.forEach { (characteristic) in
            avalibleCharacteristics.insertIfNotExist(characteristic: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            
        }
    }
    
    // read Characteristics
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            cleanup(peripheral: peripheral)
            return
        }
        
        guard let characteristicData = characteristic.value,
            let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        // Have we received the end-of-message token?
        if stringFromData == "EOM" {
            // End-of-message case: show the data.
            DispatchQueue.main.async() {
                guard let config = self.config else { fatalError() }
                let message = String(data: self.avalibleCharacteristics.find(characteristic: characteristic)!.transferedData, encoding: .utf8)
                print(message ?? "Empty")
                self.avalibleCharacteristics.find(characteristic: characteristic)?.transferedData = Data()
                config.didReceiveMessage?(message ?? "Empty", peripheral.name ?? "Unknown")
            }
        } else {
            avalibleCharacteristics.find(characteristic: characteristic)?.transferedData.append(characteristicData)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard let config = config else { fatalError() }
        guard error == nil, characteristic.uuid == config.characteristicUUID, characteristic.isNotifying else {
            cleanup(peripheral: peripheral)
            return
        }
        avalibleCharacteristics.clean()
        config.didUpdateNotifyingCharacteristic?(avalibleCharacteristics.toCharacteristics())
    }
    
    // write Characteristics
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        avalibleCharacteristics.find(characteristic: characteristic)?.transferBlocked = false
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {

    }
}
