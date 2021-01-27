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
    enum ConnectionState {
        case disconnected
        case connecting
        case connected(Int)
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
    
    func setEnableButton(state: ConnectionState) {
        switch state {
        case .disconnected:
            enableButton.isEnabled = true
            enableButton.setTitle("Enable", for: .normal)
            enableButton.backgroundColor = UIColor.green
        case .connecting:
            enableButton.isEnabled = false
            enableButton.setTitle("Connecting", for: .normal)
            enableButton.backgroundColor = UIColor.gray
        case .connected(let count):
            enableButton.isEnabled = true
            enableButton.setTitle("Disable(\(count))", for: .normal)
            enableButton.backgroundColor = UIColor.red
        }
    }
    
    func messagerCentral() {
        self.setEnableButton(state:.connecting)
        var config = BluetoothMessagerCentralConfig(serviceUUID: ViewController.serviceUUID, characteristicUUID: ViewController.characteristicUUID)
        config.didUpdateDiscoveredPeripherals = {(peripherals) -> Void in
            print("didUpdateDiscoveredPeripherals")
            print(peripherals)
        }
        config.didUpdateNotifyingCharacteristic = {(characteristic) -> Void in
            print("didUpdateNotifyingCharacteristic")
            print(characteristic)
            let notifyingCharacteristicCount = characteristic.filter({ $0.isNotifying }).count
            self.setEnableButton(state: notifyingCharacteristicCount > 0 ? .connected(notifyingCharacteristicCount) : .connecting)
        }
        config.didReceiveMessage = {(message) -> Void in
            print("didReceiveMessage")
            print(message)
            self.receivedMessages.append(message)
        }
        
        bluetoothMessager = BluetoothMessager(centralConfig: config)
    }
    
    func messagerPeripheral() {
        self.setEnableButton(state:.connecting)
        var config = BluetoothMessagerPeripheralConfig(serviceUUID: ViewController.serviceUUID, characteristicUUID: ViewController.characteristicUUID)
        config.didUpdateCentral = {(central) -> Void in
            print("didUpdateCentral")
            self.setEnableButton(state: central == nil ? .disconnected : .connected(1))
        }
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
            bluetoothMessager?.central?.sendMessage(message: messageTextField.text ?? "None", withResponse: false)
        case .peripheral:
            bluetoothMessager?.peripheral?.sendMessage(message: messageTextField.text ?? "None")
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

