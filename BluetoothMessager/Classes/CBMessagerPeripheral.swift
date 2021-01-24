import Foundation
import CoreBluetooth

class CBMessagerPeripheral {
    var activated: Bool = false
//    var connected: Bool = false
    var origin: CBPeripheral
    init(from: CBPeripheral) {
        self.origin = from
    }
}

extension Array where Element == CBMessagerPeripheral {
    mutating func insertIfNotExist(peripheral: CBPeripheral) {
        let isExist = self.contains(where: { (messagerPeripheral) -> Bool in
            return messagerPeripheral.origin == peripheral
        })
        
        if !isExist {
            self.append(CBMessagerPeripheral(from: peripheral))
        }
    }
//    mutating func setConnection(peripheral: CBPeripheral, isConnected: Bool) {
//        insertIfNotExist(peripheral: peripheral)
//        self.first { (messagerPeripheral) -> Bool in
//            return messagerPeripheral.origin == peripheral
//        }?.connected = isConnected
//    }
    func toPeripherals() -> [CBPeripheral] {
        return self.map { $0.origin }
    }
}

extension CBMessagerPeripheral: Equatable {
    static func == (lhs: CBMessagerPeripheral, rhs: CBMessagerPeripheral) -> Bool {
        return lhs.origin == lhs.origin
    }
}
