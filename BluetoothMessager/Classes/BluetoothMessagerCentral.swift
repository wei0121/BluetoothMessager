import Foundation
import CoreBluetooth

class BluetoothMessagerCentral: NSObject {
    
    var config: BluetoothMessagerCentralConfig
    var isReadyToSendMessage: Bool = false
    var discoveringPeripheral: Bool = false {
        didSet {
            if discoveringPeripheral {
                centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                                  options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }else{
                centralManager.stopScan()
            }
        }
    }
    var discoveredPeripherals: [CBMessagerPeripheral] = [] {
        didSet {
//            config.didUpdateDiscoveredPeripherals?(discoveredPeripherals)
        }
    }
    var avalibleCharacteristics: [CBMessagerCharacteristic] = []
    


    private var centralManager: CBCentralManager!
    init?(config: BluetoothMessagerCentralConfig?) {
        guard config != nil else {
            return nil
        }
        self.config = config!
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    private func retrieveConnection() {
        let retrieveConnectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [TransferService.serviceUUID])
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
        guard case .connected = peripheral.state else { return }
        
        for service in (peripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicUUID && characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    private func writeData() {
        
    }
}

extension BluetoothMessagerCentral: BluetoothMessagerCentralAction {
    
    func sendMessage(message: String) throws {
        let semaphore = DispatchSemaphore(value: 0)
        let loadingQueue = DispatchQueue.global()
        loadingQueue.async {
            
            // TODO: Can remove the timeout while
            let start = Date()
            let timeOut = start.addingTimeInterval(self.config.timeOut)
            while Date() > timeOut {
                if self.isReadyToSendMessage {
                    self.writeData()
                }
            }
        }
        semaphore.wait(timeout: .now() + self.config.timeOut)
        throw BluetoothMessagerError.noPeripheralConnected
    }
    
    func setPeripheralsActivation(peripheral: CBPeripheral, enable: Bool) {
        
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
        guard RSSI.intValue >= config.minimalSignalStrength else {
            return
        }
        discoveredPeripherals.insertIfNotExist(peripheral: peripheral)
        if !(peripheral.state == .connected || peripheral.state == .connecting) {
            centralManager.connect(peripheral, options: nil)
        }
        if discoveringPeripheral {
            centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        discoveredPeripherals.setConnection(peripheral: peripheral, isConnected: true)
        peripheral.delegate = self
        peripheral.discoverServices([TransferService.serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        discoveredPeripherals.setConnection(peripheral: peripheral, isConnected: false)
        retrieveConnection()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cleanup(peripheral: peripheral)
    }
}

extension BluetoothMessagerCentral: CBPeripheralDelegate {

    // Services
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        peripheral.discoverServices([TransferService.serviceUUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil, let peripheralServices = peripheral.services else {
            cleanup(peripheral: peripheral)
            return
        }
        peripheralServices.forEach { (service) in
            peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: service)
        }
    }
    
    // Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let serviceCharacteristics = service.characteristics else {
            cleanup(peripheral: peripheral)
            return
        }
        serviceCharacteristics.filter{ $0.uuid == TransferService.characteristicUUID }.forEach { (characteristic) in
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
                let message = String(data: self.avalibleCharacteristics.find(characteristic: characteristic)!.transferedData, encoding: .utf8)
                print(message ?? "Empty")
            }
            
            // Write test data
//            writeData()
        } else {
            avalibleCharacteristics.find(characteristic: characteristic)?.transferedData.append(characteristicData)
//            transferCharacteristics[characteristic]!.append(characteristicData)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, characteristic.uuid == TransferService.characteristicUUID, characteristic.isNotifying  else {
            cleanup(peripheral: peripheral)
            return
        }
    }
    
    // write Characteristics
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
