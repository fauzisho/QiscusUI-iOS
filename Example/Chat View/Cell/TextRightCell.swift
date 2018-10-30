//
//  QTextRightCell.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import UIKit
import QiscusUI
import QiscusCore

class TextRightCell: UIBaseChatCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.status(message: message)
        
        self.lbName.text = "You"
        self.lbTime.text = self.hour(date: message.date())
        self.tvContent.text = message.message

        lbNameHeight.constant = 0
    }
    
    func status(message: CommentModel){
        
        switch message.status {
        case .pending:
            let pendingIcon = QiscusUI.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.lightGray
            self.ivStatus.image = pendingIcon
        case .sending:
            let pendingIcon = QiscusUI.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.lightGray
            self.ivStatus.image = pendingIcon
        case .sent:
            let pendingIcon = QiscusUI.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.lightGray
            self.ivStatus.image = pendingIcon
        case .delivered:
            let pendingIcon = QiscusUI.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.lightGray
            self.ivStatus.image = pendingIcon
        case .read:
            let pendingIcon = QiscusUI.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.green
            self.ivStatus.image = pendingIcon
        case .deleted:
            let pendingIcon = QiscusUI.image(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.darkGray
            self.ivStatus.image = pendingIcon
        case .failed:
            let pendingIcon = QiscusUI.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.lightGray
            self.ivStatus.image = pendingIcon
        case .deleting:
            let pendingIcon = QiscusUI.image(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            self.ivStatus.tintColor = UIColor.lightGray
            self.ivStatus.image = pendingIcon
        }
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
    
}
