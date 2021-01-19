import UIKit
import CoreBluetooth

public class BluetoothMessager {
    
    public let central: BluetoothMessagerCentralAction?
    public let peripheral: BluetoothMessagerPeripheralAction?
    
    public init(centralConfig: BluetoothMessagerCentralConfig? = nil, peripheralConfig: BluetoothMessagerPeripheralConfig? = nil) {
        self.central = BluetoothMessagerCentral(config: centralConfig)
        self.peripheral = BluetoothMessagerPeripheral(config: peripheralConfig)
    }
}



