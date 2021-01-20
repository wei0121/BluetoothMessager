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
    static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    enum DeviceType: Int {
        case central, peripheral
        var name: String {
            get {
                switch self {
                case .central:
                    return "Central"
                case .peripheral:
                    return "Peripheral"
                }
            }
        }
    }
    var receivedMessages:[String] = ["some"] {
        didSet {
            tableView.reloadData()
        }
    }
    var bluetoothMessager: BluetoothMessager?
    
    @IBOutlet weak var messagerSwitcher: UISegmentedControl!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var enableButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func deviceTypeChangeHandler(_ sender: UISegmentedControl) {
        let deviceType = DeviceType.init(rawValue: messagerSwitcher.selectedSegmentIndex)
        messageTextField.text = "a message from " + deviceType!.name
    }
    @IBAction func enableHandler(_ sender: UIButton) {
        let deviceType = DeviceType.init(rawValue: messagerSwitcher.selectedSegmentIndex)
        switch deviceType {
        case .central:
            messagerCentral()
        case .peripheral:
            messagerPeripheral()
        case .none:
            break
        }
    }
    @IBAction func sendMessageHandler(_ sender: UIButton) {
        sendMessage()
    }
    
    func messagerCentral() {
        var config = BluetoothMessagerCentralConfig(serviceUUID: ViewController.serviceUUID, characteristicUUID: ViewController.characteristicUUID)
        config.didUpdateDiscoveredPeripherals = {(peripherals) -> Void in
            print("didUpdateDiscoveredPeripherals")
            print(peripherals)
        }
        config.didReceiveMessage = {(message) -> Void in
            print("didReceiveMessage")
            print(message)
            self.receivedMessages.append(message)
        }
        
        bluetoothMessager = BluetoothMessager(centralConfig: config)
    }
    
    func messagerPeripheral() {
        var config = BluetoothMessagerPeripheralConfig(serviceUUID: ViewController.serviceUUID, characteristicUUID: ViewController.characteristicUUID)
        config.didReceiveMessage = {(message) -> Void in
            print("didReceiveMessage")
            print(message)
            self.receivedMessages.append(message)
        }
        bluetoothMessager = BluetoothMessager(peripheralConfig: config)
    }
    
    func sendMessage() {
        let deviceType = DeviceType.init(rawValue: messagerSwitcher.selectedSegmentIndex)
        switch deviceType {
        case .central:
            do {
                try bluetoothMessager?.central?.sendMessage(message: "send me")
            } catch is BluetoothMessagerError {
                print("Couldn't buy that from the vending machine.")
            } catch {
                print("Unexpected non-vending-machine-related error: \(error)")
            }
        case .peripheral:
            bluetoothMessager?.peripheral?.sendMessage(message: "send me")
        case .none:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidLayoutSubviews() {
        enableButton.layer.cornerRadius = 10
        sendMessageButton.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = receivedMessages[indexPath.row]
        
        return cell
    }
    
    
}

