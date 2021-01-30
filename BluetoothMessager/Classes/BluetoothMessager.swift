import UIKit
import CoreBluetooth

public class BluetoothMessager {
    
    public var central: BluetoothMessagerCentralAction?
    public var peripheral: BluetoothMessagerPeripheralAction?
    
    public init(centralConfig: BluetoothMessagerCentralConfig? = nil, peripheralConfig: BluetoothMessagerPeripheralConfig? = nil) {
        self.central = BluetoothMessagerCentral(config: centralConfig)
        self.peripheral = BluetoothMessagerPeripheral(config: peripheralConfig)
    }
}



