import Foundation
import CoreBluetooth

class CBMessagerCharacteristic: CBCharacteristic {
    var writeRetried = 0
    var transferedData: Data = Data()
    var transferBlocked: Bool = false
    var origin: CBCharacteristic
    init(from: CBCharacteristic) {
        self.origin = from
    }
    
    func write(data: Data, withResponse: Bool) {
        guard !transferBlocked else {
            return
        }
        let peripheral = origin.service.peripheral
        let mtu = peripheral.maximumWriteValueLength (for: withResponse ? .withResponse : .withoutResponse)
        var messageDataIndex = 0
        if withResponse { transferBlocked = true }
        while peripheral.canSendWriteWithoutResponse && messageDataIndex < data.count {
            var amountToSend = data.count - messageDataIndex
            amountToSend = min(amountToSend, mtu)
            let chunk = data.subdata(in: messageDataIndex..<(messageDataIndex + amountToSend))
            peripheral.writeValue(chunk, for: origin, type: withResponse ? .withResponse : .withoutResponse)
            peripheral.setNotifyValue(true, for: origin)
            messageDataIndex += amountToSend
        }
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
    mutating func remove(in services: [CBService]) {
        self = self.filter({
            !services.contains($0.origin.service)
        })
    }
    func find(characteristic: CBCharacteristic) -> CBMessagerCharacteristic? {
        return self.first { (messagerCharacteristic) -> Bool in
            messagerCharacteristic.origin == characteristic
        }
    }
    func toCharacteristics() -> [CBCharacteristic] {
        return self.map { $0.origin }
    }
    mutating func clean() {
        self = self.filter({
            $0.origin.service.peripheral.state == .connected
        })
    }
}
