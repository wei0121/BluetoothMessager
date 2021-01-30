import UIKit
import BluetoothMessager
import CoreBluetooth

struct MessageBubble {
    var isSender: Bool
    var message: String
    var date: Date
}

protocol MessageBubbleViewControllerDelegate {
    func onUpdateMessages() -> [MessageBubble]
    func onSendMessages(message: String)
}

class MessageBubbleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    var delegate: MessageBubbleViewControllerDelegate?
    var data = [String]()
    
    @IBAction func onSendButtonTap(_ sender: Any) {
        self.delegate?.onSendMessages(message: textView.text)
    }
    
}

extension MessageBubbleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.onUpdateMessages().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell_sender")! as UITableViewCell
        (cell.viewWithTag(1) as! UILabel).text = delegate?.onUpdateMessages()[indexPath.row].isSender == true ? "Me" : "From"
        (cell.viewWithTag(2) as! UILabel).text = delegate?.onUpdateMessages()[indexPath.row].message ?? nil
        if let date = delegate?.onUpdateMessages()[indexPath.row].date {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let dateString = formatter.string(from: date)
            (cell.viewWithTag(3) as! UILabel).text = dateString
        }
        return cell
    }
}

extension MessageBubbleViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.delegate?.onSendMessages(message: textView.text)
        }
        return true
    }
}

extension Array where Element == MessageBubble {
    mutating func append(message: String, isSender: Bool) {
        self.append(MessageBubble(isSender: isSender, message: message, date: Date()))
    }
}
