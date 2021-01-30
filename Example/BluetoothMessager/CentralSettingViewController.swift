import UIKit

class CentralSettingViewController: UIViewController {
    
    @IBOutlet weak var scanSwitch: UISwitch!
    @IBOutlet weak var messageResponseSwitch: UISwitch!
    @IBOutlet weak var infoLabel: UILabel!
    @IBAction func scanSwitchDidChange(_ sender: UISwitch) {
        scanSwitchHandle?(sender.isOn)
    }
    var scanSwitchHandle: ((Bool) -> ())?
    var foundPeripherals: Int = 0
    
    override func viewDidLoad() {
        infoLabel.text = "\(foundPeripherals) Peripheral found"
    }
}
