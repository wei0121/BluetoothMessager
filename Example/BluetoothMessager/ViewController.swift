//
//  ViewController.swift
//  BluetoothMessager
//
//  Created by weiren on 01/11/2021.
//  Copyright (c) 2021 weiren. All rights reserved.
//

import UIKit
import BluetoothMessager
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var messagerSwitcher: UISegmentedControl!
    @IBAction func startHandler(_ sender: UIButton) {
        switch messagerSwitcher.selectedSegmentIndex {
        case 0:
            messagerCentral()
        case 1:
            messagerPeripheral()
        default:
            break
        }
    }
    
    func messagerCentral() {
        var config = BluetoothMessagerCentralConfig(serviceUUID: CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"), characteristicUUID: CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4"))
        config.didUpdateDiscoveredPeripherals = {(peripherals) -> Void in
            print("didUpdateDiscoveredPeripherals")
            print(peripherals)
        }
        config.didReceiveMessage = {(message) -> Void in
            print("didReceiveMessage")
            print(message)
        }
        
        let manager = BluetoothMessager(centralConfig: config)

        do {
            try manager.central?.sendMessage(message: "send me")
        } catch is BluetoothMessagerError {
            print("Couldn't buy that from the vending machine.")
        } catch {
            print("Unexpected non-vending-machine-related error: \(error)")
        }
    }
    
    func messagerPeripheral() {
        var config = BluetoothMessagerPeripheralConfig(serviceUUID: CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"), characteristicUUID: CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4"))
        config.didSendMessage = {(success, error) -> Void in
            
        }
        let manager = BluetoothMessager(peripheralConfig: config)
        manager.peripheral?.sendMessage(message: "send me")
      

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

