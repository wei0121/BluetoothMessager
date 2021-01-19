import Foundation
import CoreBluetooth

class CBMessagerData {

    var maximumDataLength: Int?
    var isCompleted = false
    private var messageData = Data()
    private var messageDataIndex: Int = 0
    private let peripheralManager: CBPeripheralManager
    private let transferCharacteristic: CBMutableCharacteristic
    
    init(peripheralManager: CBPeripheralManager,
         transferCharacteristic: CBMutableCharacteristic) {
        self.peripheralManager = peripheralManager
        self.transferCharacteristic = transferCharacteristic
    }
    
    func setMessage(message: String) {
        isCompleted = false
        messageData = message.data(using: .utf8)!
        messageDataIndex = 0
        send()
    }
    
    func send() {
        guard isCompleted == false else {
            return
        }

        if messageDataIndex >= messageData.count {
            isCompleted = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            return
        }
        
        var didSend = true
        while didSend {
            var amountToSend = messageData.count - messageDataIndex
            if let mtu = maximumDataLength {
                amountToSend = min(amountToSend, mtu)
            }
            
            let chunk = messageData.subdata(in: messageDataIndex..<(messageDataIndex + amountToSend))
            didSend = peripheralManager.updateValue(chunk, for: transferCharacteristic, onSubscribedCentrals: nil)
            
            if !didSend {
                return
            }

            messageDataIndex += amountToSend
            if messageDataIndex >= messageData.count {
                isCompleted = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
                return
            }
        }
    }

}
