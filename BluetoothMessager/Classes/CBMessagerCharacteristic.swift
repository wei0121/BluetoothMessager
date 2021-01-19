import Foundation
import CoreBluetooth

class CBMessagerCharacteristic: CBCharacteristic {
    var writeRetried = 0
    
    var transferedData: Data = Data()
    var transferCompleted: Bool = false
    var origin: CBCharacteristic
    init(from: CBCharacteristic) {
        self.origin = from
    }
    func write(data: Data) {
        writeRetried = 0
        let peripheral = origin.service.peripheral
        while writeRetried < 5 && peripheral.canSendWriteWithoutResponse {
                    
            let mtu = peripheral.maximumWriteValueLength (for: .withoutResponse)
            var rawPacket = [UInt8]()
            let bytesToCopy: size_t = min(mtu, data.count)
            data.copyBytes(to: &rawPacket, count: bytesToCopy)
            let packetData = Data(bytes: &rawPacket, count: bytesToCopy)
            
//            let stringFromData = String(data: packetData, encoding: .utf8)
//            os_log("Writing %d bytes: %s", bytesToCopy, String(describing: stringFromData))
            
            peripheral.writeValue(packetData, for: origin, type: .withoutResponse)
            writeRetried += 1
        }
        
        if writeRetried == 5 {
            peripheral.setNotifyValue(false, for: origin)
        }
        
//        origin.service.peripheral.writeValue(data, for: origin, type: .withoutResponse)
    }
}

extension Array where Element == CBMessagerCharacteristic {
    mutating func insertIfNotExist(characteristic: CBCharacteristic) {
        let isExist = self.contains(where: { (messagerCharacteristic) -> Bool in
            return messagerCharacteristic.origin == characteristic
        })
        
        if !isExist {
            self.append(CBMessagerCharacteristic(from: characteristic))
        }
    }
    func find(characteristic: CBCharacteristic) -> CBMessagerCharacteristic? {
        return self.first { (messagerCharacteristic) -> Bool in
            messagerCharacteristic.origin == characteristic
        }
    }
    
}
