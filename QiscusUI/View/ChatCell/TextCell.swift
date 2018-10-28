//
//  LeftTextCell.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 08/05/18.
//

import UIKit
import QiscusCore

class TextCell: UIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var statusWidth: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rightConstraint = self.ivBaloonLeft.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        leftConstraint = self.ivBaloonLeft.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
    }
    
    override func present(message: CommentModel) {
        bindDataToView(data: message)
    }
    
    override func update(message: CommentModel) {
        bindDataToView(data: message)
    }
    
//    override func menuResponderView() -> UIView {
//        return self.ivBaloonLeft
//    }
    
    func bindDataToView(data: CommentModel) {
        self.tvContent.text = data.message
        self.lbName.text = data.username
        self.lbTime.text = data.hour()

        if data.isMyComment() {
            DispatchQueue.main.async {
                self.rightConstraint.isActive = true
            }
            
            lbNameTrailing.constant = 5
            lbNameLeading.constant = 20
            lbName.textAlignment = .right
            self.statusWidth.constant = 15
            
            switch data.status {
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
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
            case .failed:
                let pendingIcon = QiscusUI.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
                self.ivStatus.tintColor = UIColor.lightGray
                self.ivStatus.image = pendingIcon
            }
        } else {
            DispatchQueue.main.async {
                self.leftConstraint.isActive = true
            }
            
            lbNameTrailing.constant = 20
//            lbNameLeading.constant = 45
            lbName.textAlignment = .left
            self.statusWidth.constant = 0
        }

        if firstInSection {
            self.lbName.isHidden = false
            self.lbNameHeight.constant = CGFloat(21)
        } else {
            self.lbName.isHidden = true
            self.lbNameHeight.constant = CGFloat(0)
        }
        
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        rightConstraint.isActive = false
        leftConstraint.isActive = false
    }
}
