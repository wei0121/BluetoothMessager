import UIKit
import BluetoothMessager
import CoreBluetooth

class PeripheralViewController: UIViewController {
    var bluetoothMessager: BluetoothMessager?
    var messageBubble: MessageBubbleViewController?
    var receivedMessages:[MessageBubble] = [MessageBubble(isSender: true, message: "some", date: Date())] {
        didSet {
            messageBubble?.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagerPeripheral()
        hideKeyboardWhenTappedAround()
    }
    
    func messagerPeripheral() {
        var config = BluetoothMessagerPeripheralConfig(serviceUUID: ViewController.serviceUUID, characteristicUUID: ViewController.characteristicUUID)
        config.didUpdateCentral = {(central) -> Void in
            print("didUpdateCentral")
        }
        config.didReceiveMessage = {(message) -> Void in
            print("didReceiveMessage")
            print(message)
            self.receivedMessages.append(message: message, isSender: false)
        }
        bluetoothMessager = BluetoothMessager(peripheralConfig: config)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bubbleSegue" {
            if let pop: MessageBubbleViewController = segue.destination as? MessageBubbleViewController {
                messageBubble = pop
                pop.delegate = self
            }
        }
    }
}

extension PeripheralViewController:  MessageBubbleViewControllerDelegate {
    func onSendMessages(message: String) {
        bluetoothMessager?.peripheral?.sendMessage(message: message)
        receivedMessages.append(message: message, isSender: true)
    }
    
    func onUpdateMessages() -> [MessageBubble] {
        return receivedMessages
    }
}

extension PeripheralViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
