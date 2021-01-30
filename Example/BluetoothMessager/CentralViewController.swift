import UIKit
import BluetoothMessager
import CoreBluetooth

class CentralViewController: UIViewController {
    
    var bluetoothMessager: BluetoothMessager?
    var messageBubble: MessageBubbleViewController?
    var settingView: CentralSettingViewController?
    var receivedMessages:[MessageBubble] = [MessageBubble(isSender: true, message: "some", date: Date())] {
        didSet {
            messageBubble?.tableView.reloadData()
        }
    }
    var connectedCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagerCentral()
        hideKeyboardWhenTappedAround() 
    }
    
    func messagerCentral() {
        var config = BluetoothMessagerCentralConfig(serviceUUID: ViewController.serviceUUID, characteristicUUID: ViewController.characteristicUUID)
        config.didUpdateDiscoveredPeripherals = {(peripherals) -> Void in
            print("didUpdateDiscoveredPeripherals")
        }
        config.didUpdateNotifyingCharacteristic = {(characteristics) -> Void in
            print("didUpdateNotifyingCharacteristic")
            self.connectedCount = characteristics.count
        }
        config.didReceiveMessage = {(message) -> Void in
            print("didReceiveMessage")
            print(message)
            self.receivedMessages.append(message: message, isSender: false)
        }
        bluetoothMessager = BluetoothMessager(centralConfig: config)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            if let pop = segue.destination.popoverPresentationController {
                pop.delegate = self
            }
            if let pop = segue.destination as? CentralSettingViewController {
                settingView = pop
                settingView?.foundPeripherals = connectedCount
                settingView?.scanSwitchHandle = { [unowned self] isOn in
                    self.bluetoothMessager?.central?.scanNewPeripheral = isOn
                }
            }
        }
        if segue.identifier == "bubbleSegue" {
            if let pop: MessageBubbleViewController = segue.destination as? MessageBubbleViewController {
                messageBubble = pop
                pop.delegate = self
            }
        }
    }
}

extension CentralViewController:  MessageBubbleViewControllerDelegate {
    func onSendMessages(message: String) {
        bluetoothMessager?.central?.sendMessage(message: message, withResponse: settingView?.messageResponseSwitch.isOn ?? false)
        receivedMessages.append(message: message, isSender: true)
    }
    
    func onUpdateMessages() -> [MessageBubble] {
        return receivedMessages
    }
}

extension CentralViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
