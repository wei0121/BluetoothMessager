import UIKit
import BluetoothMessager
import CoreBluetooth

struct MessageBubble {
    var sender: String?
    var message: String
    var date: Date
}

protocol MessageBubbleViewControllerDelegate: class {
    func onUpdateMessages() -> [MessageBubble]
    func onSendMessages(message: String)
}

class MessageBubbleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    weak var delegate: MessageBubbleViewControllerDelegate?
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
        let cellIdentifier = delegate?.onUpdateMessages()[indexPath.row].sender == nil ? "cell_sender" : "cell_receiver"
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier)! as UITableViewCell
        (cell.viewWithTag(1) as! UILabel).text = delegate?.onUpdateMessages()[indexPath.row].sender ?? "Me"
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
            view.endEditing(true)
        }
        return true
    }
}

extension Array where Element == MessageBubble {
    mutating func append(message: String, sender: String?) {
        self.append(MessageBubble(sender: sender, message: message, date: Date()))
    }
}
